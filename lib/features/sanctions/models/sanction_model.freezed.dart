// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sanction_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SanctionModel _$SanctionModelFromJson(Map<String, dynamic> json) {
  return _SanctionModel.fromJson(json);
}

/// @nodoc
mixin _$SanctionModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'student_id')
  String get studentId => throw _privateConstructorUsedError;
  @JsonKey(name: 'scope_type')
  String get scopeType => throw _privateConstructorUsedError;
  @JsonKey(name: 'scope_id')
  String get scopeId => throw _privateConstructorUsedError;
  @JsonKey(name: 'academic_term_id')
  String get academicTermId => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_absences')
  int get totalAbsences => throw _privateConstructorUsedError;
  @JsonKey(name: 'required_item')
  String get requiredItem => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'received_by_user_id')
  String? get receivedByUserId => throw _privateConstructorUsedError;
  @JsonKey(name: 'received_at')
  DateTime? get receivedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError; // Join fields
  @JsonKey(name: 'student_name')
  String? get studentName => throw _privateConstructorUsedError;
  @JsonKey(name: 'received_by_name')
  String? get receivedByName => throw _privateConstructorUsedError;

  /// Serializes this SanctionModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SanctionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SanctionModelCopyWith<SanctionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SanctionModelCopyWith<$Res> {
  factory $SanctionModelCopyWith(
    SanctionModel value,
    $Res Function(SanctionModel) then,
  ) = _$SanctionModelCopyWithImpl<$Res, SanctionModel>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'student_id') String studentId,
    @JsonKey(name: 'scope_type') String scopeType,
    @JsonKey(name: 'scope_id') String scopeId,
    @JsonKey(name: 'academic_term_id') String academicTermId,
    @JsonKey(name: 'total_absences') int totalAbsences,
    @JsonKey(name: 'required_item') String requiredItem,
    String status,
    @JsonKey(name: 'received_by_user_id') String? receivedByUserId,
    @JsonKey(name: 'received_at') DateTime? receivedAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @JsonKey(name: 'student_name') String? studentName,
    @JsonKey(name: 'received_by_name') String? receivedByName,
  });
}

/// @nodoc
class _$SanctionModelCopyWithImpl<$Res, $Val extends SanctionModel>
    implements $SanctionModelCopyWith<$Res> {
  _$SanctionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SanctionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? studentId = null,
    Object? scopeType = null,
    Object? scopeId = null,
    Object? academicTermId = null,
    Object? totalAbsences = null,
    Object? requiredItem = null,
    Object? status = null,
    Object? receivedByUserId = freezed,
    Object? receivedAt = freezed,
    Object? updatedAt = freezed,
    Object? studentName = freezed,
    Object? receivedByName = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            studentId: null == studentId
                ? _value.studentId
                : studentId // ignore: cast_nullable_to_non_nullable
                      as String,
            scopeType: null == scopeType
                ? _value.scopeType
                : scopeType // ignore: cast_nullable_to_non_nullable
                      as String,
            scopeId: null == scopeId
                ? _value.scopeId
                : scopeId // ignore: cast_nullable_to_non_nullable
                      as String,
            academicTermId: null == academicTermId
                ? _value.academicTermId
                : academicTermId // ignore: cast_nullable_to_non_nullable
                      as String,
            totalAbsences: null == totalAbsences
                ? _value.totalAbsences
                : totalAbsences // ignore: cast_nullable_to_non_nullable
                      as int,
            requiredItem: null == requiredItem
                ? _value.requiredItem
                : requiredItem // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            receivedByUserId: freezed == receivedByUserId
                ? _value.receivedByUserId
                : receivedByUserId // ignore: cast_nullable_to_non_nullable
                      as String?,
            receivedAt: freezed == receivedAt
                ? _value.receivedAt
                : receivedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            studentName: freezed == studentName
                ? _value.studentName
                : studentName // ignore: cast_nullable_to_non_nullable
                      as String?,
            receivedByName: freezed == receivedByName
                ? _value.receivedByName
                : receivedByName // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SanctionModelImplCopyWith<$Res>
    implements $SanctionModelCopyWith<$Res> {
  factory _$$SanctionModelImplCopyWith(
    _$SanctionModelImpl value,
    $Res Function(_$SanctionModelImpl) then,
  ) = __$$SanctionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'student_id') String studentId,
    @JsonKey(name: 'scope_type') String scopeType,
    @JsonKey(name: 'scope_id') String scopeId,
    @JsonKey(name: 'academic_term_id') String academicTermId,
    @JsonKey(name: 'total_absences') int totalAbsences,
    @JsonKey(name: 'required_item') String requiredItem,
    String status,
    @JsonKey(name: 'received_by_user_id') String? receivedByUserId,
    @JsonKey(name: 'received_at') DateTime? receivedAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @JsonKey(name: 'student_name') String? studentName,
    @JsonKey(name: 'received_by_name') String? receivedByName,
  });
}

