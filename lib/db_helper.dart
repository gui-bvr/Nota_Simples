import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;

  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_database.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Tabela de Categorias
        await db.execute('''
          CREATE TABLE categories (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            userId TEXT NOT NULL
          )
        ''');

        // Tabela de Imagens
        await db.execute('''
          CREATE TABLE images (
            id TEXT PRIMARY KEY,
            categoryId TEXT NOT NULL,
            path TEXT NOT NULL,
            description TEXT,
            userId TEXT NOT NULL,
            FOREIGN KEY (categoryId) REFERENCES categories (id) ON DELETE CASCADE
          )
        ''');
      },
    );
  }

  Future<void> closeDB() async {
    final db = await database;
    db.close();
  }
}
