import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_hse_report_request.freezed.dart';
part 'create_hse_report_request.g.dart';

@freezed
class CreateHseReportRequest with _$CreateHseReportRequest {
  const factory CreateHseReportRequest({
    @JsonKey(name: 'area_id') required int areaId,
    @JsonKey(name: 'risk_level') required String riskLevel,
    @JsonKey(name: 'root_cause') required String rootCause,
    required String notes,
  }) = _CreateHseReportRequest;

  factory CreateHseReportRequest.fromJson(Map<String, dynamic> json) => _$CreateHseReportRequestFromJson(json);
}
