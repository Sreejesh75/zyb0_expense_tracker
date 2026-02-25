import 'package:zybo_expense_tracker/features/categories/models/category_model.dart';

abstract class CategoryState {}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategoryLoaded extends CategoryState {
  final List<CategoryModel> categories;
  CategoryLoaded(this.categories);
}

class CategoryError extends CategoryState {
  final String message;
  CategoryError(this.message);
}

class CategorySyncing extends CategoryState {
  final List<CategoryModel> categories;
  CategorySyncing(
    this.categories,
  ); // allows retaining previously loaded features
}
