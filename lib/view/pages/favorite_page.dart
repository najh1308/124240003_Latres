import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/favorite_controller.dart';
import '../../routes/app_routes.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/character_tile.dart';
import '../widgets/state_views.dart';

class FavoritePage extends StatelessWidget {
  FavoritePage({super.key});

  final FavoriteController fav = Get.find<FavoriteController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (fav.favorites.isEmpty) {
        return const EmptyView(
          icon: Icons.favorite_border,
          title: 'Belum ada karakter favorit',
          subtitle: 'Ketuk ikon hati pada karakter untuk menambahkannya.',
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: fav.favorites.length,
        itemBuilder: (context, index) {
          final character = fav.favorites[index];

          // Geser (swipe) untuk menghapus dari favorit
          return Dismissible(
            key: ValueKey(character.id),
            direction: DismissDirection.horizontal,
            background: _swipeBackground(Alignment.centerLeft),
            secondaryBackground: _swipeBackground(Alignment.centerRight),
            onDismissed: (_) async {
              final oldIndex = await fav.remove(character);
              if (!context.mounted) return;
              showAppSnackBar(
                context,
                '${character.name} dihapus dari favorit',
                action: SnackBarAction(
                  label: 'Urungkan',
                  onPressed: () => fav.insertAt(oldIndex, character),
                ),
              );
            },
            child: CharacterTile(
              character: character,
              onTap: () => Get.toNamed(AppRoutes.detail, arguments: character),
            ),
          );
        },
      );
    });
  }

  Widget _swipeBackground(Alignment alignment) {
    return Container(
      alignment: alignment,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.delete, color: Colors.white),
    );
  }
}
