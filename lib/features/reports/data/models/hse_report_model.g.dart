// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hse_report_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HseReportModelImpl _$$HseReportModelImplFromJson(Map<String, dynamic> json) =>
    _$HseReportModelImpl(
      id: (json['id'] as num).toInt(),
      code: json['code'] as String,
      userId: (json['user_id'] as num).toInt(),
      areaId: (json['area_id'] as num).toInt(),
      name: json['name'] as String?,
      riskLevel: json['risk_level'] as String,
      rootCause: json['root_cause'] as String,
      notes: json['notes'] as String,
      status: json['status'] as String,
      picToken: json['pic_token'] as String?,
    );

Map<String, dynamic> _$$HseReportModelImplToJson(
        _$HseReportModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'user_id': instance.userId,
      'area_id': instance.areaId,
      'name': instance.name,
      'risk_level': instance.riskLevel,
      'root_cause': instance.rootCause,
      'notes': instance.notes,
      'status': instance.status,
      'pic_token': instance.picToken,
    };
