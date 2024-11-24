import 'package:flutter/material.dart';
import 'categoria_controller.dart';

class CategoriaDetalhePage extends StatelessWidget {
  final Categoria categoria;

  const CategoriaDetalhePage({super.key, required this.categoria});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(categoria.nome)),
      body: Center(
        child: Text('Conteúdo da categoria: ${categoria.nome}'),
      ),
    );
  }
}
