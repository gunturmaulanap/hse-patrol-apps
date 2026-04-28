import 'package:flutter/foundation.dart';

import '../../../app/router/route_names.dart';
import '../../../shared/enums/user_role.dart';

UserRole resolveUserRoleFromBackend({
  String? roleName,
  String? roleRaw,
}) {
  final roleSource = roleName?.trim().isNotEmpty == true
      ? roleName!.trim()
      : roleRaw?.trim();

  final normalizedRoleName = _normalizeRoleName(roleSource);

  final resolved = switch (normalizedRoleName) {
    'picarea' => UserRole.pic,
    'engineer' => UserRole.picEngineer,
    'hrga' => UserRole.picHrga,
    'hsestaff' => UserRole.petugasHse,
    'hsesupervisor' => UserRole.hseSupervisor,
    _ => UserRole.petugasHse,
  };

  debugPrint(
    '[AuthRoleHelper] resolveUserRoleFromBackend roleName=${roleSource ?? '-'} normalized=$normalizedRoleName -> ${resolved.name}',
  );

  return resolved;
}

String normalizeBackendRoleName(String? roleName) {
  return _normalizeRoleName(roleName);
}

bool isEngineerRoleName(String? roleName) {
  return _normalizeRoleName(roleName) == 'engineer';
}

bool isHrgaRoleName(String? roleName) {
  return _normalizeRoleName(roleName) == 'hrga';
}

String _normalizeRoleName(String? roleName) {
  return (roleName ?? '')
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]'), '');
}

String resolveHomeRouteName(UserRole role) {
  return switch (role) {
    UserRole.pic => RouteNames.picHome,
    UserRole.picEngineer => RouteNames.picHome,
    UserRole.picHrga => RouteNames.picHome,
    UserRole.hseSupervisor => RouteNames.supervisorHome,
    UserRole.petugasHse => RouteNames.petugasHome,
  };
}

bool isPicScopedRole(UserRole role) {
  return role == UserRole.pic ||
      role == UserRole.picEngineer ||
      role == UserRole.picHrga;
}

bool isPicEngineerRole(UserRole role) {
  return role == UserRole.picEngineer;
}

bool isPicHrgaRole(UserRole role) {
  return role == UserRole.picHrga;
}


