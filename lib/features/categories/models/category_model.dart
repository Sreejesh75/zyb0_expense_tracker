class CategoryModel {
  final String id;
  final String name;
  final int is_synced;
  final int is_deleted;

  CategoryModel({
    required this.id,
    required this.name,
    this.is_synced = 0,
    this.is_deleted = 0,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      is_synced: 1, // Considered synced if arriving from remote
      is_deleted: json['is_deleted'] ?? 0,
    );
  }

  factory CategoryModel.fromDbMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'],
      name: map['name'],
      is_synced: map['is_synced'] ?? 0,
      is_deleted: map['is_deleted'] ?? 0,
    );
  }

  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'name': name,
      'is_synced': is_synced,
      'is_deleted': is_deleted,
    };
  }

  Map<String, dynamic> toApiJson() {
    return {'id': id, 'name': name, 'is_deleted': is_deleted};
  }

  CategoryModel copyWith({
    String? id,
    String? name,
    int? is_synced,
    int? is_deleted,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      is_synced: is_synced ?? this.is_synced,
      is_deleted: is_deleted ?? this.is_deleted,
    );
  }
}
