// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'area_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AreaModelImpl _$$AreaModelImplFromJson(Map<String, dynamic> json) =>
    _$AreaModelImpl(
      id: (json['id'] as num).toInt(),
      code: json['code'] as String,
      name: json['name'] as String,
      buildingType: json['building_type'] as String,
    );

Map<String, dynamic> _$$AreaModelImplToJson(_$AreaModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
      'building_type': instance.buildingType,
    };
