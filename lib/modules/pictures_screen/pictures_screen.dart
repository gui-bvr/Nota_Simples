import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/categoria_controller.dart';
import '../fullscreen_image.dart';

class PicturesScreen extends StatelessWidget {
  final Categoria categoria;

  const PicturesScreen({super.key, required this.categoria});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CategoriaController>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await controller.loadImages(categoria.id);
    });

    return Scaffold(
      appBar: AppBar(title: Text('Imagens: ${categoria.nome}')),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.imagens.isEmpty) {
                return const Center(
                  child: Text('Nenhuma imagem encontrada.'),
                );
              }

              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemCount: controller.imagens.length,
                itemBuilder: (context, index) {
                  final imagem = controller.imagens[index];
                  return GestureDetector(
                    onTap: () {
                      Get.to(() => FullscreenImage(
                            imagePaths: controller.imagens
                                .map((img) => img.path)
                                .toList(),
                            initialIndex: index,
                          ));
                    },
                    child: Column(
                      children: [
                        Image.file(
                          File(imagem.path),
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                        Text(
                          imagem.description,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
          _AdicionarImagem(categoria: categoria),
        ],
      ),
    );
  }
}

class _AdicionarImagem extends StatefulWidget {
  final Categoria categoria;

  const _AdicionarImagem({required this.categoria});

  @override
  _AdicionarImagemState createState() => _AdicionarImagemState();
}

class _AdicionarImagemState extends State<_AdicionarImagem> {
  final TextEditingController _descricaoController = TextEditingController();

  @override
  void dispose() {
    _descricaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CategoriaController>();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _descricaoController,
              decoration: const InputDecoration(labelText: 'Descrição'),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              if (_descricaoController.text.isNotEmpty) {
                await controller.adicionarImagem(
                  widget.categoria.id,
                  _descricaoController.text,
                );
                _descricaoController.clear();
              } else {
                Get.snackbar(
                  'Aviso',
                  'A descrição não pode estar vazia.',
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
