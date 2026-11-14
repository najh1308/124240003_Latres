import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/character.dart';
import 'auth_controller.dart';

/// Daftar favorit disimpan di Shared Preferences (per user), sehingga
/// tidak hilang saat aplikasi ditutup. Controller ini permanen, jadi
/// Home, Detail, dan Favorite memakai state yang sama dan selalu sinkron.
class FavoriteController extends GetxController {
  FavoriteController(this._prefs);

  final SharedPreferences _prefs;
  final RxList<Character> favorites = <Character>[].obs;

  String get _key =>
      'favorites_${Get.find<AuthController>().username.value.toLowerCase()}';

  /// Muat favorit milik user yang sedang login.
  void load() {
    final raw = _prefs.getStringList(_key) ?? <String>[];
    favorites.assignAll(
      raw.map(
        (s) => Character.fromJson(jsonDecode(s) as Map<String, dynamic>),
      ),
    );
  }

  void clear() => favorites.clear();

  bool isFavorite(int id) => favorites.any((c) => c.id == id);

  /// Tambah jika belum ada, hapus jika sudah ada.
  /// Return true jika karakter ditambahkan, false jika dihapus.
  Future<bool> toggle(Character character) async {
    final index = favorites.indexWhere((c) => c.id == character.id);
    final added = index == -1;
    if (added) {
      favorites.add(character);
    } else {
      favorites.removeAt(index);
    }
    await _save();
    return added;
  }

  /// Hapus karakter, return posisi lama (dipakai untuk fitur "Urungkan").
  Future<int> remove(Character character) async {
    final index = favorites.indexWhere((c) => c.id == character.id);
    if (index != -1) {
      favorites.removeAt(index);
      await _save();
    }
    return index;
  }

  Future<void> insertAt(int index, Character character) async {
    if (isFavorite(character.id)) return;
    favorites.insert(index.clamp(0, favorites.length), character);
    await _save();
  }

  Future<void> _save() {
    return _prefs.setStringList(
      _key,
      favorites.map((c) => jsonEncode(c.toJson())).toList(),
    );
  }
}
