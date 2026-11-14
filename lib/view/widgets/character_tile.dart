import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/favorite_controller.dart';
import '../../model/character.dart';
import 'status_badge.dart';

/// Item karakter: foto, nama, status, dan tombol favorit.
class CharacterTile extends StatelessWidget {
  CharacterTile({
    super.key,
    required this.character,
    required this.onTap,
    this.onFavoritePressed,
  });

  final Character character;
  final VoidCallback onTap;

  /// Jika null, tombol hati hanya toggle favorit.
  final VoidCallback? onFavoritePressed;

  final FavoriteController _fav = Get.find<FavoriteController>();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  character.image,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const SizedBox(
                      width: 64,
                      height: 64,
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stack) => Container(
                    width: 64,
                    height: 64,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      character.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    StatusBadge(status: character.status),
                  ],
                ),
              ),
              Obx(() {
                final isFav = _fav.isFavorite(character.id);
                return IconButton(
                  tooltip: isFav ? 'Hapus dari favorit' : 'Tambah ke favorit',
                  icon: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? Colors.red : Colors.grey,
                  ),
                  onPressed: onFavoritePressed ?? () => _fav.toggle(character),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
