// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

EventModel _$EventModelFromJson(Map<String, dynamic> json) {
  return _EventModel.fromJson(json);
}

/// @nodoc
mixin _$EventModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'event_date')
  DateTime get eventDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'short_description')
  String? get shortDescription => throw _privateConstructorUsedError;
  @JsonKey(name: 'full_description')
  String? get fullDescription => throw _privateConstructorUsedError;
  @JsonKey(name: 'image_url')
  String? get imageUrl => throw _privateConstructorUsedError;
  String get location => throw _privateConstructorUsedError;
  @JsonKey(name: 'time_in_start')
  String get timeInStart => throw _privateConstructorUsedError;
  @JsonKey(name: 'time_in_end')
  String get timeInEnd => throw _privateConstructorUsedError;
  @JsonKey(name: 'time_out_start')
  String get timeOutStart => throw _privateConstructorUsedError;
  @JsonKey(name: 'time_out_end')
  String get timeOutEnd => throw _privateConstructorUsedError;
  @JsonKey(name: 'scope_type')
  String get scopeType => throw _privateConstructorUsedError;
  @JsonKey(name: 'scope_id')
  String get scopeId => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_mandatory')
  bool get isMandatory => throw _privateConstructorUsedError;
  @JsonKey(name: 'academic_term_id')
  String? get academicTermId => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_by_user_id')
  String? get createdByUserId => throw _privateConstructorUsedError;

  /// Serializes this EventModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EventModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EventModelCopyWith<EventModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EventModelCopyWith<$Res> {
  factory $EventModelCopyWith(
    EventModel value,
    $Res Function(EventModel) then,
  ) = _$EventModelCopyWithImpl<$Res, EventModel>;
  @useResult
  $Res call({
    String id,
    String name,
    @JsonKey(name: 'event_date') DateTime eventDate,
    @JsonKey(name: 'short_description') String? shortDescription,
    @JsonKey(name: 'full_description') String? fullDescription,
    @JsonKey(name: 'image_url') String? imageUrl,
    String location,
    @JsonKey(name: 'time_in_start') String timeInStart,
    @JsonKey(name: 'time_in_end') String timeInEnd,
    @JsonKey(name: 'time_out_start') String timeOutStart,
    @JsonKey(name: 'time_out_end') String timeOutEnd,
    @JsonKey(name: 'scope_type') String scopeType,
    @JsonKey(name: 'scope_id') String scopeId,
    @JsonKey(name: 'is_mandatory') bool isMandatory,
    @JsonKey(name: 'academic_term_id') String? academicTermId,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @JsonKey(name: 'created_by_user_id') String? createdByUserId,
  });
}

