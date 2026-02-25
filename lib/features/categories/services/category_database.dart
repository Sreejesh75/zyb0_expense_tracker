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
        isSynced INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<void> insertCategory(CategoryModel category) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert(
      tableName,
      category.toDbMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteCategory(String id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> markAsSynced(String id) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      tableName,
      {'isSynced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<CategoryModel>> getAllCategories() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(tableName);

    return List.generate(maps.length, (i) {
      return CategoryModel.fromDbMap(maps[i]);
    });
  }

  Future<List<CategoryModel>> getUnsyncedCategories() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'isSynced = ?',
      whereArgs: [0],
    );

    return List.generate(maps.length, (i) {
      return CategoryModel.fromDbMap(maps[i]);
    });
  }

  Future<void> clearAll() async {
    final db = await DatabaseHelper.instance.database;
    await db.delete(tableName);
  }
}
