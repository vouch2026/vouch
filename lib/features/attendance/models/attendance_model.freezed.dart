// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'attendance_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AttendanceModel _$AttendanceModelFromJson(Map<String, dynamic> json) {
  return _AttendanceModel.fromJson(json);
}

/// @nodoc
mixin _$AttendanceModel {
  String? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'student_id')
  String get studentId => throw _privateConstructorUsedError;
  @JsonKey(name: 'event_id')
  String get eventId => throw _privateConstructorUsedError;
  @JsonKey(name: 'actual_time_in')
  DateTime? get actualTimeIn => throw _privateConstructorUsedError;
  @JsonKey(name: 'actual_time_out')
  DateTime? get actualTimeOut => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'scanned_by_user_id')
  String? get scannedByUserId => throw _privateConstructorUsedError;
  @JsonKey(name: 'override_reason')
  String? get overrideReason => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this AttendanceModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AttendanceModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AttendanceModelCopyWith<AttendanceModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AttendanceModelCopyWith<$Res> {
  factory $AttendanceModelCopyWith(
    AttendanceModel value,
    $Res Function(AttendanceModel) then,
  ) = _$AttendanceModelCopyWithImpl<$Res, AttendanceModel>;
  @useResult
  $Res call({
    String? id,
    @JsonKey(name: 'student_id') String studentId,
    @JsonKey(name: 'event_id') String eventId,
    @JsonKey(name: 'actual_time_in') DateTime? actualTimeIn,
    @JsonKey(name: 'actual_time_out') DateTime? actualTimeOut,
    String status,
    @JsonKey(name: 'scanned_by_user_id') String? scannedByUserId,
    @JsonKey(name: 'override_reason') String? overrideReason,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  });
}

/// @nodoc
class _$AttendanceModelCopyWithImpl<$Res, $Val extends AttendanceModel>
    implements $AttendanceModelCopyWith<$Res> {
  _$AttendanceModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AttendanceModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? studentId = null,
    Object? eventId = null,
    Object? actualTimeIn = freezed,
    Object? actualTimeOut = freezed,
    Object? status = null,
    Object? scannedByUserId = freezed,
    Object? overrideReason = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String?,
            studentId: null == studentId
                ? _value.studentId
                : studentId // ignore: cast_nullable_to_non_nullable
                      as String,
            eventId: null == eventId
                ? _value.eventId
                : eventId // ignore: cast_nullable_to_non_nullable
                      as String,
            actualTimeIn: freezed == actualTimeIn
                ? _value.actualTimeIn
                : actualTimeIn // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            actualTimeOut: freezed == actualTimeOut
                ? _value.actualTimeOut
                : actualTimeOut // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            scannedByUserId: freezed == scannedByUserId
                ? _value.scannedByUserId
                : scannedByUserId // ignore: cast_nullable_to_non_nullable
                      as String?,
            overrideReason: freezed == overrideReason
                ? _value.overrideReason
                : overrideReason // ignore: cast_nullable_to_non_nullable
                      as String?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AttendanceModelImplCopyWith<$Res>
    implements $AttendanceModelCopyWith<$Res> {
  factory _$$AttendanceModelImplCopyWith(
    _$AttendanceModelImpl value,
    $Res Function(_$AttendanceModelImpl) then,
  ) = __$$AttendanceModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? id,
    @JsonKey(name: 'student_id') String studentId,
    @JsonKey(name: 'event_id') String eventId,
    @JsonKey(name: 'actual_time_in') DateTime? actualTimeIn,
    @JsonKey(name: 'actual_time_out') DateTime? actualTimeOut,
    String status,
    @JsonKey(name: 'scanned_by_user_id') String? scannedByUserId,
    @JsonKey(name: 'override_reason') String? overrideReason,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  });
}

