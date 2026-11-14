import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/auth_controller.dart';
import '../controller/character_controller.dart';
import '../controller/detail_controller.dart';
import '../controller/episode_controller.dart';
import '../controller/favorite_controller.dart';
import '../controller/main_controller.dart';
import '../view/pages/detail_page.dart';
import '../view/pages/login_page.dart';
import '../view/pages/main_page.dart';
import '../view/pages/register_page.dart';
import 'app_routes.dart';

/// Halaman utama hanya boleh diakses setelah login.
/// Jika belum login, user dialihkan ke halaman login.
class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final loggedIn = Get.find<AuthController>().isLoggedIn.value;
    return loggedIn ? null : const RouteSettings(name: AppRoutes.login);
  }
}

class MainBinding extends Bindings {
  @override
  void dependencies() {
    // Muat favorit milik user yang baru login
    Get.find<FavoriteController>().load();

    Get.lazyPut<MainController>(() => MainController());
    Get.lazyPut<CharacterController>(() => CharacterController());
    Get.lazyPut<EpisodeController>(() => EpisodeController());
  }
}

class DetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetailController>(() => DetailController());
  }
}

class AppPages {
  static final routes = [
    GetPage(name: AppRoutes.login, page: () => const LoginPage()),
    GetPage(name: AppRoutes.register, page: () => const RegisterPage()),
    GetPage(
      name: AppRoutes.main,
      page: () => MainPage(),
      binding: MainBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.detail,
      page: () => DetailPage(),
      binding: DetailBinding(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}
