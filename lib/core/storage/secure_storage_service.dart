import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  SecureStorageService._();

  static const FlutterSecureStorage instance = FlutterSecureStorage();

  static const String accessTokenKey = 'access_token';
  static const String userRoleKey = 'user_role';
}