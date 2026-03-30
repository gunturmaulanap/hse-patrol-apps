import '../../../../core/network/dio_client.dart';
import '../../../../shared/enums/user_role.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponse> login(LoginRequest request);
  Future<void> logout();
  Future<UserModel> getMe();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<LoginResponse> login(LoginRequest request) async {
    // === MOCK API IMPLEMENTATION ===
    await Future.delayed(const Duration(seconds: 1)); // Simulate network latency

    final uname = request.emailOrUsername.trim().toLowerCase();
    
    if ((uname == 'pic' || uname == 'pic@aksamala.com') && request.password == 'password') {
      return const LoginResponse(
        token: 'mock-pic-token',
        user: UserModel(
          id: 1,
          name: 'Budi PIC',
          email: 'pic@aksamala.com',
          role: UserRole.pic,
          isActive: true,
        ),
      );
    } else if ((uname == 'petugas' || uname == 'petugas@aksamala.com') && request.password == 'password') {
      return const LoginResponse(
        token: 'mock-petugas-token',
        user: UserModel(
          id: 2,
          name: 'Agus Petugas',
          email: 'petugas@aksamala.com',
          role: UserRole.petugasHse,
          isActive: true,
        ),
      );
    }

    throw Exception('Username atau password salah. Coba:\nUsername: pic (atau petugas)\nPassword: password');
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<UserModel> getMe() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const UserModel(
      id: 1,
      name: 'Mock User',
      email: 'mock@aksamala.com',
      role: UserRole.petugasHse,
      isActive: true,
    );
  }
}
