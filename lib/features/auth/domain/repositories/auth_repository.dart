import '../../data/models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel> login(String emailOrUsername, String password);
  Future<void> logout();
  Future<UserModel> getMe();
  Future<String> changePassword(
    String currentPassword,
    String newPassword,
    String confirmPassword,
  );
}
