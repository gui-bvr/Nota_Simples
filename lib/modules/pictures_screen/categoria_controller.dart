import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'db_helper.dart';

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

  ImageItem(
      {required this.id,
      required this.categoryId,
      required this.path,
      required this.description});
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
    final data = await _dbHelper.getCategories();
    categorias.value =
        data.map((e) => Categoria(id: e['id'], nome: e['name'])).toList();
  }

  Future<void> loadImages(String categoryId) async {
    final data = await _dbHelper.getImagesByCategory(categoryId);
    imagens.value = data
        .map((e) => ImageItem(
              id: e['id'],
              categoryId: e['categoryId'],
              path: e['path'],
              description: e['description'],
            ))
        .toList();
  }

  Future<void> adicionarCategoria(String nome) async {
    final id = const Uuid().v4();
    final categoria = Categoria(id: id, nome: nome);
    categorias.add(categoria);
    await _dbHelper.insertCategory({'id': id, 'name': nome});
  }

  Future<void> adicionarImagem(String categoryId, String description) async {
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
  }
}
