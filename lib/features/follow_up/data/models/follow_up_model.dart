import 'package:freezed_annotation/freezed_annotation.dart';

part 'follow_up_model.freezed.dart';
part 'follow_up_model.g.dart';

@freezed
class FollowUpModel with _$FollowUpModel {
  const factory FollowUpModel({
    required int id,
    @JsonKey(name: 'report_id') required int reportId,
    required String action,
    @JsonKey(name: 'notes_pic') String? notesPic,
    @JsonKey(name: 'notes_hse') String? notesHse,
    @Default([]) List<String> photos,
    String? status,
    String? date,
  }) = _FollowUpModel;

  factory FollowUpModel.fromJson(Map<String, dynamic> json) => _$FollowUpModelFromJson(json);
}
