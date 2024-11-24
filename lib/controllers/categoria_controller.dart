import 'dart:async';
import 'dart:io';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../../db_helper.dart';

class Categoria {
  String id;
  String nome;

  Categoria({required this.id, required this.nome});
}

class ImageItem {
  String id;
  String categoryId;
  String path;
  String description;

  ImageItem({
    required this.id,
    required this.categoryId,
    required this.path,
    required this.description,
  });
}

class CategoriaController extends GetxController {
  final DBHelper _dbHelper = DBHelper();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var categorias = <Categoria>[].obs;
  var imagens = <ImageItem>[].obs; // Lista reativa para imagens

  @override
  void onInit() {
    super.onInit();
    _loadCategories();
  }

  // Carregar categorias do usuário logado
  Future<void> _loadCategories() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final db = await _dbHelper.database;
    final data = await db.query(
      'categories',
      where: 'userId = ?',
      whereArgs: [user.uid],
    );

    categorias.value = data.map((e) {
      return Categoria(
        id: e['id'] as String,
        nome: e['name'] as String,
      );
    }).toList();
  }

  // Adicionar uma nova categoria
  Future<void> adicionarCategoria(String nome) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final db = await _dbHelper.database;
    final id = DateTime.now().toIso8601String();

    await db.insert('categories', {
      'id': id,
      'name': nome,
      'userId': user.uid,
    });

    categorias.add(Categoria(id: id, nome: nome));
  }

  // Editar uma categoria
  Future<void> editarCategoria(String id, String novoNome) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final db = await _dbHelper.database;

    await db.update(
      'categories',
      {'name': novoNome},
      where: 'id = ? AND userId = ?',
      whereArgs: [id, user.uid],
    );

    final index = categorias.indexWhere((cat) => cat.id == id);
    if (index != -1) {
      categorias[index].nome = novoNome;
      categorias.refresh();
    }
  }

  // Remover uma categoria e suas imagens
  Future<void> removerCategoria(String id) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final db = await _dbHelper.database;

    // Remove as imagens associadas à categoria
    await db.delete(
      'images',
      where: 'categoryId = ? AND userId = ?',
      whereArgs: [id, user.uid],
    );

    // Remove a categoria
    await db.delete(
      'categories',
      where: 'id = ? AND userId = ?',
      whereArgs: [id, user.uid],
    );

    categorias.removeWhere((cat) => cat.id == id);
  }

  // Carregar imagens de uma categoria
  Future<void> loadImages(String categoryId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final db = await _dbHelper.database;
    final data = await db.query(
      'images',
      where: 'categoryId = ? AND userId = ?',
      whereArgs: [categoryId, user.uid],
    );

    imagens.value = data.map((e) {
      return ImageItem(
        id: e['id'] as String,
        categoryId: e['categoryId'] as String,
        path: e['path'] as String,
        description: e['description'] as String,
      );
    }).toList();
  }

  // Adicionar uma nova imagem
  Future<void> adicionarImagem(String categoryId, String description) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final path = pickedFile.path;
      final id = DateTime.now().toIso8601String();

      final db = await _dbHelper.database;

      await db.insert('images', {
        'id': id,
        'categoryId': categoryId,
        'path': path,
        'description': description,
        'userId': user.uid,
      });

      imagens.add(ImageItem(
        id: id,
        categoryId: categoryId,
        path: path,
        description: description,
      ));
    } else {
      Get.snackbar(
        'Erro',
        'Nenhuma imagem selecionada.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Editar descrição de uma imagem
  Future<void> editarImagem(String id, String novaDescricao) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final db = await _dbHelper.database;

    await db.update(
      'images',
      {'description': novaDescricao},
      where: 'id = ? AND userId = ?',
      whereArgs: [id, user.uid],
    );

    final index = imagens.indexWhere((img) => img.id == id);
    if (index != -1) {
      imagens[index].description = novaDescricao;
      imagens.refresh();
    }
  }

  // Remover uma imagem
  Future<void> removerImagem(String id) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final db = await _dbHelper.database;

    final index = imagens.indexWhere((img) => img.id == id);
    if (index != -1) {
      final path = imagens[index].path;

      // Remove do banco de dados
      await db.delete(
        'images',
        where: 'id = ? AND userId = ?',
        whereArgs: [id, user.uid],
      );

      // Remove da lista reativa
      imagens.removeAt(index);

      // Exclui o arquivo local
      final file = File(path);
      if (file.existsSync()) {
        file.deleteSync();
      }
    }
  }
}
