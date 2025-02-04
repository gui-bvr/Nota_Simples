import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
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
  var categorias = <Categoria>[].obs;
  var imagens = <ImageItem>[].obs;

  final _dbHelper = DBHelper();

  @override
  void onInit() {
    super.onInit();
    _loadCategories();
  }

  // Carregar categorias do banco
  Future<void> _loadCategories() async {
    try {
      final db = await _dbHelper.database;
      final data = await db.query('categories');
      categorias.value = data.map((e) {
        return Categoria(
          id: e['id'] as String,
          nome: e['name'] as String,
        );
      }).toList();
    } catch (e) {
      print('Erro ao carregar categorias: $e');
      Get.snackbar(
        'Erro',
        'Não foi possível carregar as categorias.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Carregar imagens de uma categoria
  Future<void> loadImages(String categoryId) async {
    try {
      imagens.clear(); // Limpar imagens antes de carregar
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
    } catch (e) {
      print('Erro ao carregar imagens: $e');
      Get.snackbar(
        'Erro',
        'Não foi possível carregar as imagens.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Adicionar uma nova categoria
  Future<void> adicionarCategoria(String nome) async {
    try {
      final db = await _dbHelper.database;
      final id = const Uuid().v4();

      await db.insert('categories', {
        'id': id,
        'name': nome,
      });

      categorias.add(Categoria(id: id, nome: nome));
    } catch (e) {
      print('Erro ao adicionar categoria: $e');
      Get.snackbar(
        'Erro',
        'Não foi possível adicionar a categoria.',
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
        final db = await _dbHelper.database;
        final id = const Uuid().v4();
        final image = ImageItem(
          id: id,
          categoryId: categoryId,
          path: pickedFile.path,
          description: description,
        );

        await db.insert('images', {
          'id': id,
          'categoryId': categoryId,
          'path': pickedFile.path,
          'description': description,
        });

        imagens.add(image);
      }
    } catch (e) {
      print('Erro ao adicionar imagem: $e');
      Get.snackbar(
        'Erro',
        'Não foi possível adicionar a imagem.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
