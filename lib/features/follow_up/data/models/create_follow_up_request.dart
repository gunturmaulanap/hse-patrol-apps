// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_follow_up_request.freezed.dart';
part 'create_follow_up_request.g.dart';

@freezed
class CreateFollowUpRequest with _$CreateFollowUpRequest {
  const factory CreateFollowUpRequest({
    required String action,
    required String notesPic,
    String? notesHse,
  }) = _CreateFollowUpRequest;

  factory CreateFollowUpRequest.fromJson(Map<String, dynamic> json) => _$CreateFollowUpRequestFromJson(json);
}
