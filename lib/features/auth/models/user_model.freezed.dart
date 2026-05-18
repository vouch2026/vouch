// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UserModel _$UserModelFromJson(Map<String, dynamic> json) {
  return _UserModel.fromJson(json);
}

/// @nodoc
mixin _$UserModel {
  @JsonKey(name: 'auth_id')
  String get id => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  @JsonKey(name: 'first_name')
  String? get firstName => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_name')
  String? get lastName => throw _privateConstructorUsedError;
  @JsonKey(name: 'student_id_number')
  String? get schoolId => throw _privateConstructorUsedError;
  @JsonKey(name: 'faculty_id')
  String? get faculty => throw _privateConstructorUsedError;
  @JsonKey(name: 'program_id')
  String? get program => throw _privateConstructorUsedError;
  @JsonKey(name: 'year')
  int? get yearLevel => throw _privateConstructorUsedError;
  @JsonKey(name: 'profile_photo_url')
  String? get avatarUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'id_front_url')
  String? get idFrontUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'id_back_url')
  String? get idBackUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'organization_ids')
  List<String> get organizationIds => throw _privateConstructorUsedError;

  /// Role of the user. See [UserRole] for possible values.
  /// Default roles include: super_admin, student, etc.
  String get role => throw _privateConstructorUsedError;

  /// Status of the account. See [UserStatus] for possible values.
  /// Default statuses include: pending, approved, etc.
  @JsonKey(name: 'account_status')
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserModelCopyWith<UserModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserModelCopyWith<$Res> {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) then) =
      _$UserModelCopyWithImpl<$Res, UserModel>;
  @useResult
  $Res call({
    @JsonKey(name: 'auth_id') String id,
    String email,
    @JsonKey(name: 'first_name') String? firstName,
    @JsonKey(name: 'last_name') String? lastName,
    @JsonKey(name: 'student_id_number') String? schoolId,
    @JsonKey(name: 'faculty_id') String? faculty,
    @JsonKey(name: 'program_id') String? program,
    @JsonKey(name: 'year') int? yearLevel,
    @JsonKey(name: 'profile_photo_url') String? avatarUrl,
    @JsonKey(name: 'id_front_url') String? idFrontUrl,
    @JsonKey(name: 'id_back_url') String? idBackUrl,
    @JsonKey(name: 'organization_ids') List<String> organizationIds,
    String role,
    @JsonKey(name: 'account_status') String status,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  });
}

/// @nodoc
class _$UserModelCopyWithImpl<$Res, $Val extends UserModel>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? schoolId = freezed,
    Object? faculty = freezed,
    Object? program = freezed,
    Object? yearLevel = freezed,
    Object? avatarUrl = freezed,
    Object? idFrontUrl = freezed,
    Object? idBackUrl = freezed,
    Object? organizationIds = null,
    Object? role = null,
    Object? status = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            firstName: freezed == firstName
                ? _value.firstName
                : firstName // ignore: cast_nullable_to_non_nullable
                      as String?,
            lastName: freezed == lastName
                ? _value.lastName
                : lastName // ignore: cast_nullable_to_non_nullable
                      as String?,
            schoolId: freezed == schoolId
                ? _value.schoolId
                : schoolId // ignore: cast_nullable_to_non_nullable
                      as String?,
            faculty: freezed == faculty
                ? _value.faculty
                : faculty // ignore: cast_nullable_to_non_nullable
                      as String?,
            program: freezed == program
                ? _value.program
                : program // ignore: cast_nullable_to_non_nullable
                      as String?,
            yearLevel: freezed == yearLevel
                ? _value.yearLevel
                : yearLevel // ignore: cast_nullable_to_non_nullable
                      as int?,
            avatarUrl: freezed == avatarUrl
                ? _value.avatarUrl
                : avatarUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            idFrontUrl: freezed == idFrontUrl
                ? _value.idFrontUrl
                : idFrontUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            idBackUrl: freezed == idBackUrl
                ? _value.idBackUrl
                : idBackUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            organizationIds: null == organizationIds
                ? _value.organizationIds
                : organizationIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            role: null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
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
abstract class _$$UserModelImplCopyWith<$Res>
    implements $UserModelCopyWith<$Res> {
  factory _$$UserModelImplCopyWith(
    _$UserModelImpl value,
    $Res Function(_$UserModelImpl) then,
  ) = __$$UserModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'auth_id') String id,
    String email,
    @JsonKey(name: 'first_name') String? firstName,
    @JsonKey(name: 'last_name') String? lastName,
    @JsonKey(name: 'student_id_number') String? schoolId,
    @JsonKey(name: 'faculty_id') String? faculty,
    @JsonKey(name: 'program_id') String? program,
    @JsonKey(name: 'year') int? yearLevel,
    @JsonKey(name: 'profile_photo_url') String? avatarUrl,
    @JsonKey(name: 'id_front_url') String? idFrontUrl,
    @JsonKey(name: 'id_back_url') String? idBackUrl,
    @JsonKey(name: 'organization_ids') List<String> organizationIds,
    String role,
    @JsonKey(name: 'account_status') String status,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  });
}

