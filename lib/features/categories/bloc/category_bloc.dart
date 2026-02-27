import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    on<ClearLocalCategoriesEvent>(_onClearLocalCategories);
  }

  Future<void> _onClearLocalCategories(
    ClearLocalCategoriesEvent event,
    Emitter<CategoryState> emit,
  ) async {
    await localDb.clearAll();
    emit(CategoryInitial());
  }

  Future<void> _onLoadCategories(
    LoadCategoriesEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    try {
      // 1. Instantly load local data
      List<CategoryModel> localData = await localDb.getAllCategories();

      // Use SharedPreferences to track if we've already done the initial cloud fetch
      final prefs = await SharedPreferences.getInstance();
      final hasDoneInitialFetch =
          prefs.getBool('has_done_initial_category_fetch') ?? false;

      if (localData.isEmpty && !hasDoneInitialFetch) {
        bool hasRemote = false;
        try {
          final remoteData = await apiService.getCategories();
          if (remoteData.isNotEmpty) {
            hasRemote = true;
            for (var c in remoteData) {
              await localDb.insertCategory(
                c.copyWith(is_synced: 1, is_deleted: 0),
              );
            }
            localData = await localDb.getAllCategories();
          }
        } catch (e) {
          print("Failed to auto-fetch remote categories: $e");
        }

        // Only insert defaults if we couldn't fetch from remote AND we have nothing
        if (!hasRemote && localData.isEmpty) {
          final defaults = ['Grocery', 'Electricity', 'Water'];
          for (var name in defaults) {
            final cat = CategoryModel(id: _uuid.v4(), name: name, is_synced: 0);
            await localDb.insertCategory(cat);
            localData.add(cat);
          }
        }

        // Mark as done so we don't keep pulling deleted items back
        await prefs.setBool('has_done_initial_category_fetch', true);
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
    }
  }
}
