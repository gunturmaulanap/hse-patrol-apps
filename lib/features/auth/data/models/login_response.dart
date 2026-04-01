import 'user_model.dart';

class LoginResponse {
  final String token;
  final UserModel user;

  const LoginResponse({
    this.token = '',
    this.user = const UserModel(),
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final normalized = _normalizeLoginJson(json);

    return LoginResponse(
      token: normalized['token']?.toString() ?? '',
      user: normalized['user'] is Map
          ? UserModel.fromBackendJson(
              Map<String, dynamic>.from(normalized['user'] as Map),
            )
          : const UserModel(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'token': token,
      'user': user.toJson(),
    };
  }

  LoginResponse copyWith({
    String? token,
    UserModel? user,
  }) {
    return LoginResponse(
      token: token ?? this.token,
      user: user ?? this.user,
    );
  }
}

Map<String, dynamic> _normalizeLoginJson(Map<String, dynamic> json) {
  final root = Map<String, dynamic>.from(json);

  final payload = root['data'] is Map
      ? Map<String, dynamic>.from(root['data'] as Map)
      : root;

  return <String, dynamic>{
    'token': payload['token'] ??
        payload['access_token'] ??
        root['token'] ??
        root['access_token'],
    'user': payload['user'] ?? root['user'],
  };
}