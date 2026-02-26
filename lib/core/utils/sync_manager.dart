import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zybo_expense_tracker/features/categories/bloc/category_bloc.dart';
import 'package:zybo_expense_tracker/features/categories/bloc/category_event.dart';
import 'package:zybo_expense_tracker/features/transactions/bloc/transaction_bloc.dart';
import 'package:zybo_expense_tracker/features/transactions/bloc/transaction_event.dart';

class SyncManager {
  static Future<void> performFullSync(BuildContext context) async {
    final catBloc = context.read<CategoryBloc>();
    final txBloc = context.read<TransactionBloc>();

    // 1. Trigger animated UI states
    catBloc.add(SyncCategoriesEvent());
    txBloc.add(SyncTransactionsEvent());

    final catDb = catBloc.localDb;
    final catApi = catBloc.apiService;
    final txDb = txBloc.localDb;
    final txApi = txBloc.apiService;

    try {
      print("🌐 GLOBAL SYNC: Started.");

      // STEP A: CLOUD PURGE
      print("🌐 GLOBAL SYNC: Step A - Purging Deletions.");

      // 1. Transactions First (Foreign Key Integrity)
      final deletedTxIds = await txDb.getDeletedTransactionIds();
      if (deletedTxIds.isNotEmpty) {
        print("🌐 SYNC: Purging ${deletedTxIds.length} Transactions...");
        final confirmed = await txApi.deleteTransactions(deletedTxIds);
        if (confirmed.isNotEmpty) {
          await txDb.hardDeleteTransactions(confirmed);
        }
      }

      // 2. Categories Second
      final deletedCatIds = await catDb.getDeletedCategoryIds();
      if (deletedCatIds.isNotEmpty) {
        print("🌐 SYNC: Purging ${deletedCatIds.length} Categories...");
        final confirmed = await catApi.deleteCategories(deletedCatIds);
        if (confirmed.isNotEmpty) {
          await catDb.hardDeleteCategories(confirmed);
        }
      }

      // STEP B: CLOUD UPLOAD
      print("🌐 GLOBAL SYNC: Step B - Uploading New Data.");

      // 1. Categories First (Transactions need them)
      // Force uploading ALL categories to fix broken backend mappings from previous builds
      final unsyncedCats = await catDb.getAllCategories();
      if (unsyncedCats.isNotEmpty) {
        print("🌐 SYNC: Uploading ${unsyncedCats.length} Categories...");
        final confirmed = await catApi.syncCategories(unsyncedCats);
        if (confirmed.isNotEmpty) {
          await catDb.markAsSynced(confirmed);
        }
      }

      // 2. Transactions Second
      final unsyncedTxs = await txDb.getUnsyncedActiveTransactions();
      if (unsyncedTxs.isNotEmpty) {
        print("🌐 SYNC: Uploading ${unsyncedTxs.length} Transactions...");
        final confirmed = await txApi.syncTransactions(unsyncedTxs);
        if (confirmed.isNotEmpty) {
          await txDb.markAsSynced(confirmed);
        }
      }

      print("🌐 GLOBAL SYNC: Completed Cleanly!");
    } catch (e) {
      print("❌ GLOBAL SYNC ERROR: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Sync error: ${e.toString().split('Exception: ').last}',
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      // 2. Re-load from local to update UI and remove sync animations
      catBloc.add(LoadCategoriesEvent());
      txBloc.add(LoadTransactionsEvent());
    }
  }
}
