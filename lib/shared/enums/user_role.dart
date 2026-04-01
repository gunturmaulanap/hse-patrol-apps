import 'package:json_annotation/json_annotation.dart';

enum UserRole {
  @JsonValue('petugasHse')
  petugasHse,
  @JsonValue('hseSupervisor')
  hseSupervisor,
  @JsonValue('pic')
  pic,
}

extension UserRoleX on UserRole {
  String toJson() {
    switch (this) {
      case UserRole.petugasHse:
        return 'petugasHse';
      case UserRole.hseSupervisor:
        return 'hseSupervisor';
      case UserRole.pic:
        return 'pic';
    }
  }

  static UserRole fromJson(String value) {
    switch (value) {
      case 'petugasHse':
        return UserRole.petugasHse;
      case 'hseSupervisor':
        return UserRole.hseSupervisor;
      case 'pic':
        return UserRole.pic;
      default:
        return UserRole.petugasHse;
    }
  }
}