/// @nodoc
class __$$UserModelImplCopyWithImpl<$Res>
    extends _$UserModelCopyWithImpl<$Res, _$UserModelImpl>
    implements _$$UserModelImplCopyWith<$Res> {
  __$$UserModelImplCopyWithImpl(
    _$UserModelImpl _value,
    $Res Function(_$UserModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? schoolId = freezed,
    Object? faculty = freezed,
    Object? program = freezed,
    Object? yearLevel = freezed,
    Object? avatarUrl = freezed,
    Object? idFrontUrl = freezed,
    Object? idBackUrl = freezed,
    Object? organizationIds = null,
    Object? role = null,
    Object? status = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$UserModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        firstName: freezed == firstName
            ? _value.firstName
            : firstName // ignore: cast_nullable_to_non_nullable
                  as String?,
        lastName: freezed == lastName
            ? _value.lastName
            : lastName // ignore: cast_nullable_to_non_nullable
                  as String?,
        schoolId: freezed == schoolId
            ? _value.schoolId
            : schoolId // ignore: cast_nullable_to_non_nullable
                  as String?,
        faculty: freezed == faculty
            ? _value.faculty
            : faculty // ignore: cast_nullable_to_non_nullable
                  as String?,
        program: freezed == program
            ? _value.program
            : program // ignore: cast_nullable_to_non_nullable
                  as String?,
        yearLevel: freezed == yearLevel
            ? _value.yearLevel
            : yearLevel // ignore: cast_nullable_to_non_nullable
                  as int?,
        avatarUrl: freezed == avatarUrl
            ? _value.avatarUrl
            : avatarUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        idFrontUrl: freezed == idFrontUrl
            ? _value.idFrontUrl
            : idFrontUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        idBackUrl: freezed == idBackUrl
            ? _value.idBackUrl
            : idBackUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        organizationIds: null == organizationIds
            ? _value._organizationIds
            : organizationIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
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
class _$UserModelImpl extends _UserModel {
  const _$UserModelImpl({
    @JsonKey(name: 'auth_id') required this.id,
    required this.email,
    @JsonKey(name: 'first_name') this.firstName,
    @JsonKey(name: 'last_name') this.lastName,
    @JsonKey(name: 'student_id_number') this.schoolId,
    @JsonKey(name: 'faculty_id') this.faculty,
    @JsonKey(name: 'program_id') this.program,
    @JsonKey(name: 'year') this.yearLevel,
    @JsonKey(name: 'profile_photo_url') this.avatarUrl,
    @JsonKey(name: 'id_front_url') this.idFrontUrl,
    @JsonKey(name: 'id_back_url') this.idBackUrl,
    @JsonKey(name: 'organization_ids')
    final List<String> organizationIds = const [],
    this.role = 'student',
    @JsonKey(name: 'account_status') this.status = 'active',
    @JsonKey(name: 'created_at') this.createdAt,
  }) : _organizationIds = organizationIds,
       super._();

  factory _$UserModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserModelImplFromJson(json);

  @override
  @JsonKey(name: 'auth_id')
  final String id;
  @override
  final String email;
  @override
  @JsonKey(name: 'first_name')
  final String? firstName;
  @override
  @JsonKey(name: 'last_name')
  final String? lastName;
  @override
  @JsonKey(name: 'student_id_number')
  final String? schoolId;
  @override
  @JsonKey(name: 'faculty_id')
  final String? faculty;
  @override
  @JsonKey(name: 'program_id')
  final String? program;
  @override
  @JsonKey(name: 'year')
  final int? yearLevel;
  @override
  @JsonKey(name: 'profile_photo_url')
  final String? avatarUrl;
  @override
  @JsonKey(name: 'id_front_url')
  final String? idFrontUrl;
  @override
  @JsonKey(name: 'id_back_url')
  final String? idBackUrl;
  final List<String> _organizationIds;
  @override
  @JsonKey(name: 'organization_ids')
  List<String> get organizationIds {
    if (_organizationIds is EqualUnmodifiableListView) return _organizationIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_organizationIds);
  }

  /// Role of the user. See [UserRole] for possible values.
  /// Default roles include: super_admin, student, etc.
  @override
  @JsonKey()
  final String role;

  /// Status of the account. See [UserStatus] for possible values.
  /// Default statuses include: pending, approved, etc.
  @override
  @JsonKey(name: 'account_status')
  final String status;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, firstName: $firstName, lastName: $lastName, schoolId: $schoolId, faculty: $faculty, program: $program, yearLevel: $yearLevel, avatarUrl: $avatarUrl, idFrontUrl: $idFrontUrl, idBackUrl: $idBackUrl, organizationIds: $organizationIds, role: $role, status: $status, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.schoolId, schoolId) ||
                other.schoolId == schoolId) &&
            (identical(other.faculty, faculty) || other.faculty == faculty) &&
            (identical(other.program, program) || other.program == program) &&
            (identical(other.yearLevel, yearLevel) ||
                other.yearLevel == yearLevel) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.idFrontUrl, idFrontUrl) ||
                other.idFrontUrl == idFrontUrl) &&
            (identical(other.idBackUrl, idBackUrl) ||
                other.idBackUrl == idBackUrl) &&
            const DeepCollectionEquality().equals(
              other._organizationIds,
              _organizationIds,
            ) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    email,
    firstName,
    lastName,
    schoolId,
    faculty,
    program,
    yearLevel,
    avatarUrl,
    idFrontUrl,
    idBackUrl,
    const DeepCollectionEquality().hash(_organizationIds),
    role,
    status,
    createdAt,
  );

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      __$$UserModelImplCopyWithImpl<_$UserModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserModelImplToJson(this);
  }
}

