import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();

  factory DBHelper() {
    return _instance;
  }

  DBHelper._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'categories.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE categories (
            id TEXT PRIMARY KEY,
            name TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE images (
            id TEXT PRIMARY KEY,
            categoryId TEXT,
            path TEXT,
            description TEXT,
            FOREIGN KEY (categoryId) REFERENCES categories (id)
          )
        ''');
      },
    );
  }

  Future<void> insertCategory(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert('categories', data);
  }

  Future<void> insertImage(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert('images', data);
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final db = await database;
    return await db.query('categories');
  }

  Future<List<Map<String, dynamic>>> getImagesByCategory(
      String categoryId) async {
    final db = await database;
    return await db
        .query('images', where: 'categoryId = ?', whereArgs: [categoryId]);
  }
}
