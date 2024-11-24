import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/categoria_controller.dart';
import '../pictures_screen/pictures_screen.dart';

class HomeScreen extends StatelessWidget {
  final CategoriaController controller = Get.put(CategoriaController());

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Categorias')),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.categorias.isEmpty) {
                return Center(child: Text('Nenhuma categoria encontrada.'));
              }
              return ListView.builder(
                itemCount: controller.categorias.length,
                itemBuilder: (ctx, index) {
                  final categoria = controller.categorias[index];
                  return ListTile(
                    title: Text(categoria.nome),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'editar') {
                          _mostrarDialogoEditar(context, categoria);
                        } else if (value == 'deletar') {
                          _mostrarDialogoDeletar(context, categoria);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'editar',
                          child: Text('Editar'),
                        ),
                        PopupMenuItem(
                          value: 'deletar',
                          child: Text('Deletar'),
                        ),
                      ],
                    ),
                    onTap: () {
                      // Navega para a tela de fotos com o ID e nome da categoria
                      Get.to(() => PicturesScreen(categoria: categoria));
                    },
                  );
                },
              );
            }),
          ),
          _AdicionarCategoria(controller: controller),
        ],
      ),
    );
  }

  void _mostrarDialogoEditar(BuildContext context, Categoria categoria) {
    final TextEditingController _nomeController =
        TextEditingController(text: categoria.nome);

    Get.dialog(
      AlertDialog(
        title: Text('Editar Categoria'),
        content: TextField(
          controller: _nomeController,
          decoration: InputDecoration(labelText: 'Novo Nome'),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              if (_nomeController.text.isNotEmpty) {
                await controller.editarCategoria(
                    categoria.id, _nomeController.text);
                Get.back();
              } else {
                Get.snackbar(
                  'Erro',
                  'O nome da categoria não pode estar vazio.',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            child: Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoDeletar(BuildContext context, Categoria categoria) {
    Get.dialog(
      AlertDialog(
        title: Text('Deletar Categoria'),
        content: Text(
          'Tem certeza de que deseja deletar a categoria "${categoria.nome}"? Todos os dados associados também serão apagados.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await controller.removerCategoria(categoria.id);
              Get.back();
            },
            child: Text('Deletar'),
          ),
        ],
      ),
    );
  }
}

class _AdicionarCategoria extends StatefulWidget {
  final CategoriaController controller;

  _AdicionarCategoria({required this.controller});

  @override
  _AdicionarCategoriaState createState() => _AdicionarCategoriaState();
}

class _AdicionarCategoriaState extends State<_AdicionarCategoria> {
  final TextEditingController _nomeController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _nomeController,
              decoration: InputDecoration(labelText: 'Nova Categoria'),
            ),
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              if (_nomeController.text.isNotEmpty) {
                widget.controller.adicionarCategoria(_nomeController.text);
                _nomeController.clear();
              } else {
                Get.snackbar(
                  'Aviso',
                  'O nome da categoria não pode estar vazio.',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
