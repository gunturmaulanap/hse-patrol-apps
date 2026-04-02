// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hse_task_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

HseTaskModel _$HseTaskModelFromJson(Map<String, dynamic> json) {
  return _HseTaskModel.fromJson(json);
}

/// @nodoc
mixin _$HseTaskModel {
  int get id => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  int get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'area_id')
  int get areaId => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'risk_level')
  String get riskLevel => throw _privateConstructorUsedError;
  @JsonKey(name: 'root_cause')
  String get rootCause => throw _privateConstructorUsedError;
  String get notes => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'pic_token')
  String? get picToken => throw _privateConstructorUsedError;
  List<String> get photos => throw _privateConstructorUsedError;
  List<Map<String, dynamic>> get followUps =>
      throw _privateConstructorUsedError;
  String? get date => throw _privateConstructorUsedError;
  String? get userName => throw _privateConstructorUsedError;

  /// Serializes this HseTaskModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HseTaskModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HseTaskModelCopyWith<HseTaskModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HseTaskModelCopyWith<$Res> {
  factory $HseTaskModelCopyWith(
          HseTaskModel value, $Res Function(HseTaskModel) then) =
      _$HseTaskModelCopyWithImpl<$Res, HseTaskModel>;
  @useResult
  $Res call(
      {int id,
      String code,
      @JsonKey(name: 'user_id') int userId,
      @JsonKey(name: 'area_id') int areaId,
      String? name,
      @JsonKey(name: 'risk_level') String riskLevel,
      @JsonKey(name: 'root_cause') String rootCause,
      String notes,
      String status,
      @JsonKey(name: 'pic_token') String? picToken,
      List<String> photos,
      List<Map<String, dynamic>> followUps,
      String? date,
      String? userName});
}

/// @nodoc
class _$HseTaskModelCopyWithImpl<$Res, $Val extends HseTaskModel>
    implements $HseTaskModelCopyWith<$Res> {
  _$HseTaskModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HseTaskModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? userId = null,
    Object? areaId = null,
    Object? name = freezed,
    Object? riskLevel = null,
    Object? rootCause = null,
    Object? notes = null,
    Object? status = null,
    Object? picToken = freezed,
    Object? photos = null,
    Object? followUps = null,
    Object? date = freezed,
    Object? userName = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      areaId: null == areaId
          ? _value.areaId
          : areaId // ignore: cast_nullable_to_non_nullable
              as int,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
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
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      picToken: freezed == picToken
          ? _value.picToken
          : picToken // ignore: cast_nullable_to_non_nullable
              as String?,
      photos: null == photos
          ? _value.photos
          : photos // ignore: cast_nullable_to_non_nullable
              as List<String>,
      followUps: null == followUps
          ? _value.followUps
          : followUps // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>,
      date: freezed == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String?,
      userName: freezed == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HseTaskModelImplCopyWith<$Res>
    implements $HseTaskModelCopyWith<$Res> {
  factory _$$HseTaskModelImplCopyWith(
          _$HseTaskModelImpl value, $Res Function(_$HseTaskModelImpl) then) =
      __$$HseTaskModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String code,
      @JsonKey(name: 'user_id') int userId,
      @JsonKey(name: 'area_id') int areaId,
      String? name,
      @JsonKey(name: 'risk_level') String riskLevel,
      @JsonKey(name: 'root_cause') String rootCause,
      String notes,
      String status,
      @JsonKey(name: 'pic_token') String? picToken,
      List<String> photos,
      List<Map<String, dynamic>> followUps,
      String? date,
      String? userName});
}