/// @nodoc
class __$$SanctionModelImplCopyWithImpl<$Res>
    extends _$SanctionModelCopyWithImpl<$Res, _$SanctionModelImpl>
    implements _$$SanctionModelImplCopyWith<$Res> {
  __$$SanctionModelImplCopyWithImpl(
    _$SanctionModelImpl _value,
    $Res Function(_$SanctionModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SanctionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? studentId = null,
    Object? scopeType = null,
    Object? scopeId = null,
    Object? academicTermId = null,
    Object? totalAbsences = null,
    Object? requiredItem = null,
    Object? status = null,
    Object? receivedByUserId = freezed,
    Object? receivedAt = freezed,
    Object? updatedAt = freezed,
    Object? studentName = freezed,
    Object? receivedByName = freezed,
  }) {
    return _then(
      _$SanctionModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        studentId: null == studentId
            ? _value.studentId
            : studentId // ignore: cast_nullable_to_non_nullable
                  as String,
        scopeType: null == scopeType
            ? _value.scopeType
            : scopeType // ignore: cast_nullable_to_non_nullable
                  as String,
        scopeId: null == scopeId
            ? _value.scopeId
            : scopeId // ignore: cast_nullable_to_non_nullable
                  as String,
        academicTermId: null == academicTermId
            ? _value.academicTermId
            : academicTermId // ignore: cast_nullable_to_non_nullable
                  as String,
        totalAbsences: null == totalAbsences
            ? _value.totalAbsences
            : totalAbsences // ignore: cast_nullable_to_non_nullable
                  as int,
        requiredItem: null == requiredItem
            ? _value.requiredItem
            : requiredItem // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        receivedByUserId: freezed == receivedByUserId
            ? _value.receivedByUserId
            : receivedByUserId // ignore: cast_nullable_to_non_nullable
                  as String?,
        receivedAt: freezed == receivedAt
            ? _value.receivedAt
            : receivedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        studentName: freezed == studentName
            ? _value.studentName
            : studentName // ignore: cast_nullable_to_non_nullable
                  as String?,
        receivedByName: freezed == receivedByName
            ? _value.receivedByName
            : receivedByName // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SanctionModelImpl implements _SanctionModel {
  const _$SanctionModelImpl({
    required this.id,
    @JsonKey(name: 'student_id') required this.studentId,
    @JsonKey(name: 'scope_type') required this.scopeType,
    @JsonKey(name: 'scope_id') required this.scopeId,
    @JsonKey(name: 'academic_term_id') required this.academicTermId,
    @JsonKey(name: 'total_absences') required this.totalAbsences,
    @JsonKey(name: 'required_item') required this.requiredItem,
    this.status = 'Pending Item',
    @JsonKey(name: 'received_by_user_id') this.receivedByUserId,
    @JsonKey(name: 'received_at') this.receivedAt,
    @JsonKey(name: 'updated_at') this.updatedAt,
    @JsonKey(name: 'student_name') this.studentName,
    @JsonKey(name: 'received_by_name') this.receivedByName,
  });

  factory _$SanctionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SanctionModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'student_id')
  final String studentId;
  @override
  @JsonKey(name: 'scope_type')
  final String scopeType;
  @override
  @JsonKey(name: 'scope_id')
  final String scopeId;
  @override
  @JsonKey(name: 'academic_term_id')
  final String academicTermId;
  @override
  @JsonKey(name: 'total_absences')
  final int totalAbsences;
  @override
  @JsonKey(name: 'required_item')
  final String requiredItem;
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey(name: 'received_by_user_id')
  final String? receivedByUserId;
  @override
  @JsonKey(name: 'received_at')
  final DateTime? receivedAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  // Join fields
  @override
  @JsonKey(name: 'student_name')
  final String? studentName;
  @override
  @JsonKey(name: 'received_by_name')
  final String? receivedByName;

  @override
  String toString() {
    return 'SanctionModel(id: $id, studentId: $studentId, scopeType: $scopeType, scopeId: $scopeId, academicTermId: $academicTermId, totalAbsences: $totalAbsences, requiredItem: $requiredItem, status: $status, receivedByUserId: $receivedByUserId, receivedAt: $receivedAt, updatedAt: $updatedAt, studentName: $studentName, receivedByName: $receivedByName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SanctionModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.studentId, studentId) ||
                other.studentId == studentId) &&
            (identical(other.scopeType, scopeType) ||
                other.scopeType == scopeType) &&
            (identical(other.scopeId, scopeId) || other.scopeId == scopeId) &&
            (identical(other.academicTermId, academicTermId) ||
                other.academicTermId == academicTermId) &&
            (identical(other.totalAbsences, totalAbsences) ||
                other.totalAbsences == totalAbsences) &&
            (identical(other.requiredItem, requiredItem) ||
                other.requiredItem == requiredItem) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.receivedByUserId, receivedByUserId) ||
                other.receivedByUserId == receivedByUserId) &&
            (identical(other.receivedAt, receivedAt) ||
                other.receivedAt == receivedAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.studentName, studentName) ||
                other.studentName == studentName) &&
            (identical(other.receivedByName, receivedByName) ||
                other.receivedByName == receivedByName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    studentId,
    scopeType,
    scopeId,
    academicTermId,
    totalAbsences,
    requiredItem,
    status,
    receivedByUserId,
    receivedAt,
    updatedAt,
    studentName,
    receivedByName,
  );

  /// Create a copy of SanctionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SanctionModelImplCopyWith<_$SanctionModelImpl> get copyWith =>
      __$$SanctionModelImplCopyWithImpl<_$SanctionModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SanctionModelImplToJson(this);
  }
}

