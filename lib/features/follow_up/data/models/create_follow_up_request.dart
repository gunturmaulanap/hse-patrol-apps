import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_follow_up_request.freezed.dart';
part 'create_follow_up_request.g.dart';

@freezed
class CreateFollowUpRequest with _$CreateFollowUpRequest {
  const factory CreateFollowUpRequest({
    required String action,
    @JsonKey(name: 'notes_pic') required String notesPic,
    @JsonKey(name: 'notes_hse') String? notesHse,
  }) = _CreateFollowUpRequest;

  factory CreateFollowUpRequest.fromJson(Map<String, dynamic> json) => _$CreateFollowUpRequestFromJson(json);
}
