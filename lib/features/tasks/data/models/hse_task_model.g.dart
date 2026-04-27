// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hse_task_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HseTaskModelImpl _$$HseTaskModelImplFromJson(Map<String, dynamic> json) =>
    _$HseTaskModelImpl(
      id: (json['id'] as num).toInt(),
      code: json['code'] as String,
      userId: (json['userId'] as num).toInt(),
      areaId: (json['areaId'] as num).toInt(),
      name: json['name'] as String?,
      riskLevel: json['riskLevel'] as String,
      rootCause: json['rootCause'] as String,
      notes: json['notes'] as String,
      status: json['status'] as String,
      toDepartment: (json['toDepartment'] as num?)?.toInt() ?? 0,
      picToken: json['picToken'] as String?,
      photos: (json['photos'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      followUps: (json['followUps'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const [],
      date: json['date'] as String?,
      userName: json['userName'] as String?,
      cancelledBy: json['cancelledBy'] as String?,
      cancelledAt: json['cancelledAt'] as String?,
    );

Map<String, dynamic> _$$HseTaskModelImplToJson(_$HseTaskModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'userId': instance.userId,
      'areaId': instance.areaId,
      'name': instance.name,
      'riskLevel': instance.riskLevel,
      'rootCause': instance.rootCause,
      'notes': instance.notes,
      'status': instance.status,
      'toDepartment': instance.toDepartment,
      'picToken': instance.picToken,
      'photos': instance.photos,
      'followUps': instance.followUps,
      'date': instance.date,
      'userName': instance.userName,
      'cancelledBy': instance.cancelledBy,
      'cancelledAt': instance.cancelledAt,
    };
