// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_follow_up_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CreateFollowUpRequestImpl _$$CreateFollowUpRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$CreateFollowUpRequestImpl(
      action: json['action'] as String,
      notesPic: json['notes_pic'] as String,
      notesHse: json['notes_hse'] as String?,
    );

Map<String, dynamic> _$$CreateFollowUpRequestImplToJson(
        _$CreateFollowUpRequestImpl instance) =>
    <String, dynamic>{
      'action': instance.action,
      'notes_pic': instance.notesPic,
      'notes_hse': instance.notesHse,
    };
