import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:zybo_expense_tracker/features/categories/models/category_model.dart';
import 'package:zybo_expense_tracker/features/categories/services/category_database.dart';
import 'package:zybo_expense_tracker/features/categories/services/category_service.dart';
import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryDatabase localDb;
  final CategoryService apiService;
  final _uuid = const Uuid();

  CategoryBloc({required this.localDb, required this.apiService})
    : super(CategoryInitial()) {
    on<LoadCategoriesEvent>(_onLoadCategories);
    on<AddCategoryEvent>(_onAddCategory);
    on<DeleteCategoryEvent>(_onDeleteCategory);
    on<SyncCategoriesEvent>(_onSyncCategories);
  }

  Future<void> _onLoadCategories(
    LoadCategoriesEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    try {
      // 1. Instantly load local data
      List<CategoryModel> localData = await localDb.getAllCategories();

      bool isEmpty = await localDb.isTableEmpty();
      if (isEmpty) {
        final defaults = ['Food', 'Bills', 'Transport', 'Shopping'];
        for (var name in defaults) {
          final cat = CategoryModel(id: _uuid.v4(), name: name, is_synced: 0);
          await localDb.insertCategory(cat);
          localData.add(cat);
        }
      }

      emit(CategoryLoaded(localData));
    } catch (e) {
      emit(CategoryError("Failed to load categories: $e"));
    }
  }

  Future<void> _onAddCategory(
    AddCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      final newCategory = CategoryModel(
        id: _uuid.v4(),
        name: event.name,
        is_synced: 0,
      );

      // Optimistic update
      await localDb.insertCategory(newCategory);

      if (state is CategoryLoaded) {
        final currentCategories = (state as CategoryLoaded).categories;
        emit(CategoryLoaded([...currentCategories, newCategory]));
      } else {
        emit(CategoryLoaded([newCategory]));
      }

      // Sync immediately if possible
      try {
        final syncedIds = await apiService.syncCategories([newCategory]);
        if (syncedIds.isNotEmpty) {
          await localDb.markAsSynced(syncedIds);
        }
      } catch (_) {
        // Leave unsynced locally
      }
    } catch (e) {
      emit(CategoryError("Failed to add category"));
      add(LoadCategoriesEvent()); // Revert UI
    }
  }

  Future<void> _onDeleteCategory(
    DeleteCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      // Optimistic delete: Mark as deleted in local DB
      await localDb.deleteCategory(event.id);

      if (state is CategoryLoaded) {
        final currentCategories = (state as CategoryLoaded).categories;
        emit(
          CategoryLoaded(
            currentCategories.where((c) => c.id != event.id).toList(),
          ),
        );
      }

      // Try background sync for deletion
      try {
        final deletedIds = await apiService.deleteCategories([event.id]);
        if (deletedIds.isNotEmpty) {
          await localDb.hardDeleteCategories(deletedIds);
        }
      } catch (_) {
        // Leave is_deleted=1 locally for next sync attempt
      }
    } catch (e) {
      emit(CategoryError("Failed to delete category"));
      add(LoadCategoriesEvent()); // Revert UI
    }
  }

  Future<void> _onSyncCategories(
    SyncCategoriesEvent event,
    Emitter<CategoryState> emit,
  ) async {
    if (state is CategoryLoaded) {
      final currentState = (state as CategoryLoaded).categories;
      emit(CategorySyncing(currentState));

      try {
        // 1. STEP A: Clean up Deletions (Cloud Purge)
        final deletedIds = await localDb.getDeletedCategoryIds();
        if (deletedIds.isNotEmpty) {
          final confirmedDeletedIds = await apiService.deleteCategories(
            deletedIds,
          );
          if (confirmedDeletedIds.isNotEmpty) {
            await localDb.hardDeleteCategories(confirmedDeletedIds);
          }
        }

        // 2. STEP B: Upload New Data (Cloud Backup)
        final unsynced = await localDb.getUnsyncedActiveCategories();
        if (unsynced.isNotEmpty) {
          final syncedIds = await apiService.syncCategories(unsynced);
          if (syncedIds.isNotEmpty) {
            await localDb.markAsSynced(syncedIds);
          }
        }

        // Return to cleanly loaded state
        final refreshedData = await localDb.getAllCategories();
        emit(CategoryLoaded(refreshedData));
      } catch (_) {
        // Default back to loaded on error
        emit(CategoryLoaded(currentState));
      }
    }
  }
}
