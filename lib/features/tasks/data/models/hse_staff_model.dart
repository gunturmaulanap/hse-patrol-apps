class HseStaffModel {
  final int id;
  final String name;
  final String email;
  final String? avatar;
  final String roleName;

  HseStaffModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    required this.roleName,
  });

  factory HseStaffModel.fromJson(Map<String, dynamic> json) {
    return HseStaffModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      avatar: json['avatar']?.toString(),
      roleName: json['role_name']?.toString() ??
                  json['roleName']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
      'role_name': roleName,
    };
  }
}