abstract class _UserModel extends UserModel {
  const factory _UserModel({
    @JsonKey(name: 'auth_id') required final String id,
    required final String email,
    @JsonKey(name: 'first_name') final String? firstName,
    @JsonKey(name: 'last_name') final String? lastName,
    @JsonKey(name: 'student_id_number') final String? schoolId,
    @JsonKey(name: 'faculty_id') final String? faculty,
    @JsonKey(name: 'program_id') final String? program,
    @JsonKey(name: 'year') final int? yearLevel,
    @JsonKey(name: 'profile_photo_url') final String? avatarUrl,
    @JsonKey(name: 'id_front_url') final String? idFrontUrl,
    @JsonKey(name: 'id_back_url') final String? idBackUrl,
    @JsonKey(name: 'organization_ids') final List<String> organizationIds,
    final String role,
    @JsonKey(name: 'account_status') final String status,
    @JsonKey(name: 'created_at') final DateTime? createdAt,
  }) = _$UserModelImpl;
  const _UserModel._() : super._();

  factory _UserModel.fromJson(Map<String, dynamic> json) =
      _$UserModelImpl.fromJson;

  @override
  @JsonKey(name: 'auth_id')
  String get id;
  @override
  String get email;
  @override
  @JsonKey(name: 'first_name')
  String? get firstName;
  @override
  @JsonKey(name: 'last_name')
  String? get lastName;
  @override
  @JsonKey(name: 'student_id_number')
  String? get schoolId;
  @override
  @JsonKey(name: 'faculty_id')
  String? get faculty;
  @override
  @JsonKey(name: 'program_id')
  String? get program;
  @override
  @JsonKey(name: 'year')
  int? get yearLevel;
  @override
  @JsonKey(name: 'profile_photo_url')
  String? get avatarUrl;
  @override
  @JsonKey(name: 'id_front_url')
  String? get idFrontUrl;
  @override
  @JsonKey(name: 'id_back_url')
  String? get idBackUrl;
  @override
  @JsonKey(name: 'organization_ids')
  List<String> get organizationIds;

  /// Role of the user. See [UserRole] for possible values.
  /// Default roles include: super_admin, student, etc.
  @override
  String get role;

  /// Status of the account. See [UserStatus] for possible values.
  /// Default statuses include: pending, approved, etc.
  @override
  @JsonKey(name: 'account_status')
  String get status;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
