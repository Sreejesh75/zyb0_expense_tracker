import 'package:sqflite/sqflite.dart';
import 'package:zybo_expense_tracker/core/database/database_helper.dart';
import 'package:zybo_expense_tracker/features/transactions/models/transaction_model.dart';

class TransactionDatabase {
  static const String tableName = 'transactions';

  Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE $tableName (
        id TEXT PRIMARY KEY,
        note TEXT,
        amount REAL,
        type TEXT,
        category TEXT,
        timestamp TEXT,
        synced INTEGER DEFAULT 0
      )
    ''');
  }

  Future<void> insertTransaction(TransactionModel transaction) async {
    final db = await DatabaseHelper.instance.database;
    final map = transaction.toJson();
    map['synced'] = 0; // Not synced by default
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
      {'synced': 1},
      where: 'id IN ($placeholders)',
      whereArgs: ids,
    );
  }

  Future<List<TransactionModel>> getUnsyncedTransactions() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'synced = 0',
    );
    return maps.map((map) => TransactionModel.fromJson(map)).toList();
  }

  Future<List<TransactionModel>> getAllTransactions() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      orderBy: 'timestamp DESC',
    );
    return maps.map((map) => TransactionModel.fromJson(map)).toList();
  }

  Future<void> deleteTransaction(String id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }
}
