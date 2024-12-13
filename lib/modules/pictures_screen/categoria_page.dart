import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/categoria_controller.dart';
import '../pictures_screen/pictures_screen.dart';

class CategoriaPage extends StatelessWidget {
  final CategoriaController controller = Get.put(CategoriaController());

  CategoriaPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categorias')),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.categorias.isEmpty) {
                return const Center(
                  child: Text('Nenhuma categoria encontrada.'),
                );
              }
              return ListView.builder(
                itemCount: controller.categorias.length,
                itemBuilder: (ctx, index) {
                  final categoria = controller.categorias[index];
                  return ListTile(
                    title: Text(categoria.nome),
                    onTap: () {
                      _navegarParaPicturesScreen(categoria);
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

  void _navegarParaPicturesScreen(Categoria categoria) {
    try {
      print('Navegando para categoria: ${categoria.nome}, ID: ${categoria.id}');
      Get.to(() => PicturesScreen(categoria: categoria));
    } catch (e) {
      print('Erro ao navegar para a categoria: $e');
      Get.snackbar(
        'Erro',
        'Não foi possível abrir a categoria.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

class _AdicionarCategoria extends StatefulWidget {
  final CategoriaController controller;

  const _AdicionarCategoria({required this.controller, Key? key})
      : super(key: key);

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
              decoration: const InputDecoration(labelText: 'Nova Categoria'),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
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
