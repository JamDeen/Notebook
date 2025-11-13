import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class DBHelper {
  static final DBHelper instance = DBHelper._internal();
  DBHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB('notes_app.db');
    return _db!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE,
            email TEXT,
            password TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE notes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER,
            title TEXT,
            content TEXT,
            created_at TEXT,
            FOREIGN KEY(user_id) REFERENCES users(id)
          )
        ''');
      },
    );
  }

  // -------- Users --------
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return db.insert('users', user);
  }

  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    final db = await database;
    final res = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
      limit: 1,
    );
    if (res.isNotEmpty) return res.first;
    return null;
  }

  // -------- Notes --------
  Future<int> insertNote(Map<String, dynamic> note) async {
    final db = await database;
    return db.insert('notes', note);
  }

  Future<List<Map<String, dynamic>>> getNotesByUser(int userId) async {
    final db = await database;
    return db.query(
      'notes',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
  }

  Future<int> updateNote(Map<String, dynamic> note, int id) async {
    final db = await database;
    return db.update('notes', note, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteNote(int id) async {
    final db = await database;
    return db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }
}
