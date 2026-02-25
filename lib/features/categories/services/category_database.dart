import 'package:sqflite/sqflite.dart';
import 'package:zybo_expense_tracker/features/categories/models/category_model.dart';
import 'package:zybo_expense_tracker/core/database/database_helper.dart';

class CategoryDatabase {
  final String tableName = 'categories';

  Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        is_synced INTEGER NOT NULL DEFAULT 0,
        is_deleted INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<void> insertCategory(CategoryModel category) async {
    final db = await DatabaseHelper.instance.database;

    // Safety check: Don't overwrite if we have a local "is_deleted" flag
    final existing = await db.query(
      tableName,
      where: 'id = ? AND is_deleted = 1',
      whereArgs: [category.id],
    );

    if (existing.isNotEmpty) return;

    await db.insert(
      tableName,
      category.toDbMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteCategory(String id) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      tableName,
      {'is_deleted': 1, 'is_synced': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markAsSynced(List<String> ids) async {
    final db = await DatabaseHelper.instance.database;
    if (ids.isEmpty) return;

    final placeholders = List.filled(ids.length, '?').join(',');
    await db.update(
      tableName,
      {'is_synced': 1},
      where: 'id IN ($placeholders)',
      whereArgs: ids,
    );
  }

  Future<List<CategoryModel>> getAllCategories() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'is_deleted = 0',
    );

    return List.generate(maps.length, (i) {
      return CategoryModel.fromDbMap(maps[i]);
    });
  }

  Future<List<String>> getDeletedCategoryIds() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> result = await db.query(
      tableName,
      columns: ['id'],
      where: 'is_deleted = 1',
    );
    return result.map((row) => row['id'] as String).toList();
  }

  Future<void> hardDeleteCategories(List<String> ids) async {
    final db = await DatabaseHelper.instance.database;
    if (ids.isEmpty) return;

    final placeholders = List.filled(ids.length, '?').join(',');
    await db.delete(tableName, where: 'id IN ($placeholders)', whereArgs: ids);
  }

  Future<List<CategoryModel>> getUnsyncedActiveCategories() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'is_synced = 0 AND is_deleted = 0',
    );

    return maps.map((map) => CategoryModel.fromDbMap(map)).toList();
  }

  Future<bool> isTableEmpty() async {
    final db = await DatabaseHelper.instance.database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $tableName'),
    );
    return (count ?? 0) == 0;
  }

  Future<void> clearAll() async {
    final db = await DatabaseHelper.instance.database;
    await db.delete(tableName);
  }
}
