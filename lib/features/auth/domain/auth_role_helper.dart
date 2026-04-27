import 'package:flutter/foundation.dart';

import '../../../app/router/route_names.dart';
import '../../../shared/enums/user_role.dart';

abstract final class AuthRoleIds {
  static const int pic = 5;
  static const int picEngineer = 24;
  static const int picHrga = 25;
  static const int petugas = 22;
  static const int supervisor = 23;
}

UserRole resolveUserRoleFromBackend({
  required int roleId,
  String? roleName,
  String? roleRaw,
}) {
  final resolved = switch (roleId) {
    AuthRoleIds.pic => UserRole.pic,
    AuthRoleIds.picEngineer => UserRole.picEngineer,
    AuthRoleIds.picHrga => UserRole.picHrga,
    AuthRoleIds.petugas => UserRole.petugasHse,
    AuthRoleIds.supervisor => UserRole.hseSupervisor,
    _ => UserRole.petugasHse,
  };

  final roleSource = roleName?.trim().isNotEmpty == true
      ? roleName!.trim()
      : roleRaw?.trim();

  debugPrint(
    '[AuthRoleHelper] resolveUserRoleFromBackend roleId=$roleId roleSource=${roleSource ?? '-'} -> ${resolved.name}',
  );

  return resolved;
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

