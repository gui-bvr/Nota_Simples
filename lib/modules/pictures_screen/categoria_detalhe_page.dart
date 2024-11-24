import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'categoria_controller.dart';

class CategoriaDetalhePage extends StatelessWidget {
  final Categoria categoria;

  CategoriaDetalhePage({super.key, required this.categoria});

  final CategoriaController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    controller.loadImages(categoria.id);

    return Scaffold(
      appBar: AppBar(title: Text(categoria.nome)),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemCount: controller.imagens.length,
                itemBuilder: (context, index) {
                  final imagem = controller.imagens[index];
                  return Column(
                    children: [
                      Image.file(
                        File(imagem.path),
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                      Text(imagem.description),
                    ],
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

class _AdicionarImagem extends StatelessWidget {
  final Categoria categoria;

  _AdicionarImagem({required this.categoria});

  final TextEditingController _descricaoController = TextEditingController();

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
                    categoria.id, _descricaoController.text);
                _descricaoController.clear();
              }
            },
          ),
        ],
      ),
    );
  }
}
