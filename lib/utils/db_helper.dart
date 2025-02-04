import 'package:path/path.dart';
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
    final path = await getDatabasesPath();
    final dbPath = join(path, 'categories.db');

    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        // Criação da tabela de categorias
        await db.execute('''
          CREATE TABLE categories (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL
          )
        ''');

        // Criação da tabela de imagens
        await db.execute('''
          CREATE TABLE images (
            id TEXT PRIMARY KEY,
            categoryId TEXT NOT NULL,
            path TEXT NOT NULL,
            description TEXT,
            FOREIGN KEY (categoryId) REFERENCES categories (id) ON DELETE CASCADE
          )
        ''');
      },
    );
  }

  /// Inserir uma nova categoria
  Future<void> insertCategory(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert('categories', data);
  }

  /// Inserir uma nova imagem
  Future<void> insertImage(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert('images', data);
  }

  /// Buscar todas as categorias
  Future<List<Map<String, dynamic>>> getCategories() async {
    final db = await database;
    return await db.query('categories');
  }

  /// Buscar todas as imagens de uma categoria
  Future<List<Map<String, dynamic>>> getImagesByCategory(
      String categoryId) async {
    final db = await database;
    return await db
        .query('images', where: 'categoryId = ?', whereArgs: [categoryId]);
  }

  /// Atualizar uma imagem
  Future<void> updateImage(String id, Map<String, dynamic> updates) async {
    final db = await database;
    await db.update(
      'images',
      updates,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Remover uma imagem
  Future<void> deleteImage(String id) async {
    final db = await database;
    await db.delete(
      'images',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Remover uma categoria (e suas imagens associadas, devido ao ON DELETE CASCADE)
  Future<void> deleteCategory(String id) async {
    final db = await database;
    await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Fechar o banco de dados
  Future<void> closeDB() async {
    final db = await database;
    await db.close();
  }
}
