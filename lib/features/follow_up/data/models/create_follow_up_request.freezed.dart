// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_follow_up_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CreateFollowUpRequest _$CreateFollowUpRequestFromJson(
    Map<String, dynamic> json) {
  return _CreateFollowUpRequest.fromJson(json);
}

/// @nodoc
mixin _$CreateFollowUpRequest {
  String get action => throw _privateConstructorUsedError;
  @JsonKey(name: 'notes_pic')
  String get notesPic => throw _privateConstructorUsedError;
  @JsonKey(name: 'notes_hse')
  String? get notesHse => throw _privateConstructorUsedError;

  /// Serializes this CreateFollowUpRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateFollowUpRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateFollowUpRequestCopyWith<CreateFollowUpRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateFollowUpRequestCopyWith<$Res> {
  factory $CreateFollowUpRequestCopyWith(CreateFollowUpRequest value,
          $Res Function(CreateFollowUpRequest) then) =
      _$CreateFollowUpRequestCopyWithImpl<$Res, CreateFollowUpRequest>;
  @useResult
  $Res call(
      {String action,
      @JsonKey(name: 'notes_pic') String notesPic,
      @JsonKey(name: 'notes_hse') String? notesHse});
}

/// @nodoc
class _$CreateFollowUpRequestCopyWithImpl<$Res,
        $Val extends CreateFollowUpRequest>
    implements $CreateFollowUpRequestCopyWith<$Res> {
  _$CreateFollowUpRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateFollowUpRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? action = null,
    Object? notesPic = null,
    Object? notesHse = freezed,
  }) {
    return _then(_value.copyWith(
      action: null == action
          ? _value.action
          : action // ignore: cast_nullable_to_non_nullable
              as String,
      notesPic: null == notesPic
          ? _value.notesPic
          : notesPic // ignore: cast_nullable_to_non_nullable
              as String,
      notesHse: freezed == notesHse
          ? _value.notesHse
          : notesHse // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CreateFollowUpRequestImplCopyWith<$Res>
    implements $CreateFollowUpRequestCopyWith<$Res> {
  factory _$$CreateFollowUpRequestImplCopyWith(
          _$CreateFollowUpRequestImpl value,
          $Res Function(_$CreateFollowUpRequestImpl) then) =
      __$$CreateFollowUpRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String action,
      @JsonKey(name: 'notes_pic') String notesPic,
      @JsonKey(name: 'notes_hse') String? notesHse});
}

/// @nodoc
class __$$CreateFollowUpRequestImplCopyWithImpl<$Res>
    extends _$CreateFollowUpRequestCopyWithImpl<$Res,
        _$CreateFollowUpRequestImpl>
    implements _$$CreateFollowUpRequestImplCopyWith<$Res> {
  __$$CreateFollowUpRequestImplCopyWithImpl(_$CreateFollowUpRequestImpl _value,
      $Res Function(_$CreateFollowUpRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of CreateFollowUpRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? action = null,
    Object? notesPic = null,
    Object? notesHse = freezed,
  }) {
    return _then(_$CreateFollowUpRequestImpl(
      action: null == action
          ? _value.action
          : action // ignore: cast_nullable_to_non_nullable
              as String,
      notesPic: null == notesPic
          ? _value.notesPic
          : notesPic // ignore: cast_nullable_to_non_nullable
              as String,
      notesHse: freezed == notesHse
          ? _value.notesHse
          : notesHse // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateFollowUpRequestImpl implements _CreateFollowUpRequest {
  const _$CreateFollowUpRequestImpl(
      {required this.action,
      @JsonKey(name: 'notes_pic') required this.notesPic,
      @JsonKey(name: 'notes_hse') this.notesHse});

  factory _$CreateFollowUpRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateFollowUpRequestImplFromJson(json);

  @override
  final String action;
  @override
  @JsonKey(name: 'notes_pic')
  final String notesPic;
  @override
  @JsonKey(name: 'notes_hse')
  final String? notesHse;

  @override
  String toString() {
    return 'CreateFollowUpRequest(action: $action, notesPic: $notesPic, notesHse: $notesHse)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateFollowUpRequestImpl &&
            (identical(other.action, action) || other.action == action) &&
            (identical(other.notesPic, notesPic) ||
                other.notesPic == notesPic) &&
            (identical(other.notesHse, notesHse) ||
                other.notesHse == notesHse));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, action, notesPic, notesHse);

  /// Create a copy of CreateFollowUpRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateFollowUpRequestImplCopyWith<_$CreateFollowUpRequestImpl>
      get copyWith => __$$CreateFollowUpRequestImplCopyWithImpl<
          _$CreateFollowUpRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateFollowUpRequestImplToJson(
      this,
    );
  }
}

abstract class _CreateFollowUpRequest implements CreateFollowUpRequest {
  const factory _CreateFollowUpRequest(
          {required final String action,
          @JsonKey(name: 'notes_pic') required final String notesPic,
          @JsonKey(name: 'notes_hse') final String? notesHse}) =
      _$CreateFollowUpRequestImpl;

  factory _CreateFollowUpRequest.fromJson(Map<String, dynamic> json) =
      _$CreateFollowUpRequestImpl.fromJson;

  @override
  String get action;
  @override
  @JsonKey(name: 'notes_pic')
  String get notesPic;
  @override
  @JsonKey(name: 'notes_hse')
  String? get notesHse;

  /// Create a copy of CreateFollowUpRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateFollowUpRequestImplCopyWith<_$CreateFollowUpRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}
