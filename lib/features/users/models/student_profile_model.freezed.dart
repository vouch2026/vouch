// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'student_profile_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

StudentProfileModel _$StudentProfileModelFromJson(Map<String, dynamic> json) {
  return _StudentProfileModel.fromJson(json);
}

/// @nodoc
mixin _$StudentProfileModel {
  String get userId => throw _privateConstructorUsedError;
  String get studentNumber => throw _privateConstructorUsedError;
  String? get campusId => throw _privateConstructorUsedError;
  String? get campusName => throw _privateConstructorUsedError;
  String? get facultyId => throw _privateConstructorUsedError;
  String? get facultyName => throw _privateConstructorUsedError;
  String? get programId => throw _privateConstructorUsedError;
  String? get programName => throw _privateConstructorUsedError;
  int get yearLevel => throw _privateConstructorUsedError;
  String? get academicYear => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  List<OrgMembershipModel> get memberships =>
      throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this StudentProfileModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StudentProfileModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StudentProfileModelCopyWith<StudentProfileModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StudentProfileModelCopyWith<$Res> {
  factory $StudentProfileModelCopyWith(
    StudentProfileModel value,
    $Res Function(StudentProfileModel) then,
  ) = _$StudentProfileModelCopyWithImpl<$Res, StudentProfileModel>;
  @useResult
  $Res call({
    String userId,
    String studentNumber,
    String? campusId,
    String? campusName,
    String? facultyId,
    String? facultyName,
    String? programId,
    String? programName,
    int yearLevel,
    String? academicYear,
    String status,
    List<OrgMembershipModel> memberships,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$StudentProfileModelCopyWithImpl<$Res, $Val extends StudentProfileModel>
    implements $StudentProfileModelCopyWith<$Res> {
  _$StudentProfileModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StudentProfileModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? studentNumber = null,
    Object? campusId = freezed,
    Object? campusName = freezed,
    Object? facultyId = freezed,
    Object? facultyName = freezed,
    Object? programId = freezed,
    Object? programName = freezed,
    Object? yearLevel = null,
    Object? academicYear = freezed,
    Object? status = null,
    Object? memberships = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            studentNumber: null == studentNumber
                ? _value.studentNumber
                : studentNumber // ignore: cast_nullable_to_non_nullable
                      as String,
            campusId: freezed == campusId
                ? _value.campusId
                : campusId // ignore: cast_nullable_to_non_nullable
                      as String?,
            campusName: freezed == campusName
                ? _value.campusName
                : campusName // ignore: cast_nullable_to_non_nullable
                      as String?,
            facultyId: freezed == facultyId
                ? _value.facultyId
                : facultyId // ignore: cast_nullable_to_non_nullable
                      as String?,
            facultyName: freezed == facultyName
                ? _value.facultyName
                : facultyName // ignore: cast_nullable_to_non_nullable
                      as String?,
            programId: freezed == programId
                ? _value.programId
                : programId // ignore: cast_nullable_to_non_nullable
                      as String?,
            programName: freezed == programName
                ? _value.programName
                : programName // ignore: cast_nullable_to_non_nullable
                      as String?,
            yearLevel: null == yearLevel
                ? _value.yearLevel
                : yearLevel // ignore: cast_nullable_to_non_nullable
                      as int,
            academicYear: freezed == academicYear
                ? _value.academicYear
                : academicYear // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            memberships: null == memberships
                ? _value.memberships
                : memberships // ignore: cast_nullable_to_non_nullable
                      as List<OrgMembershipModel>,
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
abstract class _$$StudentProfileModelImplCopyWith<$Res>
    implements $StudentProfileModelCopyWith<$Res> {
  factory _$$StudentProfileModelImplCopyWith(
    _$StudentProfileModelImpl value,
    $Res Function(_$StudentProfileModelImpl) then,
  ) = __$$StudentProfileModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    String studentNumber,
    String? campusId,
    String? campusName,
    String? facultyId,
    String? facultyName,
    String? programId,
    String? programName,
    int yearLevel,
    String? academicYear,
    String status,
    List<OrgMembershipModel> memberships,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$StudentProfileModelImplCopyWithImpl<$Res>
    extends _$StudentProfileModelCopyWithImpl<$Res, _$StudentProfileModelImpl>
    implements _$$StudentProfileModelImplCopyWith<$Res> {
  __$$StudentProfileModelImplCopyWithImpl(
    _$StudentProfileModelImpl _value,
    $Res Function(_$StudentProfileModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StudentProfileModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? studentNumber = null,
    Object? campusId = freezed,
    Object? campusName = freezed,
    Object? facultyId = freezed,
    Object? facultyName = freezed,
    Object? programId = freezed,
    Object? programName = freezed,
    Object? yearLevel = null,
    Object? academicYear = freezed,
    Object? status = null,
    Object? memberships = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$StudentProfileModelImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        studentNumber: null == studentNumber
            ? _value.studentNumber
            : studentNumber // ignore: cast_nullable_to_non_nullable
                  as String,
        campusId: freezed == campusId
            ? _value.campusId
            : campusId // ignore: cast_nullable_to_non_nullable
                  as String?,
        campusName: freezed == campusName
            ? _value.campusName
            : campusName // ignore: cast_nullable_to_non_nullable
                  as String?,
        facultyId: freezed == facultyId
            ? _value.facultyId
            : facultyId // ignore: cast_nullable_to_non_nullable
                  as String?,
        facultyName: freezed == facultyName
            ? _value.facultyName
            : facultyName // ignore: cast_nullable_to_non_nullable
                  as String?,
        programId: freezed == programId
            ? _value.programId
            : programId // ignore: cast_nullable_to_non_nullable
                  as String?,
        programName: freezed == programName
            ? _value.programName
            : programName // ignore: cast_nullable_to_non_nullable
                  as String?,
        yearLevel: null == yearLevel
            ? _value.yearLevel
            : yearLevel // ignore: cast_nullable_to_non_nullable
                  as int,
        academicYear: freezed == academicYear
            ? _value.academicYear
            : academicYear // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        memberships: null == memberships
            ? _value._memberships
            : memberships // ignore: cast_nullable_to_non_nullable
                  as List<OrgMembershipModel>,
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
class _$StudentProfileModelImpl implements _StudentProfileModel {
  const _$StudentProfileModelImpl({
    required this.userId,
    required this.studentNumber,
    this.campusId,
    this.campusName,
    this.facultyId,
    this.facultyName,
    this.programId,
    this.programName,
    required this.yearLevel,
    this.academicYear,
    this.status = 'pending',
    final List<OrgMembershipModel> memberships = const [],
    this.createdAt,
  }) : _memberships = memberships;

  factory _$StudentProfileModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$StudentProfileModelImplFromJson(json);

  @override
  final String userId;
  @override
  final String studentNumber;
  @override
  final String? campusId;
  @override
  final String? campusName;
  @override
  final String? facultyId;
  @override
  final String? facultyName;
  @override
  final String? programId;
  @override
  final String? programName;
  @override
  final int yearLevel;
  @override
  final String? academicYear;
  @override
  @JsonKey()
  final String status;
  final List<OrgMembershipModel> _memberships;
  @override
  @JsonKey()
  List<OrgMembershipModel> get memberships {
    if (_memberships is EqualUnmodifiableListView) return _memberships;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_memberships);
  }

  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'StudentProfileModel(userId: $userId, studentNumber: $studentNumber, campusId: $campusId, campusName: $campusName, facultyId: $facultyId, facultyName: $facultyName, programId: $programId, programName: $programName, yearLevel: $yearLevel, academicYear: $academicYear, status: $status, memberships: $memberships, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StudentProfileModelImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.studentNumber, studentNumber) ||
                other.studentNumber == studentNumber) &&
            (identical(other.campusId, campusId) ||
                other.campusId == campusId) &&
            (identical(other.campusName, campusName) ||
                other.campusName == campusName) &&
            (identical(other.facultyId, facultyId) ||
                other.facultyId == facultyId) &&
            (identical(other.facultyName, facultyName) ||
                other.facultyName == facultyName) &&
            (identical(other.programId, programId) ||
                other.programId == programId) &&
            (identical(other.programName, programName) ||
                other.programName == programName) &&
            (identical(other.yearLevel, yearLevel) ||
                other.yearLevel == yearLevel) &&
            (identical(other.academicYear, academicYear) ||
                other.academicYear == academicYear) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(
              other._memberships,
              _memberships,
            ) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    userId,
    studentNumber,
    campusId,
    campusName,
    facultyId,
    facultyName,
    programId,
    programName,
    yearLevel,
    academicYear,
    status,
    const DeepCollectionEquality().hash(_memberships),
    createdAt,
  );

  /// Create a copy of StudentProfileModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StudentProfileModelImplCopyWith<_$StudentProfileModelImpl> get copyWith =>
      __$$StudentProfileModelImplCopyWithImpl<_$StudentProfileModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$StudentProfileModelImplToJson(this);
  }
}

abstract class _StudentProfileModel implements StudentProfileModel {
  const factory _StudentProfileModel({
    required final String userId,
    required final String studentNumber,
    final String? campusId,
    final String? campusName,
    final String? facultyId,
    final String? facultyName,
    final String? programId,
    final String? programName,
    required final int yearLevel,
    final String? academicYear,
    final String status,
    final List<OrgMembershipModel> memberships,
    final DateTime? createdAt,
  }) = _$StudentProfileModelImpl;

  factory _StudentProfileModel.fromJson(Map<String, dynamic> json) =
      _$StudentProfileModelImpl.fromJson;

  @override
  String get userId;
  @override
  String get studentNumber;
  @override
  String? get campusId;
  @override
  String? get campusName;
  @override
  String? get facultyId;
  @override
  String? get facultyName;
  @override
  String? get programId;
  @override
  String? get programName;
  @override
  int get yearLevel;
  @override
  String? get academicYear;
  @override
  String get status;
  @override
  List<OrgMembershipModel> get memberships;
  @override
  DateTime? get createdAt;

  /// Create a copy of StudentProfileModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StudentProfileModelImplCopyWith<_$StudentProfileModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
