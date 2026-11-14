import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/auth_controller.dart';
import '../../controller/main_controller.dart';
import 'episode_page.dart';
import 'favorite_page.dart';
import 'home_page.dart';

/// Kerangka halaman utama: AppBar (+ tombol logout) dan Bottom Navigation Bar.
class MainPage extends StatelessWidget {
  MainPage({super.key});

  final MainController controller = Get.find<MainController>();

  static const _titles = ['Rick & Morty', 'Favorites', 'Episodes'];

  Future<void> _confirmLogout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Yakin ingin keluar dari akun?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (ok == true) await Get.find<AuthController>().logout();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: AppBar(
          title: Text(_titles[controller.index.value]),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: () => _confirmLogout(context),
            ),
          ],
        ),
        // IndexedStack menjaga posisi scroll & state tiap tab
        body: IndexedStack(
          index: controller.index.value,
          children: [HomePage(), FavoritePage(), EpisodePage()],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: controller.index.value,
          onTap: controller.changeTab,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Characters',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Favorites',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.play_circle_fill),
              label: 'Episodes',
            ),
          ],
        ),
      ),
    );
  }
}