/// @nodoc
class _$EventModelCopyWithImpl<$Res, $Val extends EventModel>
    implements $EventModelCopyWith<$Res> {
  _$EventModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EventModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? eventDate = null,
    Object? shortDescription = freezed,
    Object? fullDescription = freezed,
    Object? imageUrl = freezed,
    Object? location = null,
    Object? timeInStart = null,
    Object? timeInEnd = null,
    Object? timeOutStart = null,
    Object? timeOutEnd = null,
    Object? scopeType = null,
    Object? scopeId = null,
    Object? isMandatory = null,
    Object? academicTermId = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? createdByUserId = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            eventDate: null == eventDate
                ? _value.eventDate
                : eventDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            shortDescription: freezed == shortDescription
                ? _value.shortDescription
                : shortDescription // ignore: cast_nullable_to_non_nullable
                      as String?,
            fullDescription: freezed == fullDescription
                ? _value.fullDescription
                : fullDescription // ignore: cast_nullable_to_non_nullable
                      as String?,
            imageUrl: freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            location: null == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                      as String,
            timeInStart: null == timeInStart
                ? _value.timeInStart
                : timeInStart // ignore: cast_nullable_to_non_nullable
                      as String,
            timeInEnd: null == timeInEnd
                ? _value.timeInEnd
                : timeInEnd // ignore: cast_nullable_to_non_nullable
                      as String,
            timeOutStart: null == timeOutStart
                ? _value.timeOutStart
                : timeOutStart // ignore: cast_nullable_to_non_nullable
                      as String,
            timeOutEnd: null == timeOutEnd
                ? _value.timeOutEnd
                : timeOutEnd // ignore: cast_nullable_to_non_nullable
                      as String,
            scopeType: null == scopeType
                ? _value.scopeType
                : scopeType // ignore: cast_nullable_to_non_nullable
                      as String,
            scopeId: null == scopeId
                ? _value.scopeId
                : scopeId // ignore: cast_nullable_to_non_nullable
                      as String,
            isMandatory: null == isMandatory
                ? _value.isMandatory
                : isMandatory // ignore: cast_nullable_to_non_nullable
                      as bool,
            academicTermId: freezed == academicTermId
                ? _value.academicTermId
                : academicTermId // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            createdByUserId: freezed == createdByUserId
                ? _value.createdByUserId
                : createdByUserId // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EventModelImplCopyWith<$Res>
    implements $EventModelCopyWith<$Res> {
  factory _$$EventModelImplCopyWith(
    _$EventModelImpl value,
    $Res Function(_$EventModelImpl) then,
  ) = __$$EventModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    @JsonKey(name: 'event_date') DateTime eventDate,
    @JsonKey(name: 'short_description') String? shortDescription,
    @JsonKey(name: 'full_description') String? fullDescription,
    @JsonKey(name: 'image_url') String? imageUrl,
    String location,
    @JsonKey(name: 'time_in_start') String timeInStart,
    @JsonKey(name: 'time_in_end') String timeInEnd,
    @JsonKey(name: 'time_out_start') String timeOutStart,
    @JsonKey(name: 'time_out_end') String timeOutEnd,
    @JsonKey(name: 'scope_type') String scopeType,
    @JsonKey(name: 'scope_id') String scopeId,
    @JsonKey(name: 'is_mandatory') bool isMandatory,
    @JsonKey(name: 'academic_term_id') String? academicTermId,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @JsonKey(name: 'created_by_user_id') String? createdByUserId,
  });
}

