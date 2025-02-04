import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../utils/db_helper.dart';

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

  Future<void> _loadCategories() async {
    try {
      final data = await _dbHelper.getCategories();
      categorias.value = data
          .map((e) =>
              Categoria(id: e['id'] as String, nome: e['name'] as String))
          .toList();
    } catch (e) {
      print('Erro ao carregar categorias: $e');
      Get.snackbar(
        'Erro',
        'Não foi possível carregar as categorias.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> loadImages(String categoryId) async {
    try {
      imagens.clear(); // Limpa imagens anteriores
      final data = await _dbHelper.getImagesByCategory(categoryId);
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

  Future<void> adicionarCategoria(String nome) async {
    try {
      final id = const Uuid().v4();
      final categoria = Categoria(id: id, nome: nome);
      categorias.add(categoria);
      await _dbHelper.insertCategory({'id': id, 'name': nome});
    } catch (e) {
      print('Erro ao adicionar categoria: $e');
      Get.snackbar(
        'Erro',
        'Não foi possível adicionar a categoria.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

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

        await _dbHelper.insertImage({
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
        'Não foi possível salvar a imagem.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> editarImagem(String id, String description) async {
    try {
      await _dbHelper.updateImage(id, {'description': description});
      final index = imagens.indexWhere((img) => img.id == id);
      if (index != -1) {
        imagens[index].description = description;
        imagens.refresh();
      }
    } catch (e) {
      print('Erro ao editar imagem: $e');
      Get.snackbar(
        'Erro',
        'Não foi possível editar a descrição.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> removerImagem(String id) async {
    try {
      await _dbHelper.deleteImage(id);
      imagens.removeWhere((img) => img.id == id);
    } catch (e) {
      print('Erro ao remover imagem: $e');
      Get.snackbar(
        'Erro',
        'Não foi possível remover a imagem.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  editarCategoria(String id, String text) {}

  removerCategoria(String id) {}
}
