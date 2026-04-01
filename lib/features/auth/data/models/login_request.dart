class LoginRequest {
  final String emailOrUsername;
  final String password;

  const LoginRequest({
    this.emailOrUsername = '',
    this.password = '',
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) {
    return LoginRequest(
      emailOrUsername: (json['emailOrUsername'] ?? json['email'] ?? '')
          .toString()
          .trim(),
      password: (json['password'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'emailOrUsername': emailOrUsername,
      'password': password,
    };
  }

  LoginRequest copyWith({
    String? emailOrUsername,
    String? password,
  }) {
    return LoginRequest(
      emailOrUsername: emailOrUsername ?? this.emailOrUsername,
      password: password ?? this.password,
    );
  }
}
