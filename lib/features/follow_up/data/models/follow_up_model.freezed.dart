// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'follow_up_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

FollowUpModel _$FollowUpModelFromJson(Map<String, dynamic> json) {
  return _FollowUpModel.fromJson(json);
}

/// @nodoc
mixin _$FollowUpModel {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'report_id')
  int get reportId => throw _privateConstructorUsedError;
  String get action => throw _privateConstructorUsedError;
  @JsonKey(name: 'notes_pic')
  String? get notesPic => throw _privateConstructorUsedError;
  @JsonKey(name: 'notes_hse')
  String? get notesHse => throw _privateConstructorUsedError;
  List<String> get photos => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;
  String? get date => throw _privateConstructorUsedError;

  /// Serializes this FollowUpModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FollowUpModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FollowUpModelCopyWith<FollowUpModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FollowUpModelCopyWith<$Res> {
  factory $FollowUpModelCopyWith(
          FollowUpModel value, $Res Function(FollowUpModel) then) =
      _$FollowUpModelCopyWithImpl<$Res, FollowUpModel>;
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'report_id') int reportId,
      String action,
      @JsonKey(name: 'notes_pic') String? notesPic,
      @JsonKey(name: 'notes_hse') String? notesHse,
      List<String> photos,
      String? status,
      String? date});
}

/// @nodoc
class _$FollowUpModelCopyWithImpl<$Res, $Val extends FollowUpModel>
    implements $FollowUpModelCopyWith<$Res> {
  _$FollowUpModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FollowUpModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? reportId = null,
    Object? action = null,
    Object? notesPic = freezed,
    Object? notesHse = freezed,
    Object? photos = null,
    Object? status = freezed,
    Object? date = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      reportId: null == reportId
          ? _value.reportId
          : reportId // ignore: cast_nullable_to_non_nullable
              as int,
      action: null == action
          ? _value.action
          : action // ignore: cast_nullable_to_non_nullable
              as String,
      notesPic: freezed == notesPic
          ? _value.notesPic
          : notesPic // ignore: cast_nullable_to_non_nullable
              as String?,
      notesHse: freezed == notesHse
          ? _value.notesHse
          : notesHse // ignore: cast_nullable_to_non_nullable
              as String?,
      photos: null == photos
          ? _value.photos
          : photos // ignore: cast_nullable_to_non_nullable
              as List<String>,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      date: freezed == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FollowUpModelImplCopyWith<$Res>
    implements $FollowUpModelCopyWith<$Res> {
  factory _$$FollowUpModelImplCopyWith(
          _$FollowUpModelImpl value, $Res Function(_$FollowUpModelImpl) then) =
      __$$FollowUpModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'report_id') int reportId,
      String action,
      @JsonKey(name: 'notes_pic') String? notesPic,
      @JsonKey(name: 'notes_hse') String? notesHse,
      List<String> photos,
      String? status,
      String? date});
}

/// @nodoc
class __$$FollowUpModelImplCopyWithImpl<$Res>
    extends _$FollowUpModelCopyWithImpl<$Res, _$FollowUpModelImpl>
    implements _$$FollowUpModelImplCopyWith<$Res> {
  __$$FollowUpModelImplCopyWithImpl(
      _$FollowUpModelImpl _value, $Res Function(_$FollowUpModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of FollowUpModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? reportId = null,
    Object? action = null,
    Object? notesPic = freezed,
    Object? notesHse = freezed,
    Object? photos = null,
    Object? status = freezed,
    Object? date = freezed,
  }) {
    return _then(_$FollowUpModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      reportId: null == reportId
          ? _value.reportId
          : reportId // ignore: cast_nullable_to_non_nullable
              as int,
      action: null == action
          ? _value.action
          : action // ignore: cast_nullable_to_non_nullable
              as String,
      notesPic: freezed == notesPic
          ? _value.notesPic
          : notesPic // ignore: cast_nullable_to_non_nullable
              as String?,
      notesHse: freezed == notesHse
          ? _value.notesHse
          : notesHse // ignore: cast_nullable_to_non_nullable
              as String?,
      photos: null == photos
          ? _value._photos
          : photos // ignore: cast_nullable_to_non_nullable
              as List<String>,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      date: freezed == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FollowUpModelImpl implements _FollowUpModel {
  const _$FollowUpModelImpl(
      {required this.id,
      @JsonKey(name: 'report_id') required this.reportId,
      required this.action,
      @JsonKey(name: 'notes_pic') this.notesPic,
      @JsonKey(name: 'notes_hse') this.notesHse,
      final List<String> photos = const [],
      this.status,
      this.date})
      : _photos = photos;

  factory _$FollowUpModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$FollowUpModelImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'report_id')
  final int reportId;
  @override
  final String action;
  @override
  @JsonKey(name: 'notes_pic')
  final String? notesPic;
  @override
  @JsonKey(name: 'notes_hse')
  final String? notesHse;
  final List<String> _photos;
  @override
  @JsonKey()
  List<String> get photos {
    if (_photos is EqualUnmodifiableListView) return _photos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_photos);
  }

  @override
  final String? status;
  @override
  final String? date;

  @override
  String toString() {
    return 'FollowUpModel(id: $id, reportId: $reportId, action: $action, notesPic: $notesPic, notesHse: $notesHse, photos: $photos, status: $status, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FollowUpModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.reportId, reportId) ||
                other.reportId == reportId) &&
            (identical(other.action, action) || other.action == action) &&
            (identical(other.notesPic, notesPic) ||
                other.notesPic == notesPic) &&
            (identical(other.notesHse, notesHse) ||
                other.notesHse == notesHse) &&
            const DeepCollectionEquality().equals(other._photos, _photos) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.date, date) || other.date == date));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, reportId, action, notesPic,
      notesHse, const DeepCollectionEquality().hash(_photos), status, date);

  /// Create a copy of FollowUpModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FollowUpModelImplCopyWith<_$FollowUpModelImpl> get copyWith =>
      __$$FollowUpModelImplCopyWithImpl<_$FollowUpModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FollowUpModelImplToJson(
      this,
    );
  }
}

abstract class _FollowUpModel implements FollowUpModel {
  const factory _FollowUpModel(
      {required final int id,
      @JsonKey(name: 'report_id') required final int reportId,
      required final String action,
      @JsonKey(name: 'notes_pic') final String? notesPic,
      @JsonKey(name: 'notes_hse') final String? notesHse,
      final List<String> photos,
      final String? status,
      final String? date}) = _$FollowUpModelImpl;

  factory _FollowUpModel.fromJson(Map<String, dynamic> json) =
      _$FollowUpModelImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: 'report_id')
  int get reportId;
  @override
  String get action;
  @override
  @JsonKey(name: 'notes_pic')
  String? get notesPic;
  @override
  @JsonKey(name: 'notes_hse')
  String? get notesHse;
  @override
  List<String> get photos;
  @override
  String? get status;
  @override
  String? get date;

  /// Create a copy of FollowUpModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FollowUpModelImplCopyWith<_$FollowUpModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
