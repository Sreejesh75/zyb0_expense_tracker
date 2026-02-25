import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:zybo_expense_tracker/features/transactions/services/transaction_database.dart';
import 'package:zybo_expense_tracker/features/categories/services/category_database.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('expense_tracker.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // Basic table setup to demonstrate SQLite is used
    await db.execute('''
      CREATE TABLE user_profile (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nickname TEXT,
        token TEXT
      )
    ''');

    // Transactions table
    await TransactionDatabase().createTable(db);
    // Categories table
    await CategoryDatabase().createTable(db);
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await TransactionDatabase().createTable(db);
    }
    if (oldVersion < 3) {
      await CategoryDatabase().createTable(db);
    }
  }

  Future<void> saveUserProfile(String nickname, String token) async {
    final db = await instance.database;
    await db.insert('user_profile', {
      'nickname': nickname,
      'token': token,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    final db = await instance.database;
    final result = await db.query('user_profile', limit: 1);
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }
}
