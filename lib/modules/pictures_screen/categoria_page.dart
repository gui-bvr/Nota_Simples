import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/categoria_controller.dart';
import '../pictures_screen/pictures_screen.dart';

class CategoriaPage extends StatelessWidget {
  final CategoriaController controller = Get.put(CategoriaController());

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
                    onTap: () {
                      // Navegar para a tela de imagens da categoria
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
