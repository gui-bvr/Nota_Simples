import 'package:get/get.dart';

class Categoria {
  String id;
  String nome;

  Categoria({required this.id, required this.nome});
}

class CategoriaController extends GetxController {
  // Lista de categorias
  var categorias = <Categoria>[].obs;

  // Adicionar uma nova categoria
  void adicionarCategoria(String nome) {
    final novaCategoria = Categoria(id: DateTime.now().toString(), nome: nome);
    categorias.add(novaCategoria);
  }

  // Editar uma categoria existente
  void editarCategoria(String id, String novoNome) {
    final index = categorias.indexWhere((cat) => cat.id == id);
    if (index != -1) {
      categorias[index].nome = novoNome;
      categorias.refresh(); // Atualiza a lista
    }
  }

  // Remover uma categoria
  void removerCategoria(String id) {
    categorias.removeWhere((cat) => cat.id == id);
  }
}
