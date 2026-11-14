import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/character_controller.dart';
import '../../routes/app_routes.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/character_tile.dart';
import '../widgets/state_views.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final CharacterController c = Get.find<CharacterController>();

  // label -> nilai parameter ?status=
  static const Map<String, String> _filters = {
    'Semua': '',
    'Alive': 'alive',
    'Dead': 'dead',
    'Unknown': 'unknown',
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Bonus: pencarian berdasarkan nama
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: TextField(
            controller: c.searchController,
            textInputAction: TextInputAction.search,
            onChanged: (v) => c.searchQuery.value = v.trim(),
            decoration: InputDecoration(
              hintText: 'Cari karakter berdasarkan nama...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: ValueListenableBuilder<TextEditingValue>(
                valueListenable: c.searchController,
                builder: (context, value, _) => value.text.isEmpty
                    ? const SizedBox.shrink()
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: c.clearSearch,
                      ),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        // Filter status: Alive / Dead / Unknown
        SizedBox(
          height: 48,
          child: Obx(
            () => ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              children: _filters.entries.map((e) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(e.key),
                    selected: c.selectedStatus.value == e.value,
                    onSelected: (_) => c.setStatus(e.value),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        Expanded(
          child: Obx(() {
            if (c.isLoading.value) return const LoadingView();

            if (c.errorMessage.value != null) {
              return ErrorView(
                message: c.errorMessage.value!,
                onRetry: () => c.fetchInitial(),
              );
            }

            if (c.characters.isEmpty) {
              return const EmptyView(
                icon: Icons.search_off,
                title: 'Karakter tidak ditemukan',
                subtitle: 'Coba ubah filter atau kata kunci pencarian.',
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                final ok = await c.fetchInitial(silent: true);
                if (!ok && context.mounted) {
                  showAppSnackBar(context, 'Gagal memperbarui data.');
                }
              },
              child: ListView.builder(
                controller: c.scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 8),
                itemCount: c.characters.length + 1,
                itemBuilder: (context, index) {
                  if (index == c.characters.length) return _footer();

                  final character = c.characters[index];
                  return CharacterTile(
                    character: character,
                    onTap: () =>
                        Get.toNamed(AppRoutes.detail, arguments: character),
                  );
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  // Indikator "memuat lagi" di akhir list (infinite scroll)
  Widget _footer() {
    return Obx(() {
      if (c.isLoadingMore.value) {
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        );
      }
      if (c.moreError.value) {
        return Padding(
          padding: const EdgeInsets.all(8),
          child: TextButton.icon(
            onPressed: c.loadMore,
            icon: const Icon(Icons.refresh),
            label: const Text('Gagal memuat, ketuk untuk coba lagi'),
          ),
        );
      }
      return const SizedBox(height: 16);
    });
  }
}
