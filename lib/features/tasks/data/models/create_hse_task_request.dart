import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_hse_task_request.freezed.dart';
part 'create_hse_task_request.g.dart';

@freezed
class CreateHseTaskRequest with _$CreateHseTaskRequest {
  const factory CreateHseTaskRequest({
    required String title,
    required int areaId,
    required String riskLevel,
    required String rootCause,
    required String notes,
    @Default(0) int toDepartment,
  }) = _CreateHseTaskRequest;

  factory CreateHseTaskRequest.fromJson(Map<String, dynamic> json) => _$CreateHseTaskRequestFromJson(json);
}
