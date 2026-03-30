// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_hse_report_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CreateHseReportRequest _$CreateHseReportRequestFromJson(
    Map<String, dynamic> json) {
  return _CreateHseReportRequest.fromJson(json);
}

/// @nodoc
mixin _$CreateHseReportRequest {
  @JsonKey(name: 'area_id')
  int get areaId => throw _privateConstructorUsedError;
  @JsonKey(name: 'risk_level')
  String get riskLevel => throw _privateConstructorUsedError;
  @JsonKey(name: 'root_cause')
  String get rootCause => throw _privateConstructorUsedError;
  String get notes => throw _privateConstructorUsedError;

  /// Serializes this CreateHseReportRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateHseReportRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateHseReportRequestCopyWith<CreateHseReportRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateHseReportRequestCopyWith<$Res> {
  factory $CreateHseReportRequestCopyWith(CreateHseReportRequest value,
          $Res Function(CreateHseReportRequest) then) =
      _$CreateHseReportRequestCopyWithImpl<$Res, CreateHseReportRequest>;
  @useResult
  $Res call(
      {@JsonKey(name: 'area_id') int areaId,
      @JsonKey(name: 'risk_level') String riskLevel,
      @JsonKey(name: 'root_cause') String rootCause,
      String notes});
}

/// @nodoc
class _$CreateHseReportRequestCopyWithImpl<$Res,
        $Val extends CreateHseReportRequest>
    implements $CreateHseReportRequestCopyWith<$Res> {
  _$CreateHseReportRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateHseReportRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? areaId = null,
    Object? riskLevel = null,
    Object? rootCause = null,
    Object? notes = null,
  }) {
    return _then(_value.copyWith(
      areaId: null == areaId
          ? _value.areaId
          : areaId // ignore: cast_nullable_to_non_nullable
              as int,
      riskLevel: null == riskLevel
          ? _value.riskLevel
          : riskLevel // ignore: cast_nullable_to_non_nullable
              as String,
      rootCause: null == rootCause
          ? _value.rootCause
          : rootCause // ignore: cast_nullable_to_non_nullable
              as String,
      notes: null == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CreateHseReportRequestImplCopyWith<$Res>
    implements $CreateHseReportRequestCopyWith<$Res> {
  factory _$$CreateHseReportRequestImplCopyWith(
          _$CreateHseReportRequestImpl value,
          $Res Function(_$CreateHseReportRequestImpl) then) =
      __$$CreateHseReportRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'area_id') int areaId,
      @JsonKey(name: 'risk_level') String riskLevel,
      @JsonKey(name: 'root_cause') String rootCause,
      String notes});
}

/// @nodoc
class __$$CreateHseReportRequestImplCopyWithImpl<$Res>
    extends _$CreateHseReportRequestCopyWithImpl<$Res,
        _$CreateHseReportRequestImpl>
    implements _$$CreateHseReportRequestImplCopyWith<$Res> {
  __$$CreateHseReportRequestImplCopyWithImpl(
      _$CreateHseReportRequestImpl _value,
      $Res Function(_$CreateHseReportRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of CreateHseReportRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? areaId = null,
    Object? riskLevel = null,
    Object? rootCause = null,
    Object? notes = null,
  }) {
    return _then(_$CreateHseReportRequestImpl(
      areaId: null == areaId
          ? _value.areaId
          : areaId // ignore: cast_nullable_to_non_nullable
              as int,
      riskLevel: null == riskLevel
          ? _value.riskLevel
          : riskLevel // ignore: cast_nullable_to_non_nullable
              as String,
      rootCause: null == rootCause
          ? _value.rootCause
          : rootCause // ignore: cast_nullable_to_non_nullable
              as String,
      notes: null == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateHseReportRequestImpl implements _CreateHseReportRequest {
  const _$CreateHseReportRequestImpl(
      {@JsonKey(name: 'area_id') required this.areaId,
      @JsonKey(name: 'risk_level') required this.riskLevel,
      @JsonKey(name: 'root_cause') required this.rootCause,
      required this.notes});

  factory _$CreateHseReportRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateHseReportRequestImplFromJson(json);

  @override
  @JsonKey(name: 'area_id')
  final int areaId;
  @override
  @JsonKey(name: 'risk_level')
  final String riskLevel;
  @override
  @JsonKey(name: 'root_cause')
  final String rootCause;
  @override
  final String notes;

  @override
  String toString() {
    return 'CreateHseReportRequest(areaId: $areaId, riskLevel: $riskLevel, rootCause: $rootCause, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateHseReportRequestImpl &&
            (identical(other.areaId, areaId) || other.areaId == areaId) &&
            (identical(other.riskLevel, riskLevel) ||
                other.riskLevel == riskLevel) &&
            (identical(other.rootCause, rootCause) ||
                other.rootCause == rootCause) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, areaId, riskLevel, rootCause, notes);

  /// Create a copy of CreateHseReportRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateHseReportRequestImplCopyWith<_$CreateHseReportRequestImpl>
      get copyWith => __$$CreateHseReportRequestImplCopyWithImpl<
          _$CreateHseReportRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateHseReportRequestImplToJson(
      this,
    );
  }
}

abstract class _CreateHseReportRequest implements CreateHseReportRequest {
  const factory _CreateHseReportRequest(
      {@JsonKey(name: 'area_id') required final int areaId,
      @JsonKey(name: 'risk_level') required final String riskLevel,
      @JsonKey(name: 'root_cause') required final String rootCause,
      required final String notes}) = _$CreateHseReportRequestImpl;

  factory _CreateHseReportRequest.fromJson(Map<String, dynamic> json) =
      _$CreateHseReportRequestImpl.fromJson;

  @override
  @JsonKey(name: 'area_id')
  int get areaId;
  @override
  @JsonKey(name: 'risk_level')
  String get riskLevel;
  @override
  @JsonKey(name: 'root_cause')
  String get rootCause;
  @override
  String get notes;

  /// Create a copy of CreateHseReportRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateHseReportRequestImplCopyWith<_$CreateHseReportRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}
