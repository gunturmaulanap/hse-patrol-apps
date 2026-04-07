import '../../domain/repositories/auth_repository.dart';
import 'package:flutter/foundation.dart';
import '../datasource/auth_remote_datasource.dart';
import '../models/login_request.dart';
import '../models/user_model.dart';
import '../../../../core/storage/session_manager.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final SessionManager _sessionManager;

  AuthRepositoryImpl(this._remoteDataSource, this._sessionManager);

  @override
  Future<UserModel> login(String emailOrUsername, String password) async {
    debugPrint('[AuthRepository] login() start for: ${emailOrUsername.trim()}');

    final response = await _remoteDataSource.login(
      LoginRequest(emailOrUsername: emailOrUsername, password: password),
    );

    debugPrint('[AuthRepository] parsed login response: ${response.toJson()}');
    debugPrint('[AuthRepository] Token from response: ${response.token.substring(0, 20)}...${response.token.length > 20 ? '' : response.token} (length: ${response.token.length})');
    debugPrint('[AuthRepository] before save token');
    await _sessionManager.saveToken(response.token);

    debugPrint('[AuthRepository] before save role: ${response.user.role.name}');
    await _sessionManager.saveRole(response.user.role.name);

    // Verify token was saved correctly
    final savedToken = await _sessionManager.getToken();
    debugPrint('[AuthRepository] Token after save: ${savedToken != null ? 'SAVED (length: ${savedToken.length})' : 'NOT SAVED'}');
    if (savedToken != null && savedToken.isNotEmpty) {
      debugPrint('[AuthRepository] Token verification: ${savedToken.substring(0, 20)}...${savedToken.length > 20 ? '' : savedToken}');
    }

    return response.user;
  }

  @override
  Future<void> logout() async {
    try {
      await _remoteDataSource.logout();
    } catch (_) {
      // Ignore logout errors network-side
    } finally {
      await _sessionManager.clearToken();
      await _sessionManager.clearRole();
    }
  }

  @override
  Future<UserModel> getMe() async {
    debugPrint('[AuthRepository] before call getMe()');
    return _remoteDataSource.getMe();
  }

  @override
  Future<String> changePassword(
    String currentPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    debugPrint('[AuthRepository] changePassword() start');

    return _remoteDataSource.changePassword(
      currentPassword: currentPassword,
      password: newPassword,
      passwordConfirmation: confirmPassword,
    );
  }
}