/// @nodoc
class __$$AttendanceModelImplCopyWithImpl<$Res>
    extends _$AttendanceModelCopyWithImpl<$Res, _$AttendanceModelImpl>
    implements _$$AttendanceModelImplCopyWith<$Res> {
  __$$AttendanceModelImplCopyWithImpl(
    _$AttendanceModelImpl _value,
    $Res Function(_$AttendanceModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AttendanceModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? studentId = null,
    Object? eventId = null,
    Object? actualTimeIn = freezed,
    Object? actualTimeOut = freezed,
    Object? status = null,
    Object? scannedByUserId = freezed,
    Object? overrideReason = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$AttendanceModelImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String?,
        studentId: null == studentId
            ? _value.studentId
            : studentId // ignore: cast_nullable_to_non_nullable
                  as String,
        eventId: null == eventId
            ? _value.eventId
            : eventId // ignore: cast_nullable_to_non_nullable
                  as String,
        actualTimeIn: freezed == actualTimeIn
            ? _value.actualTimeIn
            : actualTimeIn // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        actualTimeOut: freezed == actualTimeOut
            ? _value.actualTimeOut
            : actualTimeOut // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        scannedByUserId: freezed == scannedByUserId
            ? _value.scannedByUserId
            : scannedByUserId // ignore: cast_nullable_to_non_nullable
                  as String?,
        overrideReason: freezed == overrideReason
            ? _value.overrideReason
            : overrideReason // ignore: cast_nullable_to_non_nullable
                  as String?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AttendanceModelImpl implements _AttendanceModel {
  const _$AttendanceModelImpl({
    this.id,
    @JsonKey(name: 'student_id') required this.studentId,
    @JsonKey(name: 'event_id') required this.eventId,
    @JsonKey(name: 'actual_time_in') this.actualTimeIn,
    @JsonKey(name: 'actual_time_out') this.actualTimeOut,
    this.status = 'Pending',
    @JsonKey(name: 'scanned_by_user_id') this.scannedByUserId,
    @JsonKey(name: 'override_reason') this.overrideReason,
    @JsonKey(name: 'updated_at') this.updatedAt,
  });

  factory _$AttendanceModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AttendanceModelImplFromJson(json);

  @override
  final String? id;
  @override
  @JsonKey(name: 'student_id')
  final String studentId;
  @override
  @JsonKey(name: 'event_id')
  final String eventId;
  @override
  @JsonKey(name: 'actual_time_in')
  final DateTime? actualTimeIn;
  @override
  @JsonKey(name: 'actual_time_out')
  final DateTime? actualTimeOut;
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey(name: 'scanned_by_user_id')
  final String? scannedByUserId;
  @override
  @JsonKey(name: 'override_reason')
  final String? overrideReason;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'AttendanceModel(id: $id, studentId: $studentId, eventId: $eventId, actualTimeIn: $actualTimeIn, actualTimeOut: $actualTimeOut, status: $status, scannedByUserId: $scannedByUserId, overrideReason: $overrideReason, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AttendanceModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.studentId, studentId) ||
                other.studentId == studentId) &&
            (identical(other.eventId, eventId) || other.eventId == eventId) &&
            (identical(other.actualTimeIn, actualTimeIn) ||
                other.actualTimeIn == actualTimeIn) &&
            (identical(other.actualTimeOut, actualTimeOut) ||
                other.actualTimeOut == actualTimeOut) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.scannedByUserId, scannedByUserId) ||
                other.scannedByUserId == scannedByUserId) &&
            (identical(other.overrideReason, overrideReason) ||
                other.overrideReason == overrideReason) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    studentId,
    eventId,
    actualTimeIn,
    actualTimeOut,
    status,
    scannedByUserId,
    overrideReason,
    updatedAt,
  );

  /// Create a copy of AttendanceModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AttendanceModelImplCopyWith<_$AttendanceModelImpl> get copyWith =>
      __$$AttendanceModelImplCopyWithImpl<_$AttendanceModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AttendanceModelImplToJson(this);
  }
}

abstract class _AttendanceModel implements AttendanceModel {
  const factory _AttendanceModel({
    final String? id,
    @JsonKey(name: 'student_id') required final String studentId,
    @JsonKey(name: 'event_id') required final String eventId,
    @JsonKey(name: 'actual_time_in') final DateTime? actualTimeIn,
    @JsonKey(name: 'actual_time_out') final DateTime? actualTimeOut,
    final String status,
    @JsonKey(name: 'scanned_by_user_id') final String? scannedByUserId,
    @JsonKey(name: 'override_reason') final String? overrideReason,
    @JsonKey(name: 'updated_at') final DateTime? updatedAt,
  }) = _$AttendanceModelImpl;

  factory _AttendanceModel.fromJson(Map<String, dynamic> json) =
      _$AttendanceModelImpl.fromJson;

  @override
  String? get id;
  @override
  @JsonKey(name: 'student_id')
  String get studentId;
  @override
  @JsonKey(name: 'event_id')
  String get eventId;
  @override
  @JsonKey(name: 'actual_time_in')
  DateTime? get actualTimeIn;
  @override
  @JsonKey(name: 'actual_time_out')
  DateTime? get actualTimeOut;
  @override
  String get status;
  @override
  @JsonKey(name: 'scanned_by_user_id')
  String? get scannedByUserId;
  @override
  @JsonKey(name: 'override_reason')
  String? get overrideReason;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;

  /// Create a copy of AttendanceModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AttendanceModelImplCopyWith<_$AttendanceModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