/// @nodoc
class __$$EventModelImplCopyWithImpl<$Res>
    extends _$EventModelCopyWithImpl<$Res, _$EventModelImpl>
    implements _$$EventModelImplCopyWith<$Res> {
  __$$EventModelImplCopyWithImpl(
    _$EventModelImpl _value,
    $Res Function(_$EventModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EventModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? eventDate = null,
    Object? shortDescription = freezed,
    Object? fullDescription = freezed,
    Object? imageUrl = freezed,
    Object? location = null,
    Object? timeInStart = null,
    Object? timeInEnd = null,
    Object? timeOutStart = null,
    Object? timeOutEnd = null,
    Object? scopeType = null,
    Object? scopeId = null,
    Object? isMandatory = null,
    Object? academicTermId = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? createdByUserId = freezed,
  }) {
    return _then(
      _$EventModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        eventDate: null == eventDate
            ? _value.eventDate
            : eventDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        shortDescription: freezed == shortDescription
            ? _value.shortDescription
            : shortDescription // ignore: cast_nullable_to_non_nullable
                  as String?,
        fullDescription: freezed == fullDescription
            ? _value.fullDescription
            : fullDescription // ignore: cast_nullable_to_non_nullable
                  as String?,
        imageUrl: freezed == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        location: null == location
            ? _value.location
            : location // ignore: cast_nullable_to_non_nullable
                  as String,
        timeInStart: null == timeInStart
            ? _value.timeInStart
            : timeInStart // ignore: cast_nullable_to_non_nullable
                  as String,
        timeInEnd: null == timeInEnd
            ? _value.timeInEnd
            : timeInEnd // ignore: cast_nullable_to_non_nullable
                  as String,
        timeOutStart: null == timeOutStart
            ? _value.timeOutStart
            : timeOutStart // ignore: cast_nullable_to_non_nullable
                  as String,
        timeOutEnd: null == timeOutEnd
            ? _value.timeOutEnd
            : timeOutEnd // ignore: cast_nullable_to_non_nullable
                  as String,
        scopeType: null == scopeType
            ? _value.scopeType
            : scopeType // ignore: cast_nullable_to_non_nullable
                  as String,
        scopeId: null == scopeId
            ? _value.scopeId
            : scopeId // ignore: cast_nullable_to_non_nullable
                  as String,
        isMandatory: null == isMandatory
            ? _value.isMandatory
            : isMandatory // ignore: cast_nullable_to_non_nullable
                  as bool,
        academicTermId: freezed == academicTermId
            ? _value.academicTermId
            : academicTermId // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        createdByUserId: freezed == createdByUserId
            ? _value.createdByUserId
            : createdByUserId // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$EventModelImpl implements _EventModel {
  const _$EventModelImpl({
    required this.id,
    required this.name,
    @JsonKey(name: 'event_date') required this.eventDate,
    @JsonKey(name: 'short_description') this.shortDescription,
    @JsonKey(name: 'full_description') this.fullDescription,
    @JsonKey(name: 'image_url') this.imageUrl,
    required this.location,
    @JsonKey(name: 'time_in_start') required this.timeInStart,
    @JsonKey(name: 'time_in_end') required this.timeInEnd,
    @JsonKey(name: 'time_out_start') required this.timeOutStart,
    @JsonKey(name: 'time_out_end') required this.timeOutEnd,
    @JsonKey(name: 'scope_type') required this.scopeType,
    @JsonKey(name: 'scope_id') required this.scopeId,
    @JsonKey(name: 'is_mandatory') this.isMandatory = true,
    @JsonKey(name: 'academic_term_id') this.academicTermId,
    @JsonKey(name: 'created_at') this.createdAt,
    @JsonKey(name: 'updated_at') this.updatedAt,
    @JsonKey(name: 'created_by_user_id') this.createdByUserId,
  });

  factory _$EventModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$EventModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  @JsonKey(name: 'event_date')
  final DateTime eventDate;
  @override
  @JsonKey(name: 'short_description')
  final String? shortDescription;
  @override
  @JsonKey(name: 'full_description')
  final String? fullDescription;
  @override
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @override
  final String location;
  @override
  @JsonKey(name: 'time_in_start')
  final String timeInStart;
  @override
  @JsonKey(name: 'time_in_end')
  final String timeInEnd;
  @override
  @JsonKey(name: 'time_out_start')
  final String timeOutStart;
  @override
  @JsonKey(name: 'time_out_end')
  final String timeOutEnd;
  @override
  @JsonKey(name: 'scope_type')
  final String scopeType;
  @override
  @JsonKey(name: 'scope_id')
  final String scopeId;
  @override
  @JsonKey(name: 'is_mandatory')
  final bool isMandatory;
  @override
  @JsonKey(name: 'academic_term_id')
  final String? academicTermId;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  @override
  @JsonKey(name: 'created_by_user_id')
  final String? createdByUserId;

  @override
  String toString() {
    return 'EventModel(id: $id, name: $name, eventDate: $eventDate, shortDescription: $shortDescription, fullDescription: $fullDescription, imageUrl: $imageUrl, location: $location, timeInStart: $timeInStart, timeInEnd: $timeInEnd, timeOutStart: $timeOutStart, timeOutEnd: $timeOutEnd, scopeType: $scopeType, scopeId: $scopeId, isMandatory: $isMandatory, academicTermId: $academicTermId, createdAt: $createdAt, updatedAt: $updatedAt, createdByUserId: $createdByUserId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EventModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.eventDate, eventDate) ||
                other.eventDate == eventDate) &&
            (identical(other.shortDescription, shortDescription) ||
                other.shortDescription == shortDescription) &&
            (identical(other.fullDescription, fullDescription) ||
                other.fullDescription == fullDescription) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.timeInStart, timeInStart) ||
                other.timeInStart == timeInStart) &&
            (identical(other.timeInEnd, timeInEnd) ||
                other.timeInEnd == timeInEnd) &&
            (identical(other.timeOutStart, timeOutStart) ||
                other.timeOutStart == timeOutStart) &&
            (identical(other.timeOutEnd, timeOutEnd) ||
                other.timeOutEnd == timeOutEnd) &&
            (identical(other.scopeType, scopeType) ||
                other.scopeType == scopeType) &&
            (identical(other.scopeId, scopeId) || other.scopeId == scopeId) &&
            (identical(other.isMandatory, isMandatory) ||
                other.isMandatory == isMandatory) &&
            (identical(other.academicTermId, academicTermId) ||
                other.academicTermId == academicTermId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.createdByUserId, createdByUserId) ||
                other.createdByUserId == createdByUserId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    eventDate,
    shortDescription,
    fullDescription,
    imageUrl,
    location,
    timeInStart,
    timeInEnd,
    timeOutStart,
    timeOutEnd,
    scopeType,
    scopeId,
    isMandatory,
    academicTermId,
    createdAt,
    updatedAt,
    createdByUserId,
  );

  /// Create a copy of EventModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EventModelImplCopyWith<_$EventModelImpl> get copyWith =>
      __$$EventModelImplCopyWithImpl<_$EventModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EventModelImplToJson(this);
  }
}

