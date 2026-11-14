import 'package:hive_flutter/hive_flutter.dart';
import '../model/user.dart';

class AuthService {
  static const String boxName = 'users';

  // Akun bawaan untuk latihan responsi
  static const String _defaultUsername = 'latresponsi';
  static const String _defaultPassword = 'latres123';

  /// Dipanggil sekali di main(): init Hive, daftarkan adapter, buka box,
  /// lalu pastikan akun bawaan sudah ada di database.
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(UserAdapter());
    await Hive.openBox<User>(boxName);

    final box = Hive.box<User>(boxName);
    if (!box.containsKey(_defaultUsername)) {
      await box.put(
        _defaultUsername,
        User(username: _defaultUsername, password: _defaultPassword),
      );
    }
  }

  Box<User> get _box => Hive.box<User>(boxName);

  // Key box = username huruf kecil, supaya tidak case-sensitive
  User? find(String username) => _box.get(username.toLowerCase());

  bool exists(String username) => _box.containsKey(username.toLowerCase());

  Future<void> register(String username, String password) {
    return _box.put(
      username.toLowerCase(),
      User(username: username, password: password),
    );
  }
}
