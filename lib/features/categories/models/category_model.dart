class CategoryModel {
  final String id;
  final String name;
  final int isSynced;

  CategoryModel({required this.id, required this.name, this.isSynced = 0});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      isSynced: 1, // Considered synced if arriving from remote
    );
  }

  factory CategoryModel.fromDbMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'],
      name: map['name'],
      isSynced: map['isSynced'] ?? 0,
    );
  }

  Map<String, dynamic> toDbMap() {
    return {'id': id, 'name': name, 'isSynced': isSynced};
  }

  Map<String, dynamic> toApiJson() {
    return {'id': id, 'name': name};
  }

  CategoryModel copyWith({String? id, String? name, int? isSynced}) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
