import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'controller/auth_controller.dart';
import 'controller/favorite_controller.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'service/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Local database (Hive) + akun bawaan
  await AuthService.init();

  // Shared Preferences (sesi login & favorit)
  final prefs = await SharedPreferences.getInstance();
  Get.put(AuthController(prefs), permanent: true);
  Get.put(FavoriteController(prefs), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Jika sesi login masih tersimpan, langsung ke halaman utama
    final loggedIn = Get.find<AuthController>().isLoggedIn.value;

    final scheme = ColorScheme.fromSeed(seedColor: const Color(0xFF2E9E6B));

    return GetMaterialApp(
      title: 'Rick & Morty Explorer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        appBarTheme: AppBarTheme(
          centerTitle: true,
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: scheme.onPrimary,
          ),
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F7F5),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      initialRoute: loggedIn ? AppRoutes.main : AppRoutes.login,
      getPages: AppPages.routes,
    );
  }
}
