abstract class CategoryEvent {}

class LoadCategoriesEvent extends CategoryEvent {}

class AddCategoryEvent extends CategoryEvent {
  final String name;
  AddCategoryEvent(this.name);
}

class DeleteCategoryEvent extends CategoryEvent {
  final String id;
  DeleteCategoryEvent(this.id);
}

class SyncCategoriesEvent extends CategoryEvent {}

class ClearLocalCategoriesEvent extends CategoryEvent {}