/// @nodoc
class __$$HseTaskModelImplCopyWithImpl<$Res>
    extends _$HseTaskModelCopyWithImpl<$Res, _$HseTaskModelImpl>
    implements _$$HseTaskModelImplCopyWith<$Res> {
  __$$HseTaskModelImplCopyWithImpl(
      _$HseTaskModelImpl _value, $Res Function(_$HseTaskModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of HseTaskModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? userId = null,
    Object? areaId = null,
    Object? name = freezed,
    Object? riskLevel = null,
    Object? rootCause = null,
    Object? notes = null,
    Object? status = null,
    Object? picToken = freezed,
    Object? photos = null,
    Object? followUps = null,
    Object? date = freezed,
    Object? userName = freezed,
  }) {
    return _then(_$HseTaskModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      areaId: null == areaId
          ? _value.areaId
          : areaId // ignore: cast_nullable_to_non_nullable
              as int,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
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
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      picToken: freezed == picToken
          ? _value.picToken
          : picToken // ignore: cast_nullable_to_non_nullable
              as String?,
      photos: null == photos
          ? _value._photos
          : photos // ignore: cast_nullable_to_non_nullable
              as List<String>,
      followUps: null == followUps
          ? _value._followUps
          : followUps // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>,
      date: freezed == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String?,
      userName: freezed == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HseTaskModelImpl implements _HseTaskModel {
  const _$HseTaskModelImpl(
      {required this.id,
      required this.code,
      @JsonKey(name: 'user_id') required this.userId,
      @JsonKey(name: 'area_id') required this.areaId,
      this.name,
      @JsonKey(name: 'risk_level') required this.riskLevel,
      @JsonKey(name: 'root_cause') required this.rootCause,
      required this.notes,
      required this.status,
      @JsonKey(name: 'pic_token') this.picToken,
      final List<String> photos = const [],
      final List<Map<String, dynamic>> followUps = const [],
      this.date,
      this.userName})
      : _photos = photos,
        _followUps = followUps;

  factory _$HseTaskModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$HseTaskModelImplFromJson(json);

  @override
  final int id;
  @override
  final String code;
  @override
  @JsonKey(name: 'user_id')
  final int userId;
  @override
  @JsonKey(name: 'area_id')
  final int areaId;
  @override
  final String? name;
  @override
  @JsonKey(name: 'risk_level')
  final String riskLevel;
  @override
  @JsonKey(name: 'root_cause')
  final String rootCause;
  @override
  final String notes;
  @override
  final String status;
  @override
  @JsonKey(name: 'pic_token')
  final String? picToken;
  final List<String> _photos;
  @override
  @JsonKey()
  List<String> get photos {
    if (_photos is EqualUnmodifiableListView) return _photos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_photos);
  }

  final List<Map<String, dynamic>> _followUps;
  @override
  @JsonKey()
  List<Map<String, dynamic>> get followUps {
    if (_followUps is EqualUnmodifiableListView) return _followUps;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_followUps);
  }

  @override
  final String? date;
  @override
  final String? userName;

  @override
  String toString() {
    return 'HseTaskModel(id: $id, code: $code, userId: $userId, areaId: $areaId, name: $name, riskLevel: $riskLevel, rootCause: $rootCause, notes: $notes, status: $status, picToken: $picToken, photos: $photos, followUps: $followUps, date: $date, userName: $userName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HseTaskModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.areaId, areaId) || other.areaId == areaId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.riskLevel, riskLevel) ||
                other.riskLevel == riskLevel) &&
            (identical(other.rootCause, rootCause) ||
                other.rootCause == rootCause) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.picToken, picToken) ||
                other.picToken == picToken) &&
            const DeepCollectionEquality().equals(other._photos, _photos) &&
            const DeepCollectionEquality()
                .equals(other._followUps, _followUps) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.userName, userName) ||
                other.userName == userName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      code,
      userId,
      areaId,
      name,
      riskLevel,
      rootCause,
      notes,
      status,
      picToken,
      const DeepCollectionEquality().hash(_photos),
      const DeepCollectionEquality().hash(_followUps),
      date,
      userName);

  /// Create a copy of HseTaskModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HseTaskModelImplCopyWith<_$HseTaskModelImpl> get copyWith =>
      __$$HseTaskModelImplCopyWithImpl<_$HseTaskModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HseTaskModelImplToJson(
      this,
    );
  }
}

abstract class _HseTaskModel implements HseTaskModel {
  const factory _HseTaskModel(
      {required final int id,
      required final String code,
      @JsonKey(name: 'user_id') required final int userId,
      @JsonKey(name: 'area_id') required final int areaId,
      final String? name,
      @JsonKey(name: 'risk_level') required final String riskLevel,
      @JsonKey(name: 'root_cause') required final String rootCause,
      required final String notes,
      required final String status,
      @JsonKey(name: 'pic_token') final String? picToken,
      final List<String> photos,
      final List<Map<String, dynamic>> followUps,
      final String? date,
      final String? userName}) = _$HseTaskModelImpl;

  factory _HseTaskModel.fromJson(Map<String, dynamic> json) =
      _$HseTaskModelImpl.fromJson;

  @override
  int get id;
  @override
  String get code;
  @override
  @JsonKey(name: 'user_id')
  int get userId;
  @override
  @JsonKey(name: 'area_id')
  int get areaId;
  @override
  String? get name;
  @override
  @JsonKey(name: 'risk_level')
  String get riskLevel;
  @override
  @JsonKey(name: 'root_cause')
  String get rootCause;
  @override
  String get notes;
  @override
  String get status;
  @override
  @JsonKey(name: 'pic_token')
  String? get picToken;
  @override
  List<String> get photos;
  @override
  List<Map<String, dynamic>> get followUps;
  @override
  String? get date;
  @override
  String? get userName;

  /// Create a copy of HseTaskModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HseTaskModelImplCopyWith<_$HseTaskModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
