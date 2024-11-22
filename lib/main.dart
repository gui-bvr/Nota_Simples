import 'routes/app_imports.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    print('Firebase Initialized');
  } catch (e) {
    print('Error initializing Firebase: $e');
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NoteSnap',
      initialRoute: AppRoutes.initial,
      getPages: AppPages.pages,
    );
  }
}
