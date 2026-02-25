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

      // Seed default categories if literally empty
      if (localData.isEmpty) {
        final defaults = ['Food', 'Bills', 'Transport', 'Shopping'];
        for (var name in defaults) {
          final cat = CategoryModel(id: _uuid.v4(), name: name, isSynced: 0);
          await localDb.insertCategory(cat);
          localData.add(cat);
        }
      }

      emit(CategoryLoaded(localData));

      // 2. Fetch latest from server
      try {
        final serverData = await apiService.getCategories();
        if (serverData.isNotEmpty) {
          for (var cat in serverData) {
            await localDb.insertCategory(cat);
            await localDb.markAsSynced(cat.id);
          }
          final newLocalData = await localDb.getAllCategories();
          emit(CategoryLoaded(newLocalData));
        }
      } catch (_) {
        // Silent fail for server fetch if offline
      }
    } catch (e) {
      emit(CategoryError("Failed to load categories: $e"));
    }
  }

  Future<void> _onAddCategory(
    AddCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      final newCategory = CategoryModel(id: _uuid.v4(), name: event.name);

      // Optimistic update
      await localDb.insertCategory(newCategory);

      if (state is CategoryLoaded) {
        final currentCategories = (state as CategoryLoaded).categories;
        emit(CategoryLoaded([...currentCategories, newCategory]));
      } else {
        emit(CategoryLoaded([newCategory]));
      }

      // Sync immediately
      try {
        final syncedIds = await apiService.syncCategories([newCategory]);
        if (syncedIds.isNotEmpty) {
          for (var id in syncedIds) {
            await localDb.markAsSynced(id);
          }
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
      // Optimistic delete
      await localDb.deleteCategory(event.id);

      if (state is CategoryLoaded) {
        final currentCategories = (state as CategoryLoaded).categories;
        emit(
          CategoryLoaded(
            currentCategories.where((c) => c.id != event.id).toList(),
          ),
        );
      }

      // Delete on API
      try {
        await apiService.deleteCategories([event.id]);
      } catch (_) {
        // Ignore remote fail for optimistic local approach
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
        // Find unsynced
        final unsynced = await localDb.getUnsyncedCategories();
        if (unsynced.isNotEmpty) {
          final syncedIds = await apiService.syncCategories(unsynced);
          for (var id in syncedIds) {
            await localDb.markAsSynced(id);
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
