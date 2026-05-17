// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'instructor_profile_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

InstructorProfileModel _$InstructorProfileModelFromJson(
  Map<String, dynamic> json,
) {
  return _InstructorProfileModel.fromJson(json);
}

/// @nodoc
mixin _$InstructorProfileModel {
  String get userId => throw _privateConstructorUsedError;
  String get instructorId => throw _privateConstructorUsedError;
  String? get campusId => throw _privateConstructorUsedError;
  String? get campusName => throw _privateConstructorUsedError;
  String? get facultyId => throw _privateConstructorUsedError;
  String? get facultyName => throw _privateConstructorUsedError;
  String get position => throw _privateConstructorUsedError;
  String? get assignedProgramId => throw _privateConstructorUsedError;
  String? get assignedProgramName => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  List<OrgMembershipModel> get memberships =>
      throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this InstructorProfileModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of InstructorProfileModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InstructorProfileModelCopyWith<InstructorProfileModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InstructorProfileModelCopyWith<$Res> {
  factory $InstructorProfileModelCopyWith(
    InstructorProfileModel value,
    $Res Function(InstructorProfileModel) then,
  ) = _$InstructorProfileModelCopyWithImpl<$Res, InstructorProfileModel>;
  @useResult
  $Res call({
    String userId,
    String instructorId,
    String? campusId,
    String? campusName,
    String? facultyId,
    String? facultyName,
    String position,
    String? assignedProgramId,
    String? assignedProgramName,
    String status,
    List<OrgMembershipModel> memberships,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$InstructorProfileModelCopyWithImpl<
  $Res,
  $Val extends InstructorProfileModel
>
    implements $InstructorProfileModelCopyWith<$Res> {
  _$InstructorProfileModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InstructorProfileModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? instructorId = null,
    Object? campusId = freezed,
    Object? campusName = freezed,
    Object? facultyId = freezed,
    Object? facultyName = freezed,
    Object? position = null,
    Object? assignedProgramId = freezed,
    Object? assignedProgramName = freezed,
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
            instructorId: null == instructorId
                ? _value.instructorId
                : instructorId // ignore: cast_nullable_to_non_nullable
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
            position: null == position
                ? _value.position
                : position // ignore: cast_nullable_to_non_nullable
                      as String,
            assignedProgramId: freezed == assignedProgramId
                ? _value.assignedProgramId
                : assignedProgramId // ignore: cast_nullable_to_non_nullable
                      as String?,
            assignedProgramName: freezed == assignedProgramName
                ? _value.assignedProgramName
                : assignedProgramName // ignore: cast_nullable_to_non_nullable
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
abstract class _$$InstructorProfileModelImplCopyWith<$Res>
    implements $InstructorProfileModelCopyWith<$Res> {
  factory _$$InstructorProfileModelImplCopyWith(
    _$InstructorProfileModelImpl value,
    $Res Function(_$InstructorProfileModelImpl) then,
  ) = __$$InstructorProfileModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    String instructorId,
    String? campusId,
    String? campusName,
    String? facultyId,
    String? facultyName,
    String position,
    String? assignedProgramId,
    String? assignedProgramName,
    String status,
    List<OrgMembershipModel> memberships,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$InstructorProfileModelImplCopyWithImpl<$Res>
    extends
        _$InstructorProfileModelCopyWithImpl<$Res, _$InstructorProfileModelImpl>
    implements _$$InstructorProfileModelImplCopyWith<$Res> {
  __$$InstructorProfileModelImplCopyWithImpl(
    _$InstructorProfileModelImpl _value,
    $Res Function(_$InstructorProfileModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of InstructorProfileModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? instructorId = null,
    Object? campusId = freezed,
    Object? campusName = freezed,
    Object? facultyId = freezed,
    Object? facultyName = freezed,
    Object? position = null,
    Object? assignedProgramId = freezed,
    Object? assignedProgramName = freezed,
    Object? status = null,
    Object? memberships = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$InstructorProfileModelImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        instructorId: null == instructorId
            ? _value.instructorId
            : instructorId // ignore: cast_nullable_to_non_nullable
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
        position: null == position
            ? _value.position
            : position // ignore: cast_nullable_to_non_nullable
                  as String,
        assignedProgramId: freezed == assignedProgramId
            ? _value.assignedProgramId
            : assignedProgramId // ignore: cast_nullable_to_non_nullable
                  as String?,
        assignedProgramName: freezed == assignedProgramName
            ? _value.assignedProgramName
            : assignedProgramName // ignore: cast_nullable_to_non_nullable
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
class _$InstructorProfileModelImpl implements _InstructorProfileModel {
  const _$InstructorProfileModelImpl({
    required this.userId,
    required this.instructorId,
    this.campusId,
    this.campusName,
    this.facultyId,
    this.facultyName,
    this.position = 'instructor',
    this.assignedProgramId,
    this.assignedProgramName,
    this.status = 'active',
    final List<OrgMembershipModel> memberships = const [],
    this.createdAt,
  }) : _memberships = memberships;

  factory _$InstructorProfileModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$InstructorProfileModelImplFromJson(json);

  @override
  final String userId;
  @override
  final String instructorId;
  @override
  final String? campusId;
  @override
  final String? campusName;
  @override
  final String? facultyId;
  @override
  final String? facultyName;
  @override
  @JsonKey()
  final String position;
  @override
  final String? assignedProgramId;
  @override
  final String? assignedProgramName;
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
    return 'InstructorProfileModel(userId: $userId, instructorId: $instructorId, campusId: $campusId, campusName: $campusName, facultyId: $facultyId, facultyName: $facultyName, position: $position, assignedProgramId: $assignedProgramId, assignedProgramName: $assignedProgramName, status: $status, memberships: $memberships, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InstructorProfileModelImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.instructorId, instructorId) ||
                other.instructorId == instructorId) &&
            (identical(other.campusId, campusId) ||
                other.campusId == campusId) &&
            (identical(other.campusName, campusName) ||
                other.campusName == campusName) &&
            (identical(other.facultyId, facultyId) ||
                other.facultyId == facultyId) &&
            (identical(other.facultyName, facultyName) ||
                other.facultyName == facultyName) &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.assignedProgramId, assignedProgramId) ||
                other.assignedProgramId == assignedProgramId) &&
            (identical(other.assignedProgramName, assignedProgramName) ||
                other.assignedProgramName == assignedProgramName) &&
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
    instructorId,
    campusId,
    campusName,
    facultyId,
    facultyName,
    position,
    assignedProgramId,
    assignedProgramName,
    status,
    const DeepCollectionEquality().hash(_memberships),
    createdAt,
  );

  /// Create a copy of InstructorProfileModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InstructorProfileModelImplCopyWith<_$InstructorProfileModelImpl>
  get copyWith =>
      __$$InstructorProfileModelImplCopyWithImpl<_$InstructorProfileModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$InstructorProfileModelImplToJson(this);
  }
}

abstract class _InstructorProfileModel implements InstructorProfileModel {
  const factory _InstructorProfileModel({
    required final String userId,
    required final String instructorId,
    final String? campusId,
    final String? campusName,
    final String? facultyId,
    final String? facultyName,
    final String position,
    final String? assignedProgramId,
    final String? assignedProgramName,
    final String status,
    final List<OrgMembershipModel> memberships,
    final DateTime? createdAt,
  }) = _$InstructorProfileModelImpl;

  factory _InstructorProfileModel.fromJson(Map<String, dynamic> json) =
      _$InstructorProfileModelImpl.fromJson;

  @override
  String get userId;
  @override
  String get instructorId;
  @override
  String? get campusId;
  @override
  String? get campusName;
  @override
  String? get facultyId;
  @override
  String? get facultyName;
  @override
  String get position;
  @override
  String? get assignedProgramId;
  @override
  String? get assignedProgramName;
  @override
  String get status;
  @override
  List<OrgMembershipModel> get memberships;
  @override
  DateTime? get createdAt;

  /// Create a copy of InstructorProfileModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InstructorProfileModelImplCopyWith<_$InstructorProfileModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
