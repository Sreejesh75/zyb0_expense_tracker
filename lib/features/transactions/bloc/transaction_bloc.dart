import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zybo_expense_tracker/core/services/notification_service.dart';
import 'package:zybo_expense_tracker/features/transactions/services/transaction_database.dart';
import 'package:zybo_expense_tracker/features/transactions/services/transaction_service.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionDatabase localDb;
  final TransactionService apiService;

  TransactionBloc({required this.localDb, required this.apiService})
    : super(TransactionInitial()) {
    on<LoadTransactionsEvent>(_onLoadTransactions);
    on<AddTransactionEvent>(_onAddTransaction);
    on<DeleteTransactionEvent>(_onDeleteTransaction);
    on<SyncTransactionsEvent>(_onSyncTransactions);
    on<ClearLocalDataEvent>(_onClearLocalData);
  }

  Future<void> _onClearLocalData(
    ClearLocalDataEvent event,
    Emitter<TransactionState> emit,
  ) async {
    await localDb.clearAll();
    emit(TransactionInitial());
  }

  Future<void> _onLoadTransactions(
    LoadTransactionsEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    try {
      // 1. Instantly load local data
      var localData = await localDb.getAllTransactions();

      // 2. If completely empty (e.g., fresh login after logout), attempt remote pull
      if (localData.isEmpty) {
        try {
          final remoteData = await apiService.getTransactions();
          if (remoteData.isNotEmpty) {
            for (var tx in remoteData) {
              await localDb.insertTransaction(
                tx.copyWith(is_synced: 1, is_deleted: 0),
              );
            }
            localData = await localDb.getAllTransactions();
          }
        } catch (e) {
          print("Failed to auto-fetch remote transactions on fresh login: $e");
        }
      }

      emit(TransactionLoaded(localData));
    } catch (e) {
      emit(TransactionError("Failed to load transactions: $e"));
    }
  }

  Future<void> _onAddTransaction(
    AddTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      // Optimistically update DB and UI
      final transaction = event.transaction.copyWith(
        is_synced: 0,
        is_deleted: 0,
      );
      await localDb.insertTransaction(transaction);

      if (state is TransactionLoaded) {
        final currentTransactions = (state as TransactionLoaded).transactions;
        emit(TransactionLoaded([transaction, ...currentTransactions]));
      } else {
        emit(TransactionLoaded([transaction]));
      }

      // Check Notification Limit Alert
      if (transaction.type == 'debit') {
        final prefs = await SharedPreferences.getInstance();
        final limit = prefs.getDouble('alert_limit') ?? 10000;

        final allTxs = await localDb.getAllTransactions();
        double currentMonthExpense = 0;
        final now = DateTime.now();

        for (var tx in allTxs) {
          if (tx.type == 'debit' &&
              tx.timestamp.month == now.month &&
              tx.timestamp.year == now.year) {
            currentMonthExpense += tx.amount;
          }
        }

        // If pushing past limit, fire notification!
        if (currentMonthExpense > limit) {
          await NotificationService().showLimitExceededNotification(
            limit,
            currentMonthExpense,
          );
        }
      }
    } catch (e) {
      emit(TransactionError("Failed to save transaction"));
      add(LoadTransactionsEvent()); // Revert
    }
  }

  Future<void> _onDeleteTransaction(
    DeleteTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      // Optimistic delete: Mark as deleted in local DB
      await localDb.deleteTransaction(event.id);

      if (state is TransactionLoaded || state is TransactionSyncing) {
        final currentTransactions = state is TransactionLoaded
            ? (state as TransactionLoaded).transactions
            : (state as TransactionSyncing).transactions;

        final updatedTransactions = currentTransactions
            .where((t) => t.id != event.id)
            .toList();

        if (state is TransactionLoaded) {
          emit(TransactionLoaded(updatedTransactions));
        } else {
          emit(TransactionSyncing(updatedTransactions));
        }
      }
    } catch (e) {
      emit(TransactionError("Failed to delete transaction"));
      add(LoadTransactionsEvent()); // Revert
    }
  }

  Future<void> _onSyncTransactions(
    SyncTransactionsEvent event,
    Emitter<TransactionState> emit,
  ) async {
    if (state is TransactionLoaded) {
      final currentState = (state as TransactionLoaded).transactions;
      emit(TransactionSyncing(currentState));
    }
  }
}
