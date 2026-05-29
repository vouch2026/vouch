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
  String? get id => throw _privateConstructorUsedError; // public.users.id
  @JsonKey(name: 'auth_id')
  String get authId => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  @JsonKey(name: 'first_name')
  String? get firstName => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_name')
  String? get lastName => throw _privateConstructorUsedError;
  @JsonKey(name: 'student_id_number')
  String get schoolId => throw _privateConstructorUsedError;
  @JsonKey(name: 'faculty_id')
  String? get facultyId => throw _privateConstructorUsedError;
  @JsonKey(name: 'program_id')
  String? get programId => throw _privateConstructorUsedError;
  @JsonKey(name: 'campus_id')
  String? get campusId => throw _privateConstructorUsedError;
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

  /// Derived or primary role
  String get role => throw _privateConstructorUsedError;
  @JsonKey(name: 'account_status')
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'joined_at')
  DateTime? get joinedAt => throw _privateConstructorUsedError; // Join fields (not in users table but useful for UI)
  String? get facultyName => throw _privateConstructorUsedError;
  String? get programName => throw _privateConstructorUsedError;

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
    String? id,
    @JsonKey(name: 'auth_id') String authId,
    String email,
    @JsonKey(name: 'first_name') String? firstName,
    @JsonKey(name: 'last_name') String? lastName,
    @JsonKey(name: 'student_id_number') String schoolId,
    @JsonKey(name: 'faculty_id') String? facultyId,
    @JsonKey(name: 'program_id') String? programId,
    @JsonKey(name: 'campus_id') String? campusId,
    @JsonKey(name: 'year') int? yearLevel,
    @JsonKey(name: 'profile_photo_url') String? avatarUrl,
    @JsonKey(name: 'id_front_url') String? idFrontUrl,
    @JsonKey(name: 'id_back_url') String? idBackUrl,
    @JsonKey(name: 'organization_ids') List<String> organizationIds,
    String role,
    @JsonKey(name: 'account_status') String status,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'joined_at') DateTime? joinedAt,
    String? facultyName,
    String? programName,
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
    Object? id = freezed,
    Object? authId = null,
    Object? email = null,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? schoolId = null,
    Object? facultyId = freezed,
    Object? programId = freezed,
    Object? campusId = freezed,
    Object? yearLevel = freezed,
    Object? avatarUrl = freezed,
    Object? idFrontUrl = freezed,
    Object? idBackUrl = freezed,
    Object? organizationIds = null,
    Object? role = null,
    Object? status = null,
    Object? createdAt = freezed,
    Object? joinedAt = freezed,
    Object? facultyName = freezed,
    Object? programName = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String?,
            authId: null == authId
                ? _value.authId
                : authId // ignore: cast_nullable_to_non_nullable
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
            schoolId: null == schoolId
                ? _value.schoolId
                : schoolId // ignore: cast_nullable_to_non_nullable
                      as String,
            facultyId: freezed == facultyId
                ? _value.facultyId
                : facultyId // ignore: cast_nullable_to_non_nullable
                      as String?,
            programId: freezed == programId
                ? _value.programId
                : programId // ignore: cast_nullable_to_non_nullable
                      as String?,
            campusId: freezed == campusId
                ? _value.campusId
                : campusId // ignore: cast_nullable_to_non_nullable
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
            joinedAt: freezed == joinedAt
                ? _value.joinedAt
                : joinedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            facultyName: freezed == facultyName
                ? _value.facultyName
                : facultyName // ignore: cast_nullable_to_non_nullable
                      as String?,
            programName: freezed == programName
                ? _value.programName
                : programName // ignore: cast_nullable_to_non_nullable
                      as String?,
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
    String? id,
    @JsonKey(name: 'auth_id') String authId,
    String email,
    @JsonKey(name: 'first_name') String? firstName,
    @JsonKey(name: 'last_name') String? lastName,
    @JsonKey(name: 'student_id_number') String schoolId,
    @JsonKey(name: 'faculty_id') String? facultyId,
    @JsonKey(name: 'program_id') String? programId,
    @JsonKey(name: 'campus_id') String? campusId,
    @JsonKey(name: 'year') int? yearLevel,
    @JsonKey(name: 'profile_photo_url') String? avatarUrl,
    @JsonKey(name: 'id_front_url') String? idFrontUrl,
    @JsonKey(name: 'id_back_url') String? idBackUrl,
    @JsonKey(name: 'organization_ids') List<String> organizationIds,
    String role,
    @JsonKey(name: 'account_status') String status,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'joined_at') DateTime? joinedAt,
    String? facultyName,
    String? programName,
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
    Object? id = freezed,
    Object? authId = null,
    Object? email = null,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? schoolId = null,
    Object? facultyId = freezed,
    Object? programId = freezed,
    Object? campusId = freezed,
    Object? yearLevel = freezed,
    Object? avatarUrl = freezed,
    Object? idFrontUrl = freezed,
    Object? idBackUrl = freezed,
    Object? organizationIds = null,
    Object? role = null,
    Object? status = null,
    Object? createdAt = freezed,
    Object? joinedAt = freezed,
    Object? facultyName = freezed,
    Object? programName = freezed,
  }) {
    return _then(
      _$UserModelImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String?,
        authId: null == authId
            ? _value.authId
            : authId // ignore: cast_nullable_to_non_nullable
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
        schoolId: null == schoolId
            ? _value.schoolId
            : schoolId // ignore: cast_nullable_to_non_nullable
                  as String,
        facultyId: freezed == facultyId
            ? _value.facultyId
            : facultyId // ignore: cast_nullable_to_non_nullable
                  as String?,
        programId: freezed == programId
            ? _value.programId
            : programId // ignore: cast_nullable_to_non_nullable
                  as String?,
        campusId: freezed == campusId
            ? _value.campusId
            : campusId // ignore: cast_nullable_to_non_nullable
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
        joinedAt: freezed == joinedAt
            ? _value.joinedAt
            : joinedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        facultyName: freezed == facultyName
            ? _value.facultyName
            : facultyName // ignore: cast_nullable_to_non_nullable
                  as String?,
        programName: freezed == programName
            ? _value.programName
            : programName // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserModelImpl extends _UserModel {
  const _$UserModelImpl({
    this.id,
    @JsonKey(name: 'auth_id') required this.authId,
    required this.email,
    @JsonKey(name: 'first_name') this.firstName,
    @JsonKey(name: 'last_name') this.lastName,
    @JsonKey(name: 'student_id_number') required this.schoolId,
    @JsonKey(name: 'faculty_id') this.facultyId,
    @JsonKey(name: 'program_id') this.programId,
    @JsonKey(name: 'campus_id') this.campusId,
    @JsonKey(name: 'year') this.yearLevel,
    @JsonKey(name: 'profile_photo_url') this.avatarUrl,
    @JsonKey(name: 'id_front_url') this.idFrontUrl,
    @JsonKey(name: 'id_back_url') this.idBackUrl,
    @JsonKey(name: 'organization_ids')
    final List<String> organizationIds = const [],
    this.role = 'student',
    @JsonKey(name: 'account_status') this.status = 'active',
    @JsonKey(name: 'created_at') this.createdAt,
    @JsonKey(name: 'joined_at') this.joinedAt,
    this.facultyName,
    this.programName,
  }) : _organizationIds = organizationIds,
       super._();

  factory _$UserModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserModelImplFromJson(json);

  @override
  final String? id;
  // public.users.id
  @override
  @JsonKey(name: 'auth_id')
  final String authId;
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
  final String schoolId;
  @override
  @JsonKey(name: 'faculty_id')
  final String? facultyId;
  @override
  @JsonKey(name: 'program_id')
  final String? programId;
  @override
  @JsonKey(name: 'campus_id')
  final String? campusId;
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

  /// Derived or primary role
  @override
  @JsonKey()
  final String role;
  @override
  @JsonKey(name: 'account_status')
  final String status;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'joined_at')
  final DateTime? joinedAt;
  // Join fields (not in users table but useful for UI)
  @override
  final String? facultyName;
  @override
  final String? programName;

  @override
  String toString() {
    return 'UserModel(id: $id, authId: $authId, email: $email, firstName: $firstName, lastName: $lastName, schoolId: $schoolId, facultyId: $facultyId, programId: $programId, campusId: $campusId, yearLevel: $yearLevel, avatarUrl: $avatarUrl, idFrontUrl: $idFrontUrl, idBackUrl: $idBackUrl, organizationIds: $organizationIds, role: $role, status: $status, createdAt: $createdAt, joinedAt: $joinedAt, facultyName: $facultyName, programName: $programName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.authId, authId) || other.authId == authId) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.schoolId, schoolId) ||
                other.schoolId == schoolId) &&
            (identical(other.facultyId, facultyId) ||
                other.facultyId == facultyId) &&
            (identical(other.programId, programId) ||
                other.programId == programId) &&
            (identical(other.campusId, campusId) ||
                other.campusId == campusId) &&
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
                other.createdAt == createdAt) &&
            (identical(other.joinedAt, joinedAt) ||
                other.joinedAt == joinedAt) &&
            (identical(other.facultyName, facultyName) ||
                other.facultyName == facultyName) &&
            (identical(other.programName, programName) ||
                other.programName == programName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    authId,
    email,
    firstName,
    lastName,
    schoolId,
    facultyId,
    programId,
    campusId,
    yearLevel,
    avatarUrl,
    idFrontUrl,
    idBackUrl,
    const DeepCollectionEquality().hash(_organizationIds),
    role,
    status,
    createdAt,
    joinedAt,
    facultyName,
    programName,
  ]);

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
    final String? id,
    @JsonKey(name: 'auth_id') required final String authId,
    required final String email,
    @JsonKey(name: 'first_name') final String? firstName,
    @JsonKey(name: 'last_name') final String? lastName,
    @JsonKey(name: 'student_id_number') required final String schoolId,
    @JsonKey(name: 'faculty_id') final String? facultyId,
    @JsonKey(name: 'program_id') final String? programId,
    @JsonKey(name: 'campus_id') final String? campusId,
    @JsonKey(name: 'year') final int? yearLevel,
    @JsonKey(name: 'profile_photo_url') final String? avatarUrl,
    @JsonKey(name: 'id_front_url') final String? idFrontUrl,
    @JsonKey(name: 'id_back_url') final String? idBackUrl,
    @JsonKey(name: 'organization_ids') final List<String> organizationIds,
    final String role,
    @JsonKey(name: 'account_status') final String status,
    @JsonKey(name: 'created_at') final DateTime? createdAt,
    @JsonKey(name: 'joined_at') final DateTime? joinedAt,
    final String? facultyName,
    final String? programName,
  }) = _$UserModelImpl;
  const _UserModel._() : super._();

  factory _UserModel.fromJson(Map<String, dynamic> json) =
      _$UserModelImpl.fromJson;

  @override
  String? get id; // public.users.id
  @override
  @JsonKey(name: 'auth_id')
  String get authId;
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
  String get schoolId;
  @override
  @JsonKey(name: 'faculty_id')
  String? get facultyId;
  @override
  @JsonKey(name: 'program_id')
  String? get programId;
  @override
  @JsonKey(name: 'campus_id')
  String? get campusId;
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

  /// Derived or primary role
  @override
  String get role;
  @override
  @JsonKey(name: 'account_status')
  String get status;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'joined_at')
  DateTime? get joinedAt; // Join fields (not in users table but useful for UI)
  @override
  String? get facultyName;
  @override
  String? get programName;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
