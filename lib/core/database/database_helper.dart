import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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

    return await openDatabase(path, version: 1, onCreate: _createDB);
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
  }

  Future<void> saveUserProfile(String nickname, String token) async {
    final db = await instance.database;
    await db.insert('user_profile', {
      'nickname': nickname,
      'token': token,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
