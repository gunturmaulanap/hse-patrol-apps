// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_hse_task_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CreateHseTaskRequestImpl _$$CreateHseTaskRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$CreateHseTaskRequestImpl(
      title: json['title'] as String,
      areaId: (json['areaId'] as num).toInt(),
      riskLevel: json['riskLevel'] as String,
      rootCause: json['rootCause'] as String,
      notes: json['notes'] as String,
      toDepartment: (json['toDepartment'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$CreateHseTaskRequestImplToJson(
        _$CreateHseTaskRequestImpl instance) =>
    <String, dynamic>{
      'title': instance.title,
      'areaId': instance.areaId,
      'riskLevel': instance.riskLevel,
      'rootCause': instance.rootCause,
      'notes': instance.notes,
      'toDepartment': instance.toDepartment,
    };
