import 'package:get/get.dart';
import '../model/episode.dart';
import '../service/api_service.dart';

class EpisodeController extends GetxController {
  final ApiService _api = ApiService();

  final RxList<Episode> episodes = <Episode>[].obs;
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    fetchEpisodes();
  }

  /// Ambil semua halaman episode (API membatasi 20 data per halaman).
  /// Return true jika sukses.
  Future<bool> fetchEpisodes({bool silent = false}) async {
    if (!silent) isLoading.value = true;
    errorMessage.value = null;

    try {
      final all = <Episode>[];
      var page = 1;
      var hasNext = true;
      while (hasNext) {
        final result = await _api.fetchEpisodes(page: page);
        all.addAll(result.items);
        hasNext = result.hasNext;
        page++;
      }
      episodes.assignAll(all);
      return true;
    } catch (e) {
      if (!silent || episodes.isEmpty) {
        episodes.clear();
        errorMessage.value =
            e is ApiException ? e.message : 'Terjadi kesalahan tak terduga.';
      }
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
