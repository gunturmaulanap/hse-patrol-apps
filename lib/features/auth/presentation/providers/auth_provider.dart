import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/session_manager.dart';
import '../../data/datasource/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';

final sessionManagerProvider = Provider<SessionManager>((ref) {
  return const SessionManager();
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remote = ref.read(authRemoteDataSourceProvider);
  final session = ref.read(sessionManagerProvider);
  return AuthRepositoryImpl(remote, session);
});

class AuthState {
  final bool isLoading;
  final String? error;
  
  AuthState({this.isLoading = false, this.error});
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(AuthState());

  Future<bool> login(String username, String password) async {
    state = AuthState(isLoading: true);
    try {
      await _repository.login(username, password);
      state = AuthState(isLoading: false);
      return true;
    } catch (e) {
      state = AuthState(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    state = AuthState(isLoading: true);
    await _repository.logout();
    state = AuthState(isLoading: false);
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return AuthNotifier(repository);
});
