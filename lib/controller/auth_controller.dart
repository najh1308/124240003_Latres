import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../routes/app_routes.dart';
import '../service/auth_service.dart';
import 'favorite_controller.dart';

/// Shared Preferences  -> menyimpan sesi login (key 'loginData')
/// Hive (local DB)     -> menyimpan akun yang terdaftar
class AuthController extends GetxController {
  AuthController(this._prefs);

  static const String _loginKey = 'loginData';
  static const String _usernameKey = 'username';

  final SharedPreferences _prefs;
  final AuthService _service = AuthService();

  late final RxBool isLoggedIn = RxBool(_prefs.getBool(_loginKey) ?? false);
  late final RxString username = RxString(_prefs.getString(_usernameKey) ?? '');

  /// Return null jika berhasil, atau pesan error jika gagal.
  Future<String?> login(String inputUsername, String inputPassword) async {
    final u = inputUsername.trim();
    if (u.isEmpty || inputPassword.isEmpty) {
      return 'Username dan password wajib diisi.';
    }

    final user = _service.find(u);
    if (user == null || user.password != inputPassword) {
      return 'Username atau password salah.';
    }

    await _prefs.setBool(_loginKey, true);
    await _prefs.setString(_usernameKey, user.username);
    isLoggedIn.value = true;
    username.value = user.username;
    return null;
  }

  /// Return null jika berhasil, atau pesan error jika gagal.
  Future<String?> register(
    String inputUsername,
    String inputPassword,
    String confirmPassword,
  ) async {
    final u = inputUsername.trim();
    if (u.isEmpty || inputPassword.isEmpty || confirmPassword.isEmpty) {
      return 'Semua field wajib diisi.';
    }
    if (u.length < 4) return 'Username minimal 4 karakter.';
    if (inputPassword.length < 6) return 'Password minimal 6 karakter.';
    if (inputPassword != confirmPassword) {
      return 'Konfirmasi password tidak sama.';
    }
    if (_service.exists(u)) return 'Username sudah dipakai.';

    await _service.register(u, inputPassword);
    return null;
  }

  Future<void> logout() async {
    await _prefs.setBool(_loginKey, false);
    await _prefs.remove(_usernameKey);
    isLoggedIn.value = false;
    username.value = '';
    Get.find<FavoriteController>().clear();
    Get.offAllNamed(AppRoutes.login);
  }
}
