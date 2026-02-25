import 'package:sqflite/sqflite.dart';
import 'package:zybo_expense_tracker/core/database/database_helper.dart';
import 'package:zybo_expense_tracker/features/transactions/models/transaction_model.dart';

class TransactionDatabase {
  static const String tableName = 'transactions';

  Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        id TEXT PRIMARY KEY,
        note TEXT,
        amount REAL,
        type TEXT,
        category_id TEXT,
        timestamp TEXT,
        is_synced INTEGER DEFAULT 0,
        is_deleted INTEGER DEFAULT 0
      )
    ''');
  }

  Future<void> insertTransaction(TransactionModel transaction) async {
    final db = await DatabaseHelper.instance.database;

    // Safety check: Don't overwrite if we have a local "is_deleted" flag
    final existing = await db.query(
      tableName,
      where: 'id = ? AND is_deleted = 1',
      whereArgs: [transaction.id],
    );

    if (existing.isNotEmpty) return;

    final map = transaction.toJson();
    // Maintain sync status if provided, otherwise default to 0
    map['is_synced'] = transaction.is_synced;
    await db.insert(
      tableName,
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
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

  Future<List<TransactionModel>> getUnsyncedTransactions() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'is_synced = 0',
    );
    return maps.map((map) => TransactionModel.fromJson(map)).toList();
  }

  Future<List<TransactionModel>> getUnsyncedActiveTransactions() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'is_synced = 0 AND is_deleted = 0',
    );
    return maps.map((map) => TransactionModel.fromJson(map)).toList();
  }

  Future<List<String>> getDeletedTransactionIds() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> result = await db.query(
      tableName,
      columns: ['id'],
      where: 'is_deleted = 1',
    );
    return result.map((row) => row['id'] as String).toList();
  }

  Future<void> hardDeleteTransactions(List<String> ids) async {
    final db = await DatabaseHelper.instance.database;
    if (ids.isEmpty) return;

    final placeholders = List.filled(ids.length, '?').join(',');
    await db.delete(tableName, where: 'id IN ($placeholders)', whereArgs: ids);
  }

  Future<List<TransactionModel>> getAllTransactions() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT t.*, c.name as categoryName
      FROM $tableName t
      LEFT JOIN categories c ON t.category_id = c.id
      WHERE t.is_deleted = 0
      ORDER BY t.timestamp DESC
    ''');
    return maps.map((map) => TransactionModel.fromJson(map)).toList();
  }

  Future<void> deleteTransaction(String id) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      tableName,
      {'is_deleted': 1, 'is_synced': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
