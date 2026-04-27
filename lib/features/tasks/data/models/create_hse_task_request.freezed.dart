// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_hse_task_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CreateHseTaskRequest _$CreateHseTaskRequestFromJson(Map<String, dynamic> json) {
  return _CreateHseTaskRequest.fromJson(json);
}

/// @nodoc
mixin _$CreateHseTaskRequest {
  String get title => throw _privateConstructorUsedError;
  int get areaId => throw _privateConstructorUsedError;
  String get riskLevel => throw _privateConstructorUsedError;
  String get rootCause => throw _privateConstructorUsedError;
  String get notes => throw _privateConstructorUsedError;
  int get toDepartment => throw _privateConstructorUsedError;

  /// Serializes this CreateHseTaskRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateHseTaskRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateHseTaskRequestCopyWith<CreateHseTaskRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateHseTaskRequestCopyWith<$Res> {
  factory $CreateHseTaskRequestCopyWith(CreateHseTaskRequest value,
          $Res Function(CreateHseTaskRequest) then) =
      _$CreateHseTaskRequestCopyWithImpl<$Res, CreateHseTaskRequest>;
  @useResult
  $Res call(
      {String title,
      int areaId,
      String riskLevel,
      String rootCause,
      String notes,
      int toDepartment});
}

/// @nodoc
class _$CreateHseTaskRequestCopyWithImpl<$Res,
        $Val extends CreateHseTaskRequest>
    implements $CreateHseTaskRequestCopyWith<$Res> {
  _$CreateHseTaskRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateHseTaskRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? areaId = null,
    Object? riskLevel = null,
    Object? rootCause = null,
    Object? notes = null,
    Object? toDepartment = null,
  }) {
    return _then(_value.copyWith(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
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
      toDepartment: null == toDepartment
          ? _value.toDepartment
          : toDepartment // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CreateHseTaskRequestImplCopyWith<$Res>
    implements $CreateHseTaskRequestCopyWith<$Res> {
  factory _$$CreateHseTaskRequestImplCopyWith(_$CreateHseTaskRequestImpl value,
          $Res Function(_$CreateHseTaskRequestImpl) then) =
      __$$CreateHseTaskRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String title,
      int areaId,
      String riskLevel,
      String rootCause,
      String notes,
      int toDepartment});
}

/// @nodoc
class __$$CreateHseTaskRequestImplCopyWithImpl<$Res>
    extends _$CreateHseTaskRequestCopyWithImpl<$Res, _$CreateHseTaskRequestImpl>
    implements _$$CreateHseTaskRequestImplCopyWith<$Res> {
  __$$CreateHseTaskRequestImplCopyWithImpl(_$CreateHseTaskRequestImpl _value,
      $Res Function(_$CreateHseTaskRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of CreateHseTaskRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? areaId = null,
    Object? riskLevel = null,
    Object? rootCause = null,
    Object? notes = null,
    Object? toDepartment = null,
  }) {
    return _then(_$CreateHseTaskRequestImpl(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
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
      toDepartment: null == toDepartment
          ? _value.toDepartment
          : toDepartment // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateHseTaskRequestImpl implements _CreateHseTaskRequest {
  const _$CreateHseTaskRequestImpl(
      {required this.title,
      required this.areaId,
      required this.riskLevel,
      required this.rootCause,
      required this.notes,
      this.toDepartment = 0});

  factory _$CreateHseTaskRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateHseTaskRequestImplFromJson(json);

  @override
  final String title;
  @override
  final int areaId;
  @override
  final String riskLevel;
  @override
  final String rootCause;
  @override
  final String notes;
  @override
  @JsonKey()
  final int toDepartment;

  @override
  String toString() {
    return 'CreateHseTaskRequest(title: $title, areaId: $areaId, riskLevel: $riskLevel, rootCause: $rootCause, notes: $notes, toDepartment: $toDepartment)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateHseTaskRequestImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.areaId, areaId) || other.areaId == areaId) &&
            (identical(other.riskLevel, riskLevel) ||
                other.riskLevel == riskLevel) &&
            (identical(other.rootCause, rootCause) ||
                other.rootCause == rootCause) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.toDepartment, toDepartment) ||
                other.toDepartment == toDepartment));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, title, areaId, riskLevel, rootCause, notes, toDepartment);

  /// Create a copy of CreateHseTaskRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateHseTaskRequestImplCopyWith<_$CreateHseTaskRequestImpl>
      get copyWith =>
          __$$CreateHseTaskRequestImplCopyWithImpl<_$CreateHseTaskRequestImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateHseTaskRequestImplToJson(
      this,
    );
  }
}

abstract class _CreateHseTaskRequest implements CreateHseTaskRequest {
  const factory _CreateHseTaskRequest(
      {required final String title,
      required final int areaId,
      required final String riskLevel,
      required final String rootCause,
      required final String notes,
      final int toDepartment}) = _$CreateHseTaskRequestImpl;

  factory _CreateHseTaskRequest.fromJson(Map<String, dynamic> json) =
      _$CreateHseTaskRequestImpl.fromJson;

  @override
  String get title;
  @override
  int get areaId;
  @override
  String get riskLevel;
  @override
  String get rootCause;
  @override
  String get notes;
  @override
  int get toDepartment;

  /// Create a copy of CreateHseTaskRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateHseTaskRequestImplCopyWith<_$CreateHseTaskRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}
