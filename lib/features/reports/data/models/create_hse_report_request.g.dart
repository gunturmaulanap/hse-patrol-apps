// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_hse_report_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CreateHseReportRequestImpl _$$CreateHseReportRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$CreateHseReportRequestImpl(
      areaId: (json['area_id'] as num).toInt(),
      riskLevel: json['risk_level'] as String,
      rootCause: json['root_cause'] as String,
      notes: json['notes'] as String,
    );

Map<String, dynamic> _$$CreateHseReportRequestImplToJson(
        _$CreateHseReportRequestImpl instance) =>
    <String, dynamic>{
      'area_id': instance.areaId,
      'risk_level': instance.riskLevel,
      'root_cause': instance.rootCause,
      'notes': instance.notes,
    };
