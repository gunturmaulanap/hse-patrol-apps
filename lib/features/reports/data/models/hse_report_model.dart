import 'package:freezed_annotation/freezed_annotation.dart';

part 'hse_report_model.freezed.dart';
part 'hse_report_model.g.dart';

@freezed
class HseReportModel with _$HseReportModel {
  const factory HseReportModel({
    required int id,
    required String code,
    @JsonKey(name: 'user_id') required int userId,
    @JsonKey(name: 'area_id') required int areaId,
    String? name,
    @JsonKey(name: 'risk_level') required String riskLevel,
    @JsonKey(name: 'root_cause') required String rootCause,
    required String notes,
    required String status,
    @JsonKey(name: 'pic_token') String? picToken,
  }) = _HseReportModel;

  factory HseReportModel.fromJson(Map<String, dynamic> json) => _$HseReportModelFromJson(json);
}
