import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class FullscreenImage extends StatefulWidget {
  final List<String> imagePaths; // Lista de caminhos das imagens
  final int initialIndex; // Índice inicial da imagem exibida

  FullscreenImage({required this.imagePaths, required this.initialIndex});

  @override
  _FullscreenImageState createState() => _FullscreenImageState();
}

class _FullscreenImageState extends State<FullscreenImage> {
  late PageController _pageController; // Controlador para navegar entre imagens
  late int _currentIndex; // Índice atual da imagem

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Imagem ${_currentIndex + 1}/${widget.imagePaths.length}'),
        backgroundColor: Colors.black,
      ),
      body: PhotoViewGallery.builder(
        itemCount: widget.imagePaths.length,
        pageController: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        builder: (context, index) {
          final imagePath = widget.imagePaths[index];
          return PhotoViewGalleryPageOptions(
            imageProvider: FileImage(File(imagePath)),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2.0,
          );
        },
        scrollPhysics: BouncingScrollPhysics(),
        backgroundDecoration: BoxDecoration(color: Colors.black),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
