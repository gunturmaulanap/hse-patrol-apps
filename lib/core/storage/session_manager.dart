import 'secure_storage_service.dart';

class SessionManager {
  const SessionManager();

  Future<void> saveToken(String token) async {
    await SecureStorageService.instance.write(
      key: SecureStorageService.accessTokenKey,
      value: token,
    );
  }

  Future<String?> getToken() async {
    return SecureStorageService.instance.read(
      key: SecureStorageService.accessTokenKey,
    );
  }

  Future<void> clearToken() async {
    await SecureStorageService.instance.delete(
      key: SecureStorageService.accessTokenKey,
    );
  }

  Future<void> saveRole(String role) async {
    await SecureStorageService.instance.write(
      key: SecureStorageService.userRoleKey,
      value: role,
    );
  }

  Future<String?> getRole() async {
    return SecureStorageService.instance.read(
      key: SecureStorageService.userRoleKey,
    );
  }

  Future<void> clearRole() async {
    await SecureStorageService.instance.delete(
      key: SecureStorageService.userRoleKey,
    );
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}