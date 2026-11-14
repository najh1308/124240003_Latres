import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/character.dart';
import '../service/api_service.dart';

class CharacterController extends GetxController {
  final ApiService _api = ApiService();

  // State
  final RxList<Character> characters = <Character>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool moreError = false.obs;
  final RxnString errorMessage = RxnString();
  final RxString selectedStatus = ''.obs; // '' = semua
  final RxString searchQuery = ''.obs;

  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();

  int _page = 1;
  bool hasNext = true;
  int _requestId = 0; // mencegah response lama menimpa response baru

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    // Pencarian ditunda 500 ms supaya tidak request di setiap huruf
    debounce(
      searchQuery,
      (_) => fetchInitial(),
      time: const Duration(milliseconds: 500),
    );
    fetchInitial();
  }

  @override
  void onClose() {
    scrollController.dispose();
    searchController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    final pos = scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 300) loadMore();
  }

  void setStatus(String status) {
    if (selectedStatus.value == status) return;
    selectedStatus.value = status;
    fetchInitial();
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  /// Ambil halaman pertama (sesuai filter + pencarian).
  /// [silent] = true dipakai pull-to-refresh (tanpa loading layar penuh).
  /// Return true jika sukses.
  Future<bool> fetchInitial({bool silent = false}) async {
    final id = ++_requestId;
    if (!silent) isLoading.value = true;
    errorMessage.value = null;
    moreError.value = false;
    isLoadingMore.value = false;
    _page = 1;

    try {
      final result = await _api.fetchCharacters(
        page: 1,
        status: selectedStatus.value,
        name: searchQuery.value,
      );
      if (id != _requestId) return true;
      characters.assignAll(result.items);
      hasNext = result.hasNext;
      return true;
    } catch (e) {
      if (id != _requestId) return false;
      if (!silent || characters.isEmpty) {
        characters.clear();
        errorMessage.value =
            e is ApiException ? e.message : 'Terjadi kesalahan tak terduga.';
      }
      return false;
    } finally {
      if (id == _requestId) isLoading.value = false;
    }
  }

  /// Infinite scroll: ambil halaman berikutnya.
  Future<void> loadMore() async {
    if (isLoading.value || isLoadingMore.value || !hasNext) return;

    final id = _requestId;
    isLoadingMore.value = true;
    moreError.value = false;

    try {
      final result = await _api.fetchCharacters(
        page: _page + 1,
        status: selectedStatus.value,
        name: searchQuery.value,
      );
      if (id != _requestId) return;
      _page++;
      characters.addAll(result.items);
      hasNext = result.hasNext;
    } catch (_) {
      if (id == _requestId) moreError.value = true;
    } finally {
      if (id == _requestId) isLoadingMore.value = false;
    }
  }
}
