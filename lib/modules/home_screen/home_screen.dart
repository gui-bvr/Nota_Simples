import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/categoria_controller.dart';
import '../pictures_screen/pictures_screen.dart';
import '../login_screen/login_screen.dart';
import 'package:sizer/sizer.dart';

class HomeScreen extends StatelessWidget {
  final CategoriaController controller = Get.put(CategoriaController());

  final RxString profileImagePath = ''.obs;
  final RxString userName = 'Usuário'.obs;
  final RxString userEmail = ''.obs;
  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          _UserProfile(
            profileImagePath: profileImagePath,
            userName: userName,
            userEmail: userEmail,
            onLogout: _logout,
          ),
          Expanded(
            child: Obx(() {
              if (controller.categorias.isEmpty) {
                return Center(
                    child: Text(
                  'Nenhuma categoria encontrada.',
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w100,
                  ),
                ));
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
    final TextEditingController nomeController =
        TextEditingController(text: categoria.nome);

    Get.dialog(
      AlertDialog(
        title: Text('Editar Categoria'),
        content: TextField(
          controller: nomeController,
          decoration: InputDecoration(labelText: 'Novo Nome'),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              if (nomeController.text.isNotEmpty) {
                await controller.editarCategoria(
                    categoria.id, nomeController.text);
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
        title: Text(
          'Deletar Categoria',
          style: TextStyle(
            fontSize: 18.sp,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Text(
          'Tem certeza de que deseja deletar a categoria "${categoria.nome}"? Todas as imagens tambem serão excluidas.',
          style: TextStyle(
            fontSize: 15.sp,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w100,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancelar',
              style: TextStyle(
                fontSize: 16.sp,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              await controller.removerCategoria(categoria.id);
              Get.back();
            },
            child: Text(
              'Deletar',
              style: TextStyle(
                fontSize: 16.sp,
              ),
            ),
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

  const _UserProfile({
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
                    : AssetImage('assets/icons/default_avatar.png')
                        as ImageProvider,
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

  const _AdicionarCategoria(this.controller);

  @override
  Widget build(BuildContext context) {
    final TextEditingController nomeController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: nomeController,
              decoration: InputDecoration(labelText: 'Nova Categoria'),
            ),
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              if (nomeController.text.isNotEmpty) {
                controller.adicionarCategoria(nomeController.text);
                nomeController.clear();
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
