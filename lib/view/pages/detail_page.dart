import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/detail_controller.dart';
import '../../controller/favorite_controller.dart';
import '../../model/character.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/state_views.dart';
import '../widgets/status_badge.dart';

class DetailPage extends StatelessWidget {
  DetailPage({super.key});

  final DetailController c = Get.find<DetailController>();
  final FavoriteController fav = Get.find<FavoriteController>();

  Future<void> _toggleFavorite(BuildContext context, Character ch) async {
    final added = await fav.toggle(ch);
    if (!context.mounted) return;
    showAppSnackBar(
      context,
      added
          ? '${ch.name} ditambahkan ke favorit'
          : '${ch.name} dihapus dari favorit',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(c.selected.name),
        actions: [
          // Icon favorit berubah sesuai status
          Obx(() {
            final ch = c.character.value;
            if (ch == null) return const SizedBox.shrink();
            final isFav = fav.isFavorite(ch.id);
            return IconButton(
              tooltip: isFav ? 'Hapus dari favorit' : 'Tambah ke favorit',
              icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
              color: isFav ? Colors.redAccent : null,
              onPressed: () => _toggleFavorite(context, ch),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (c.isLoading.value) return const LoadingView();

        final ch = c.character.value;
        if (c.errorMessage.value != null || ch == null) {
          return ErrorView(
            message: c.errorMessage.value ?? 'Data tidak tersedia.',
            onRetry: c.fetch,
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.network(
                    ch.image,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const LoadingView();
                    },
                    errorBuilder: (context, error, stack) => Container(
                      color: Colors.grey.shade300,
                      child: const Icon(
                        Icons.broken_image,
                        size: 64,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                ch.name,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Center(child: StatusBadge(status: ch.status, filled: true)),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      _InfoRow(icon: Icons.pets, label: 'Species', value: ch.species),
                      _InfoRow(icon: Icons.wc, label: 'Gender', value: ch.gender),
                      _InfoRow(icon: Icons.public, label: 'Origin', value: ch.origin),
                      _InfoRow(
                        icon: Icons.place,
                        label: 'Location',
                        value: ch.location,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Obx(() {
                final isFav = fav.isFavorite(ch.id);
                return FilledButton.icon(
                  onPressed: () => _toggleFavorite(context, ch),
                  style: FilledButton.styleFrom(
                    backgroundColor: isFav ? Colors.red : null,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
                  label: Text(
                    isFav ? 'Hapus dari Favorite' : 'Tambah ke Favorite',
                  ),
                );
              }),
            ],
          ),
        );
      }),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(label, style: const TextStyle(color: Colors.black54, fontSize: 13)),
      subtitle: Text(
        value,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
