import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/categoria_controller.dart';
import '../pictures_screen/pictures_screen.dart';
import '../login_screen/login_screen.dart';

class HomeScreen extends StatelessWidget {
  final CategoriaController controller = Get.put(CategoriaController());

  // Estados reativos para o perfil
  final RxString profileImagePath = ''.obs; // Caminho da imagem de perfil
  final RxString userName = 'Usuário'.obs; // Nome escolhido pelo usuário
  final RxString userEmail = ''.obs; // Email do Firebase

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Obter o email do Firebase Authentication ao inicializar
    _fetchUserEmail();

    return Scaffold(
      appBar: AppBar(
        title: Text('Categorias'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Sair',
          ),
        ],
      ),
      body: Column(
        children: [
          // Seção do perfil
          _UserProfile(
            profileImagePath: profileImagePath,
            userName: userName,
            userEmail: userEmail,
            onLogout: _logout,
          ),
          // Lista de categorias
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
                      Get.to(() => PicturesScreen(categoria: categoria));
                    },
                  );
                },
              );
            }),
          ),
          _AdicionarCategoria(controller),
        ],
      ),
    );
  }

  // Busca o email do usuário autenticado no Firebase
  void _fetchUserEmail() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userEmail.value = user.email ?? 'Sem email disponível';
    }
  }

  // Realiza o logout do usuário
  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Get.offAll(() => LoginScreen());
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Falha ao realizar logout: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
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

class _UserProfile extends StatelessWidget {
  final RxString profileImagePath;
  final RxString userName;
  final RxString userEmail;
  final VoidCallback onLogout;

  _UserProfile({
    required this.profileImagePath,
    required this.userName,
    required this.userEmail,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Obx(() {
            return GestureDetector(
              onTap: () => _selecionarImagem(),
              child: CircleAvatar(
                radius: 40,
                backgroundImage: profileImagePath.isNotEmpty
                    ? FileImage(File(profileImagePath.value))
                    : AssetImage('assets/default_avatar.png') as ImageProvider,
                child: profileImagePath.isEmpty
                    ? Icon(Icons.camera_alt, size: 30, color: Colors.white)
                    : null,
              ),
            );
          }),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => Text(
                      userName.value,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    )),
                Obx(() => Text(
                      userEmail.value,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    )),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: onLogout,
            tooltip: 'Sair',
          ),
        ],
      ),
    );
  }

  Future<void> _selecionarImagem() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      profileImagePath.value = pickedFile.path;
    }
  }
}

class _AdicionarCategoria extends StatelessWidget {
  final CategoriaController controller;

  const _AdicionarCategoria(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController _nomeController = TextEditingController();

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
                controller.adicionarCategoria(_nomeController.text);
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
