import 'package:freezed_annotation/freezed_annotation.dart';

part 'hse_task_model.freezed.dart';
part 'hse_task_model.g.dart';

@freezed
class HseTaskModel with _$HseTaskModel {
  const factory HseTaskModel({
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
    @Default([]) List<String> photos,
    @Default([]) List<Map<String, dynamic>> followUps,
    String? date,
    String? userName,
    @JsonKey(name: 'cancelled_by') String? cancelledBy,
    @JsonKey(name: 'cancelled_at') String? cancelledAt,
  }) = _HseTaskModel;

  factory HseTaskModel.fromJson(Map<String, dynamic> json) => _$HseTaskModelFromJson(json);
}
