// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'follow_up_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FollowUpModelImpl _$$FollowUpModelImplFromJson(Map<String, dynamic> json) =>
    _$FollowUpModelImpl(
      id: (json['id'] as num).toInt(),
      reportId: (json['report_id'] as num).toInt(),
      action: json['action'] as String,
      notesPic: json['notes_pic'] as String?,
      notesHse: json['notes_hse'] as String?,
      photos: (json['photos'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      status: json['status'] as String?,
      date: json['date'] as String?,
    );

Map<String, dynamic> _$$FollowUpModelImplToJson(_$FollowUpModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'report_id': instance.reportId,
      'action': instance.action,
      'notes_pic': instance.notesPic,
      'notes_hse': instance.notesHse,
      'photos': instance.photos,
      'status': instance.status,
      'date': instance.date,
    };
