import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_hse_task_request.freezed.dart';
part 'create_hse_task_request.g.dart';

@freezed
class CreateHseTaskRequest with _$CreateHseTaskRequest {
  const factory CreateHseTaskRequest({
    required String title,
    @JsonKey(name: 'area_id') required int areaId,
    @JsonKey(name: 'risk_level') required String riskLevel,
    @JsonKey(name: 'root_cause') required String rootCause,
    required String notes,
  }) = _CreateHseTaskRequest;

  factory CreateHseTaskRequest.fromJson(Map<String, dynamic> json) => _$CreateHseTaskRequestFromJson(json);
}
