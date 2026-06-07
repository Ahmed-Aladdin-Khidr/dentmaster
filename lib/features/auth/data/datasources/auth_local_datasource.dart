import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthLocalDatasource {
  Future<bool> isPasswordSet();
  Future<String?> getPasswordHash();
  Future<void> savePasswordHash(String hash);
}

class AuthLocalDatasourceImpl implements AuthLocalDatasource {
  static const _keyHash = 'password_hash';
  static const _keyIsSet = 'is_password_set';

  @override
  Future<bool> isPasswordSet() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsSet) ?? false;
  }

  @override
  Future<String?> getPasswordHash() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyHash);
  }

  @override
  Future<void> savePasswordHash(String hash) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyHash, hash);
    await prefs.setBool(_keyIsSet, true);
  }
}
