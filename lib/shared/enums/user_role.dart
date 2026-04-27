import 'package:json_annotation/json_annotation.dart';

enum UserRole {
  @JsonValue('petugasHse')
  petugasHse,
  @JsonValue('hseSupervisor')
  hseSupervisor,
  @JsonValue('pic')
  pic,
  @JsonValue('picEngineer')
  picEngineer,
  @JsonValue('picHrga')
  picHrga,
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
      case UserRole.picEngineer:
        return 'picEngineer';
      case UserRole.picHrga:
        return 'picHrga';
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
      case 'picEngineer':
        return UserRole.picEngineer;
      case 'picHrga':
        return UserRole.picHrga;
      default:
        return UserRole.petugasHse;
    }
  }
}
