import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/storage/session_manager.dart';
import '../../data/datasource/auth_remote_datasource.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';

final sessionManagerProvider = Provider<SessionManager>((ref) {
  return SessionManager();
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
  final UserModel? user;

  const AuthState({
    this.isLoading = false,
    this.error,
    this.user,
  });
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState());

  Future<bool> login(String username, String password) async {
    debugPrint('[AuthNotifier] before update auth state -> loading true');
    state = AuthState(isLoading: true, user: state.user);

    try {
      final user = await _repository.login(username, password);

      debugPrint('[AuthNotifier] before update auth state -> login success');
      state = AuthState(isLoading: false, user: user);

      return true;
    } catch (e, st) {
      debugPrint('[AuthNotifier] login error: $e');
      debugPrint('[AuthNotifier] login stacktrace: $st');

      debugPrint('[AuthNotifier] before update auth state -> login failed');
      state = AuthState(isLoading: false, error: e.toString(), user: state.user);

      return false;
    }
  }

  Future<void> logout() async {
    debugPrint('[AuthNotifier] before update auth state -> logout loading true');
    state = AuthState(isLoading: true, user: state.user);

    await _repository.logout();

    debugPrint('[AuthNotifier] before update auth state -> logout success');
    state = const AuthState(isLoading: false, user: null);
  }

  void setHydratedUser(UserModel user) {
    debugPrint('[AuthNotifier] before update auth state -> hydrate user');
    state = AuthState(isLoading: false, user: user);
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return AuthNotifier(repository);
});

// Provider untuk user yang sedang login (replacing currentUserProvider dari mock_database)
final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authNotifierProvider).user;
});
