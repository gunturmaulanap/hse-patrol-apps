import '../../domain/repositories/auth_repository.dart';
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
    final response = await _remoteDataSource.login(
      LoginRequest(emailOrUsername: emailOrUsername, password: password),
    );
    await _sessionManager.saveToken(response.token);
    await _sessionManager.saveRole(response.user.role.name);
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
    return _remoteDataSource.getMe();
  }
}
