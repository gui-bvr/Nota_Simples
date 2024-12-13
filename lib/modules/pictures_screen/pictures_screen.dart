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

    // Carregar imagens da categoria ao abrir a tela
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadImages(categoria.id);
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

              final validImages = controller.imagens
                  .where((img) => File(img.path).existsSync())
                  .toList();

              if (validImages.isEmpty) {
                return const Center(
                  child: Text('Nenhuma imagem válida encontrada.'),
                );
              }

              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemCount: validImages.length,
                itemBuilder: (context, index) {
                  final imagem = validImages[index];
                  return GestureDetector(
                    onTap: () {
                      // Abrir tela de visualização com navegação e zoom
                      Get.to(() => FullscreenImage(
                            imagePaths:
                                validImages.map((img) => img.path).toList(),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                imagem.description,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'editar') {
                                  _mostrarDialogoEditar(context, imagem);
                                } else if (value == 'deletar') {
                                  _mostrarDialogoDeletar(context, imagem);
                                }
                              },
                              itemBuilder: (context) => const [
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
                          ],
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

  // Exibir diálogo para editar a descrição
  void _mostrarDialogoEditar(BuildContext context, ImageItem imagem) {
    final descricaoController = TextEditingController(text: imagem.description);

    Get.dialog(
      AlertDialog(
        title: const Text('Editar Descrição'),
        content: TextField(
          controller: descricaoController,
          decoration: const InputDecoration(labelText: 'Descrição'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final controller = Get.find<CategoriaController>();
                await controller.editarImagem(
                  imagem.id,
                  descricaoController.text,
                );
                Get.back();
              } catch (e) {
                Get.snackbar(
                  'Erro',
                  'Falha ao editar descrição: $e',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  // Exibir diálogo para confirmar a exclusão
  void _mostrarDialogoDeletar(BuildContext context, ImageItem imagem) {
    Get.dialog(
      AlertDialog(
        title: const Text('Deletar Imagem'),
        content: const Text('Tem certeza de que deseja deletar esta imagem?'),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final controller = Get.find<CategoriaController>();
                await controller.removerImagem(imagem.id);
                Get.back();
              } catch (e) {
                Get.snackbar(
                  'Erro',
                  'Falha ao deletar imagem: $e',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            child: const Text('Deletar'),
          ),
        ],
      ),
    );
  }
}

// Widget para adicionar imagens à galeria
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
    final CategoriaController controller = Get.find();

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
                try {
                  await controller.adicionarImagem(
                    widget.categoria.id,
                    _descricaoController.text,
                  );
                  _descricaoController.clear();
                } catch (e) {
                  Get.snackbar(
                    'Erro',
                    'Falha ao adicionar imagem: $e',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
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
