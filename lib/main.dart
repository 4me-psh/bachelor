import 'package:bachelor/controllers/clothing_item_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'configs/theme_config.dart';
import 'views/login_page.dart';
import 'views/home_page.dart';
import 'utils/jwt_storage.dart';
import 'controllers/gallery_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final token = await JwtStorage.getToken();
  final userId = await JwtStorage.getUserId();

  final Widget startPage = (token != null && userId != null)
      ? HomePage(userId: userId)
      : const LoginPage();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GalleryController()),
        ChangeNotifierProvider(create: (_) => ClothingItemController()),
      ],
      child: MyApp(startPage: startPage),
    ),
  );
}

class MyApp extends StatelessWidget {
  final Widget startPage;
  const MyApp({super.key, required this.startPage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Clothing Recommendation',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: startPage,
      routes: {
        '/login': (_) => const LoginPage(),
      },
    );
  }
}
