import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../db_helper.dart';

//teste

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
  var categorias = <Categoria>[].obs;
  var imagens = <ImageItem>[].obs;

  final _dbHelper = DBHelper();

  @override
  void onInit() {
    super.onInit();
    _loadCategories();
  }

  // Carregar categorias do banco de dados
  Future<void> _loadCategories() async {
    try {
      final data = await _dbHelper.getCategories();
      categorias.value =
          data.map((e) => Categoria(id: e['id'], nome: e['name'])).toList();
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Falha ao carregar categorias: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Carregar imagens por categoria
  Future<void> loadImages(String categoryId) async {
    try {
      final data = await _dbHelper.getImagesByCategory(categoryId);
      imagens.value = data
          .map((e) => ImageItem(
                id: e['id'],
                categoryId: e['categoryId'],
                path: e['path'],
                description: e['description'],
              ))
          .toList();
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Falha ao carregar imagens: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Adicionar uma nova categoria
  Future<void> adicionarCategoria(String nome) async {
    try {
      final id = const Uuid().v4();
      final categoria = Categoria(id: id, nome: nome);
      categorias.add(categoria);
      await _dbHelper.insertCategory({'id': id, 'name': nome});
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Falha ao adicionar categoria: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Adicionar uma nova imagem
  Future<void> adicionarImagem(String categoryId, String description) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final id = const Uuid().v4();
        final image = ImageItem(
          id: id,
          categoryId: categoryId,
          path: pickedFile.path,
          description: description,
        );
        imagens.add(image);

        await _dbHelper.insertImage({
          'id': id,
          'categoryId': categoryId,
          'path': pickedFile.path,
          'description': description,
        });
      }
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Falha ao adicionar imagem: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Editar descrição de uma imagem
  Future<void> editarImagem(String imageId, String novaDescricao) async {
    try {
      final index = imagens.indexWhere((img) => img.id == imageId);
      if (index != -1) {
        imagens[index].description = novaDescricao;
        imagens.refresh();

        final db = await _dbHelper.database;
        await db.update(
          'images',
          {'description': novaDescricao},
          where: 'id = ?',
          whereArgs: [imageId],
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Falha ao editar descrição: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Remover uma imagem
  Future<void> removerImagem(String imageId) async {
    try {
      final index = imagens.indexWhere((img) => img.id == imageId);
      if (index != -1) {
        final path = imagens[index].path;
        imagens.removeAt(index);

        final db = await _dbHelper.database;
        await db.delete(
          'images',
          where: 'id = ?',
          whereArgs: [imageId],
        );

        // Deletar o arquivo físico
        final file = File(path);
        if (file.existsSync()) {
          file.deleteSync();
        }
      }
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Falha ao remover imagem: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Editar o nome de uma categoria
  Future<void> editarCategoria(String id, String novoNome) async {
    try {
      final index = categorias.indexWhere((cat) => cat.id == id);
      if (index != -1) {
        categorias[index].nome = novoNome;
        categorias.refresh();

        final db = await _dbHelper.database;
        await db.update(
          'categories',
          {'name': novoNome},
          where: 'id = ?',
          whereArgs: [id],
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Falha ao editar categoria: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Remover uma categoria
  Future<void> removerCategoria(String id) async {
    try {
      final index = categorias.indexWhere((cat) => cat.id == id);
      if (index != -1) {
        categorias.removeAt(index);
        categorias.refresh();

        final db = await _dbHelper.database;
        await db.delete(
          'categories',
          where: 'id = ?',
          whereArgs: [id],
        );

        // Remover imagens associadas à categoria
        await db.delete(
          'images',
          where: 'categoryId = ?',
          whereArgs: [id],
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Falha ao remover categoria: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
