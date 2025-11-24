// lib/database/db_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _database;
  static final DBHelper instance = DBHelper._init();

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('sami_app.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 2, // ← This forces migration
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE users ADD COLUMN pin TEXT');
        }
      },
    );
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        pin TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        chat_id TEXT NOT NULL,
        sender_id INTEGER NOT NULL,
        message TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');
    
  }

  // Your other methods stay exactly the same
  Future<Map<String, dynamic>?> login(String email, String password) async {
    final db = await database;
    final result = await db.query('users', where: 'email = ? AND password = ?', whereArgs: [email, password]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('users', user);
  }

  Future<List<Map<String, dynamic>>> getAllUsersExcept(int id) async {
    final db = await database;
    return await db.query('users', where: 'id != ?', whereArgs: [id]);
  }

  Future<void> saveMessage(String chatId, int senderId, String text) async {
    final db = await database;
    await db.insert('messages', {
      'chat_id': chatId,
      'sender_id': senderId,
      'message': text,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getMessages(String chatId) async {
    final db = await database;
    return await db.query('messages', where: 'chat_id = ?', whereArgs: [chatId], orderBy: 'timestamp DESC');
  }

  Future<void> setUserPin(int userId, String pin) async {
    final db = await database;
    await db.update('users', {'pin': pin}, where: 'id = ?', whereArgs: [userId]);
  }

  Future<Map<String, dynamic>?> loginWithPin(String pin) async {
    final db = await database;
    final result = await db.query('users', where: 'pin = ?', whereArgs: [pin]);
    return result.isNotEmpty ? result.first : null;
  }
}