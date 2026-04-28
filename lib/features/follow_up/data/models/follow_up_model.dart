// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'follow_up_model.freezed.dart';
part 'follow_up_model.g.dart';

@freezed
class FollowUpModel with _$FollowUpModel {
  const factory FollowUpModel({
    required int id,
    required int reportId,
    required String action,
    String? notesPic,
    String? notesHse,
    @Default([]) List<String> photos,
    String? status,
    String? date,
  }) = _FollowUpModel;

  factory FollowUpModel.fromJson(Map<String, dynamic> json) => _$FollowUpModelFromJson(json);
}
