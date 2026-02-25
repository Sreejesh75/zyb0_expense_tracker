import 'package:flutter_bloc/flutter_bloc.dart';
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
  }

  Future<void> _onLoadTransactions(
    LoadTransactionsEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    try {
      // 1. Instantly load and show local data
      final localData = await localDb.getAllTransactions();
      emit(TransactionLoaded(localData));

      // 2. Fetch latest from server & update local
      try {
        final serverData = await apiService.getTransactions();
        if (serverData.isNotEmpty) {
          for (var tx in serverData) {
            await localDb.insertTransaction(tx);
            await localDb.markAsSynced([tx.id]);
          }
          final newLocalData = await localDb.getAllTransactions();
          emit(TransactionLoaded(newLocalData));
        }
      } catch (_) {
        // Silent fail for server fetch if offline
      }
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

      // Try syncing immediately
      try {
        final syncedIds = await apiService.syncTransactions([transaction]);
        if (syncedIds.isNotEmpty) {
          await localDb.markAsSynced(syncedIds);
        }
      } catch (_) {
        // Leave as unsynced locally if offline
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

      if (state is TransactionLoaded) {
        final currentTransactions = (state as TransactionLoaded).transactions;
        emit(
          TransactionLoaded(
            currentTransactions.where((t) => t.id != event.id).toList(),
          ),
        );
      }

      // Try background sync for deletion
      try {
        final confirmedIds = await apiService.deleteTransactions([event.id]);
        if (confirmedIds.isNotEmpty) {
          await localDb.hardDeleteTransactions(confirmedIds);
        }
      } catch (_) {
        // Fail silently, will be handled by main sync workflow
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
      // We could add a TransactionSyncing state if needed, but keeping it simple

      try {
        // 1. STEP A: Clean up Deletions (Cloud Purge)
        final deletedIds = await localDb.getDeletedTransactionIds();
        if (deletedIds.isNotEmpty) {
          final confirmedDeletedIds = await apiService.deleteTransactions(
            deletedIds,
          );
          if (confirmedDeletedIds.isNotEmpty) {
            await localDb.hardDeleteTransactions(confirmedDeletedIds);
          }
        }

        // 2. STEP B: Upload New Data (Cloud Backup)
        final unsynced = await localDb.getUnsyncedActiveTransactions();
        if (unsynced.isNotEmpty) {
          final syncedIds = await apiService.syncTransactions(unsynced);
          if (syncedIds.isNotEmpty) {
            await localDb.markAsSynced(syncedIds);
          }
        }

        // Return to cleanly loaded state
        final refreshedData = await localDb.getAllTransactions();
        emit(TransactionLoaded(refreshedData));
      } catch (_) {
        // Fallback to current state on error
        emit(TransactionLoaded(currentState));
      }
    }
  }
}
