import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecureStorageService {
  SecureStorageService._();

  static SecureStorageService? _instance;
  static SecureStorageService get instance => _instance ??= SecureStorageService._();

  // Use FlutterSecureStorage for mobile, SharedPreferences for web
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static SharedPreferences? _preferences;

  static Future<void> init() async {
    if (kIsWeb && _preferences == null) {
      _preferences = await SharedPreferences.getInstance();
    }
  }

  Future<SharedPreferences> _getPreferences() async {
    if (_preferences != null) return _preferences!;
    _preferences = await SharedPreferences.getInstance();
    return _preferences!;
  }

  static const String accessTokenKey = 'access_token';
  static const String userRoleKey = 'user_role';

  Future<void> write({required String key, required String value}) async {
    if (kIsWeb) {
      final prefs = await _getPreferences();
      await prefs.setString(key, value);
    } else {
      await _secureStorage.write(key: key, value: value);
    }
  }

  Future<String?> read({required String key}) async {
    if (kIsWeb) {
      final prefs = await _getPreferences();
      return prefs.getString(key);
    } else {
      return await _secureStorage.read(key: key);
    }
  }

  Future<void> delete({required String key}) async {
    if (kIsWeb) {
      final prefs = await _getPreferences();
      await prefs.remove(key);
    } else {
      await _secureStorage.delete(key: key);
    }
  }
}
