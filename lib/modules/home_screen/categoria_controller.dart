import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/db_helper.dart';

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

  var categorias = <Categoria>[].obs;
  var imagens = <ImageItem>[].obs; // Lista reativa de imagens

  @override
  void onInit() {
    super.onInit();
    _loadCategories();
  }

  // Carregar categorias
  Future<void> _loadCategories() async {
    final db = await _dbHelper.database;
    final data = await db.query('categories');
    categorias.value = data.map((e) {
      return Categoria(
        id: e['id'] as String,
        nome: e['name'] as String,
      );
    }).toList();
  }

  // Carregar imagens de uma categoria
  Future<void> loadImages(String categoryId) async {
    final db = await _dbHelper.database;
    final data = await db.query(
      'images',
      where: 'categoryId = ?',
      whereArgs: [categoryId],
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

  // Adicionar uma categoria
  Future<void> adicionarCategoria(String nome) async {
    final db = await _dbHelper.database;
    final id = DateTime.now().toIso8601String();

    await db.insert('categories', {'id': id, 'name': nome});
    categorias.add(Categoria(id: id, nome: nome));
  }

  // Adicionar uma imagem
  Future<void> adicionarImagem(String categoryId, String description) async {
    final id = DateTime.now().toIso8601String();
    final path = await _pickImage();

    if (path != null) {
      final db = await _dbHelper.database;

      await db.insert('images', {
        'id': id,
        'categoryId': categoryId,
        'path': path,
        'description': description,
      });

      imagens.add(ImageItem(
        id: id,
        categoryId: categoryId,
        path: path,
        description: description,
      ));
    }
  }

  // Editar descrição de uma imagem
  Future<void> editarImagem(String id, String novaDescricao) async {
    final db = await _dbHelper.database;

    await db.update(
      'images',
      {'description': novaDescricao},
      where: 'id = ?',
      whereArgs: [id],
    );

    final index = imagens.indexWhere((img) => img.id == id);
    if (index != -1) {
      imagens[index].description = novaDescricao;
      imagens.refresh(); // Atualiza a interface
    }
  }

  // Remover uma imagem
  Future<void> removerImagem(String id) async {
    final db = await _dbHelper.database;

    await db.delete('images', where: 'id = ?', whereArgs: [id]);

    final index = imagens.indexWhere((img) => img.id == id);
    if (index != -1) {
      final path = imagens[index].path;
      imagens.removeAt(index);

      // Remover o arquivo local
      final file = File(path);
      if (file.existsSync()) {
        file.deleteSync();
      }
    }
  }

  // Editar uma categoria
  Future<void> editarCategoria(String id, String novoNome) async {
    final db = await _dbHelper.database;

    await db.update(
      'categories',
      {'name': novoNome},
      where: 'id = ?',
      whereArgs: [id],
    );

    final index = categorias.indexWhere((cat) => cat.id == id);
    if (index != -1) {
      categorias[index].nome = novoNome;
      categorias.refresh(); // Atualiza a interface
    }
  }

  // Remover uma categoria
  Future<void> removerCategoria(String id) async {
    final db = await _dbHelper.database;

    // Remover imagens associadas à categoria
    await db.delete('images', where: 'categoryId = ?', whereArgs: [id]);

    // Remover a categoria
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);

    categorias.removeWhere((cat) => cat.id == id);
  }

  // Selecionar imagem usando ImagePicker
  Future<String?> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    return pickedFile?.path;
  }
}
