import 'package:freezed_annotation/freezed_annotation.dart';

part 'area_model.freezed.dart';
part 'area_model.g.dart';

@freezed
class AreaModel with _$AreaModel {
  const factory AreaModel({
    required int id,
    required String code,
    required String name,
    @JsonKey(name: 'building_type') required String buildingType,
  }) = _AreaModel;

  factory AreaModel.fromJson(Map<String, dynamic> json) => _$AreaModelFromJson(json);
}