abstract class _EventModel implements EventModel {
  const factory _EventModel({
    required final String id,
    required final String name,
    @JsonKey(name: 'event_date') required final DateTime eventDate,
    @JsonKey(name: 'short_description') final String? shortDescription,
    @JsonKey(name: 'full_description') final String? fullDescription,
    @JsonKey(name: 'image_url') final String? imageUrl,
    required final String location,
    @JsonKey(name: 'time_in_start') required final String timeInStart,
    @JsonKey(name: 'time_in_end') required final String timeInEnd,
    @JsonKey(name: 'time_out_start') required final String timeOutStart,
    @JsonKey(name: 'time_out_end') required final String timeOutEnd,
    @JsonKey(name: 'scope_type') required final String scopeType,
    @JsonKey(name: 'scope_id') required final String scopeId,
    @JsonKey(name: 'is_mandatory') final bool isMandatory,
    @JsonKey(name: 'academic_term_id') final String? academicTermId,
    @JsonKey(name: 'created_at') final DateTime? createdAt,
    @JsonKey(name: 'updated_at') final DateTime? updatedAt,
    @JsonKey(name: 'created_by_user_id') final String? createdByUserId,
  }) = _$EventModelImpl;

  factory _EventModel.fromJson(Map<String, dynamic> json) =
      _$EventModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  @JsonKey(name: 'event_date')
  DateTime get eventDate;
  @override
  @JsonKey(name: 'short_description')
  String? get shortDescription;
  @override
  @JsonKey(name: 'full_description')
  String? get fullDescription;
  @override
  @JsonKey(name: 'image_url')
  String? get imageUrl;
  @override
  String get location;
  @override
  @JsonKey(name: 'time_in_start')
  String get timeInStart;
  @override
  @JsonKey(name: 'time_in_end')
  String get timeInEnd;
  @override
  @JsonKey(name: 'time_out_start')
  String get timeOutStart;
  @override
  @JsonKey(name: 'time_out_end')
  String get timeOutEnd;
  @override
  @JsonKey(name: 'scope_type')
  String get scopeType;
  @override
  @JsonKey(name: 'scope_id')
  String get scopeId;
  @override
  @JsonKey(name: 'is_mandatory')
  bool get isMandatory;
  @override
  @JsonKey(name: 'academic_term_id')
  String? get academicTermId;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;
  @override
  @JsonKey(name: 'created_by_user_id')
  String? get createdByUserId;

  /// Create a copy of EventModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EventModelImplCopyWith<_$EventModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
