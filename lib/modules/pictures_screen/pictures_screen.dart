import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/categoria_controller.dart';
import '../fullscreen_image.dart';

class PicturesScreen extends StatelessWidget {
  final Categoria categoria;

  PicturesScreen({required this.categoria});

  final CategoriaController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    // Carregar imagens da categoria ao entrar na tela
    controller.loadImages(categoria.id);

    return Scaffold(
      appBar: AppBar(title: Text('Imagens: ${categoria.nome}')),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.imagens.isEmpty) {
                return Center(child: Text('Nenhuma imagem encontrada.'));
              }
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemCount: controller.imagens.length,
                itemBuilder: (context, index) {
                  final imagem = controller.imagens[index];
                  return GestureDetector(
                    onTap: () {
                      // Abrir a tela de visualização com navegação e zoom
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                imagem.description,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 12),
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
    final _descricaoController =
        TextEditingController(text: imagem.description);

    Get.dialog(
      AlertDialog(
        title: Text('Editar Descrição'),
        content: TextField(
          controller: _descricaoController,
          decoration: InputDecoration(labelText: 'Descrição'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await controller.editarImagem(
                  imagem.id,
                  _descricaoController.text,
                );
                Get.back();
              } catch (e) {
                Get.snackbar('Erro', 'Falha ao editar descrição: $e',
                    snackPosition: SnackPosition.BOTTOM);
              }
            },
            child: Text('Salvar'),
          ),
        ],
      ),
    );
  }

  // Exibir diálogo para confirmar a exclusão
  void _mostrarDialogoDeletar(BuildContext context, ImageItem imagem) {
    Get.dialog(
      AlertDialog(
        title: Text('Deletar Imagem'),
        content: Text('Tem certeza de que deseja deletar esta imagem?'),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await controller.removerImagem(imagem.id);
                Get.back();
              } catch (e) {
                Get.snackbar('Erro', 'Falha ao deletar imagem: $e',
                    snackPosition: SnackPosition.BOTTOM);
              }
            },
            child: Text('Deletar'),
          ),
        ],
      ),
    );
  }
}

// Widget para adicionar imagens à galeria
class _AdicionarImagem extends StatefulWidget {
  final Categoria categoria;

  _AdicionarImagem({required this.categoria});

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
              decoration: InputDecoration(labelText: 'Descrição'),
            ),
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              if (_descricaoController.text.isNotEmpty) {
                controller.adicionarImagem(
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
