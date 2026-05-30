// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event_rating_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

EventRatingModel _$EventRatingModelFromJson(Map<String, dynamic> json) {
  return _EventRatingModel.fromJson(json);
}

/// @nodoc
mixin _$EventRatingModel {
  String? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'event_id')
  String get eventId => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  int get rating => throw _privateConstructorUsedError;
  String? get comment => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this EventRatingModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EventRatingModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EventRatingModelCopyWith<EventRatingModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EventRatingModelCopyWith<$Res> {
  factory $EventRatingModelCopyWith(
    EventRatingModel value,
    $Res Function(EventRatingModel) then,
  ) = _$EventRatingModelCopyWithImpl<$Res, EventRatingModel>;
  @useResult
  $Res call({
    String? id,
    @JsonKey(name: 'event_id') String eventId,
    @JsonKey(name: 'user_id') String userId,
    int rating,
    String? comment,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  });
}

/// @nodoc
class _$EventRatingModelCopyWithImpl<$Res, $Val extends EventRatingModel>
    implements $EventRatingModelCopyWith<$Res> {
  _$EventRatingModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EventRatingModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? eventId = null,
    Object? userId = null,
    Object? rating = null,
    Object? comment = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String?,
            eventId: null == eventId
                ? _value.eventId
                : eventId // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            rating: null == rating
                ? _value.rating
                : rating // ignore: cast_nullable_to_non_nullable
                      as int,
            comment: freezed == comment
                ? _value.comment
                : comment // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EventRatingModelImplCopyWith<$Res>
    implements $EventRatingModelCopyWith<$Res> {
  factory _$$EventRatingModelImplCopyWith(
    _$EventRatingModelImpl value,
    $Res Function(_$EventRatingModelImpl) then,
  ) = __$$EventRatingModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? id,
    @JsonKey(name: 'event_id') String eventId,
    @JsonKey(name: 'user_id') String userId,
    int rating,
    String? comment,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  });
}

/// @nodoc
class __$$EventRatingModelImplCopyWithImpl<$Res>
    extends _$EventRatingModelCopyWithImpl<$Res, _$EventRatingModelImpl>
    implements _$$EventRatingModelImplCopyWith<$Res> {
  __$$EventRatingModelImplCopyWithImpl(
    _$EventRatingModelImpl _value,
    $Res Function(_$EventRatingModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EventRatingModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? eventId = null,
    Object? userId = null,
    Object? rating = null,
    Object? comment = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$EventRatingModelImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String?,
        eventId: null == eventId
            ? _value.eventId
            : eventId // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        rating: null == rating
            ? _value.rating
            : rating // ignore: cast_nullable_to_non_nullable
                  as int,
        comment: freezed == comment
            ? _value.comment
            : comment // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$EventRatingModelImpl implements _EventRatingModel {
  const _$EventRatingModelImpl({
    this.id,
    @JsonKey(name: 'event_id') required this.eventId,
    @JsonKey(name: 'user_id') required this.userId,
    required this.rating,
    this.comment,
    @JsonKey(name: 'created_at') this.createdAt,
  });

  factory _$EventRatingModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$EventRatingModelImplFromJson(json);

  @override
  final String? id;
  @override
  @JsonKey(name: 'event_id')
  final String eventId;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  final int rating;
  @override
  final String? comment;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @override
  String toString() {
    return 'EventRatingModel(id: $id, eventId: $eventId, userId: $userId, rating: $rating, comment: $comment, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EventRatingModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.eventId, eventId) || other.eventId == eventId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.comment, comment) || other.comment == comment) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, eventId, userId, rating, comment, createdAt);

  /// Create a copy of EventRatingModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EventRatingModelImplCopyWith<_$EventRatingModelImpl> get copyWith =>
      __$$EventRatingModelImplCopyWithImpl<_$EventRatingModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$EventRatingModelImplToJson(this);
  }
}

abstract class _EventRatingModel implements EventRatingModel {
  const factory _EventRatingModel({
    final String? id,
    @JsonKey(name: 'event_id') required final String eventId,
    @JsonKey(name: 'user_id') required final String userId,
    required final int rating,
    final String? comment,
    @JsonKey(name: 'created_at') final DateTime? createdAt,
  }) = _$EventRatingModelImpl;

  factory _EventRatingModel.fromJson(Map<String, dynamic> json) =
      _$EventRatingModelImpl.fromJson;

  @override
  String? get id;
  @override
  @JsonKey(name: 'event_id')
  String get eventId;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  int get rating;
  @override
  String? get comment;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;

  /// Create a copy of EventRatingModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EventRatingModelImplCopyWith<_$EventRatingModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
