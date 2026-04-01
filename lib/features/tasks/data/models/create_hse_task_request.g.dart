// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_hse_task_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CreateHseTaskRequestImpl _$$CreateHseTaskRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$CreateHseTaskRequestImpl(
      title: json['title'] as String,
      areaId: (json['area_id'] as num).toInt(),
      riskLevel: json['risk_level'] as String,
      rootCause: json['root_cause'] as String,
      notes: json['notes'] as String,
    );

Map<String, dynamic> _$$CreateHseTaskRequestImplToJson(
        _$CreateHseTaskRequestImpl instance) =>
    <String, dynamic>{
      'title': instance.title,
      'area_id': instance.areaId,
      'risk_level': instance.riskLevel,
      'root_cause': instance.rootCause,
      'notes': instance.notes,
    };
