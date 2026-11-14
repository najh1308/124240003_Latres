import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/episode_controller.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/state_views.dart';

class EpisodePage extends StatelessWidget {
  EpisodePage({super.key});

  final EpisodeController c = Get.find<EpisodeController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (c.isLoading.value) return const LoadingView();

      if (c.errorMessage.value != null) {
        return ErrorView(
          message: c.errorMessage.value!,
          onRetry: () => c.fetchEpisodes(),
        );
      }

      if (c.episodes.isEmpty) {
        return const EmptyView(
          icon: Icons.movie_outlined,
          title: 'Belum ada episode',
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          final ok = await c.fetchEpisodes(silent: true);
          if (!ok && context.mounted) {
            showAppSnackBar(context, 'Gagal memperbarui data.');
          }
        },
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: c.episodes.length,
          itemBuilder: (context, index) {
            final ep = c.episodes[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  child: Text(
                    '${ep.id}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(
                  ep.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('${ep.code}  •  ${ep.airDate}'),
              ),
            );
          },
        ),
      );
    });
  }
}
