import 'package:freezed_annotation/freezed_annotation.dart';

part 'hse_task_model.freezed.dart';
part 'hse_task_model.g.dart';

@freezed
class HseTaskModel with _$HseTaskModel {
  const factory HseTaskModel({
    required int id,
    required String code,
    required int userId,
    required int areaId,
    String? name,
    required String riskLevel,
    required String rootCause,
    required String notes,
    required String status,
    @Default(0) int toDepartment,
    String? picToken,
    @Default([]) List<String> photos,
    @Default([]) List<Map<String, dynamic>> followUps,
    String? date,
    String? userName,
    String? cancelledBy,
    String? cancelledAt,
  }) = _HseTaskModel;

  factory HseTaskModel.fromJson(Map<String, dynamic> json) => _$HseTaskModelFromJson(json);
}
