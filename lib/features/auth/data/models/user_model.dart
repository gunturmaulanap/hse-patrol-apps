import '../../../../shared/enums/user_role.dart';

class UserModel {
  final int id;
  final String name;
  final String email;
  final int roleId;
  final String roleName;
  final UserRole role;
  final String? phone;
  final bool isActive;
  final List<String> areaAccess;

  const UserModel({
    this.id = 0,
    this.name = '',
    this.email = '',
    this.roleId = 0,
    this.roleName = '',
    this.role = UserRole.petugasHse,
    this.phone,
    this.isActive = true,
    this.areaAccess = const <String>[],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel.fromBackendJson(json);
  }

  factory UserModel.fromBackendJson(Map<String, dynamic> json) {
    final map = Map<String, dynamic>.from(json);

    return UserModel(
      id: _toInt(map['id']),
      name: _toSafeString(map['name']),
      email: _toSafeString(map['email']),
      roleId: _toInt(map['role_id'] ?? map['roleId']),
      roleName: _toSafeString(map['role_name'] ?? map['roleName']),
      role: _parseUserRole(
        roleName: map['role_name']?.toString() ?? map['roleName']?.toString(),
        roleRaw: map['role']?.toString(),
        roleId: _toInt(map['role_id'] ?? map['roleId']),
      ),
      phone: _toNullableString(map['phone']),
      isActive: _toBool(
        map['is_active'] ?? map['isActive'],
        defaultValue: true,
      ),
      areaAccess: _toStringList(
        map['area_access'] ?? map['areaAccess'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
      'role_id': roleId,
      'role_name': roleName,
      'role': role.name,
      'phone': phone,
      'is_active': isActive,
      'area_access': areaAccess,
    };
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    int? roleId,
    String? roleName,
    UserRole? role,
    String? phone,
    bool? isActive,
    List<String>? areaAccess,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      roleId: roleId ?? this.roleId,
      roleName: roleName ?? this.roleName,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      isActive: isActive ?? this.isActive,
      areaAccess: areaAccess ?? this.areaAccess,
    );
  }
}

UserRole _parseUserRole({
  String? roleName,
  String? roleRaw,
  int? roleId,
}) {
  if (roleId == 12) {
    return UserRole.pic;
  }

  if (roleId == 22) {
    return UserRole.petugasHse;
  }

  final source = (roleName != null && roleName.trim().isNotEmpty)
      ? roleName
      : roleRaw;

  if (source == null) return UserRole.petugasHse;

  final normalized = source.toLowerCase().trim();

  if (normalized == 'pic_area') {
    return UserRole.pic;
  }

  if (normalized == 'hse_staff') {
    return UserRole.petugasHse;
  }

  if (normalized == 'hse_supervisor') {
    return UserRole.hseSupervisor;
  }

  if (normalized == 'pic area') {
    return UserRole.pic;
  }

  if (normalized == 'hse supervisor') {
    return UserRole.hseSupervisor;
  }

  if (normalized == 'hse') {
    return UserRole.petugasHse;
  }

  if (normalized == 'pic' || normalized.contains('pic')) {
    return UserRole.pic;
  }

  if (normalized.contains('petugas') || normalized.contains('hse')) {
    if (normalized.contains('supervisor')) {
      return UserRole.hseSupervisor;
    }

    return UserRole.petugasHse;
  }

  return UserRole.petugasHse;
}

int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? 0;
}

String _toSafeString(dynamic value) {
  if (value == null) return '';
  return value.toString();
}

String? _toNullableString(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

bool _toBool(dynamic value, {bool defaultValue = false}) {
  if (value == null) return defaultValue;
  if (value is bool) return value;
  if (value is num) return value == 1;

  final normalized = value.toString().trim().toLowerCase();

  if (normalized == 'true' ||
      normalized == '1' ||
      normalized == 'yes' ||
      normalized == 'y' ||
      normalized == 'active') {
    return true;
  }

  if (normalized == 'false' ||
      normalized == '0' ||
      normalized == 'no' ||
      normalized == 'n' ||
      normalized == 'inactive') {
    return false;
  }

  return defaultValue;
}

List<String> _toStringList(dynamic value) {
  if (value is List) {
    return value
        .where((item) => item != null)
        .map((item) => item.toString())
        .toList();
  }

  return <String>[];
}