abstract class _SanctionModel implements SanctionModel {
  const factory _SanctionModel({
    required final String id,
    @JsonKey(name: 'student_id') required final String studentId,
    @JsonKey(name: 'scope_type') required final String scopeType,
    @JsonKey(name: 'scope_id') required final String scopeId,
    @JsonKey(name: 'academic_term_id') required final String academicTermId,
    @JsonKey(name: 'total_absences') required final int totalAbsences,
    @JsonKey(name: 'required_item') required final String requiredItem,
    final String status,
    @JsonKey(name: 'received_by_user_id') final String? receivedByUserId,
    @JsonKey(name: 'received_at') final DateTime? receivedAt,
    @JsonKey(name: 'updated_at') final DateTime? updatedAt,
    @JsonKey(name: 'student_name') final String? studentName,
    @JsonKey(name: 'received_by_name') final String? receivedByName,
  }) = _$SanctionModelImpl;

  factory _SanctionModel.fromJson(Map<String, dynamic> json) =
      _$SanctionModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'student_id')
  String get studentId;
  @override
  @JsonKey(name: 'scope_type')
  String get scopeType;
  @override
  @JsonKey(name: 'scope_id')
  String get scopeId;
  @override
  @JsonKey(name: 'academic_term_id')
  String get academicTermId;
  @override
  @JsonKey(name: 'total_absences')
  int get totalAbsences;
  @override
  @JsonKey(name: 'required_item')
  String get requiredItem;
  @override
  String get status;
  @override
  @JsonKey(name: 'received_by_user_id')
  String? get receivedByUserId;
  @override
  @JsonKey(name: 'received_at')
  DateTime? get receivedAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt; // Join fields
  @override
  @JsonKey(name: 'student_name')
  String? get studentName;
  @override
  @JsonKey(name: 'received_by_name')
  String? get receivedByName;

  /// Create a copy of SanctionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SanctionModelImplCopyWith<_$SanctionModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
