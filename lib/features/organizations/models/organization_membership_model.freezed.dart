// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'organization_membership_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

OrganizationMembershipModel _$OrganizationMembershipModelFromJson(
  Map<String, dynamic> json,
) {
  return _OrganizationMembershipModel.fromJson(json);
}

/// @nodoc
mixin _$OrganizationMembershipModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'organization_id')
  String get organizationId => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'role_id')
  String? get roleId => throw _privateConstructorUsedError;
  @JsonKey(name: 'academic_term_id')
  String? get academicTermId => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'assigned_at')
  DateTime? get assignedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'expired_at')
  DateTime? get expiredAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'joined_at')
  DateTime? get joinedAt => throw _privateConstructorUsedError; // Join fields for UI
  UserModel? get user => throw _privateConstructorUsedError;
  AcademicTermModel? get term => throw _privateConstructorUsedError;
  @JsonKey(name: 'role_name')
  String? get roleName => throw _privateConstructorUsedError;
  @JsonKey(name: 'hierarchy_level')
  int? get hierarchyLevel => throw _privateConstructorUsedError;
  List<String> get permissions => throw _privateConstructorUsedError;

  /// Serializes this OrganizationMembershipModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OrganizationMembershipModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrganizationMembershipModelCopyWith<OrganizationMembershipModel>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrganizationMembershipModelCopyWith<$Res> {
  factory $OrganizationMembershipModelCopyWith(
    OrganizationMembershipModel value,
    $Res Function(OrganizationMembershipModel) then,
  ) =
      _$OrganizationMembershipModelCopyWithImpl<
        $Res,
        OrganizationMembershipModel
      >;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'organization_id') String organizationId,
    @JsonKey(name: 'user_id') String userId,
    @JsonKey(name: 'role_id') String? roleId,
    @JsonKey(name: 'academic_term_id') String? academicTermId,
    String status,
    @JsonKey(name: 'assigned_at') DateTime? assignedAt,
    @JsonKey(name: 'expired_at') DateTime? expiredAt,
    @JsonKey(name: 'joined_at') DateTime? joinedAt,
    UserModel? user,
    AcademicTermModel? term,
    @JsonKey(name: 'role_name') String? roleName,
    @JsonKey(name: 'hierarchy_level') int? hierarchyLevel,
    List<String> permissions,
  });

  $UserModelCopyWith<$Res>? get user;
  $AcademicTermModelCopyWith<$Res>? get term;
}

/// @nodoc
class _$OrganizationMembershipModelCopyWithImpl<
  $Res,
  $Val extends OrganizationMembershipModel
>
    implements $OrganizationMembershipModelCopyWith<$Res> {
  _$OrganizationMembershipModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrganizationMembershipModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? organizationId = null,
    Object? userId = null,
    Object? roleId = freezed,
    Object? academicTermId = freezed,
    Object? status = null,
    Object? assignedAt = freezed,
    Object? expiredAt = freezed,
    Object? joinedAt = freezed,
    Object? user = freezed,
    Object? term = freezed,
    Object? roleName = freezed,
    Object? hierarchyLevel = freezed,
    Object? permissions = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            organizationId: null == organizationId
                ? _value.organizationId
                : organizationId // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            roleId: freezed == roleId
                ? _value.roleId
                : roleId // ignore: cast_nullable_to_non_nullable
                      as String?,
            academicTermId: freezed == academicTermId
                ? _value.academicTermId
                : academicTermId // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            assignedAt: freezed == assignedAt
                ? _value.assignedAt
                : assignedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            expiredAt: freezed == expiredAt
                ? _value.expiredAt
                : expiredAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            joinedAt: freezed == joinedAt
                ? _value.joinedAt
                : joinedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            user: freezed == user
                ? _value.user
                : user // ignore: cast_nullable_to_non_nullable
                      as UserModel?,
            term: freezed == term
                ? _value.term
                : term // ignore: cast_nullable_to_non_nullable
                      as AcademicTermModel?,
            roleName: freezed == roleName
                ? _value.roleName
                : roleName // ignore: cast_nullable_to_non_nullable
                      as String?,
            hierarchyLevel: freezed == hierarchyLevel
                ? _value.hierarchyLevel
                : hierarchyLevel // ignore: cast_nullable_to_non_nullable
                      as int?,
            permissions: null == permissions
                ? _value.permissions
                : permissions // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }

  /// Create a copy of OrganizationMembershipModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserModelCopyWith<$Res>? get user {
    if (_value.user == null) {
      return null;
    }

    return $UserModelCopyWith<$Res>(_value.user!, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }

  /// Create a copy of OrganizationMembershipModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AcademicTermModelCopyWith<$Res>? get term {
    if (_value.term == null) {
      return null;
    }

    return $AcademicTermModelCopyWith<$Res>(_value.term!, (value) {
      return _then(_value.copyWith(term: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$OrganizationMembershipModelImplCopyWith<$Res>
    implements $OrganizationMembershipModelCopyWith<$Res> {
  factory _$$OrganizationMembershipModelImplCopyWith(
    _$OrganizationMembershipModelImpl value,
    $Res Function(_$OrganizationMembershipModelImpl) then,
  ) = __$$OrganizationMembershipModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'organization_id') String organizationId,
    @JsonKey(name: 'user_id') String userId,
    @JsonKey(name: 'role_id') String? roleId,
    @JsonKey(name: 'academic_term_id') String? academicTermId,
    String status,
    @JsonKey(name: 'assigned_at') DateTime? assignedAt,
    @JsonKey(name: 'expired_at') DateTime? expiredAt,
    @JsonKey(name: 'joined_at') DateTime? joinedAt,
    UserModel? user,
    AcademicTermModel? term,
    @JsonKey(name: 'role_name') String? roleName,
    @JsonKey(name: 'hierarchy_level') int? hierarchyLevel,
    List<String> permissions,
  });

  @override
  $UserModelCopyWith<$Res>? get user;
  @override
  $AcademicTermModelCopyWith<$Res>? get term;
}

/// @nodoc
class __$$OrganizationMembershipModelImplCopyWithImpl<$Res>
    extends
        _$OrganizationMembershipModelCopyWithImpl<
          $Res,
          _$OrganizationMembershipModelImpl
        >
    implements _$$OrganizationMembershipModelImplCopyWith<$Res> {
  __$$OrganizationMembershipModelImplCopyWithImpl(
    _$OrganizationMembershipModelImpl _value,
    $Res Function(_$OrganizationMembershipModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OrganizationMembershipModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? organizationId = null,
    Object? userId = null,
    Object? roleId = freezed,
    Object? academicTermId = freezed,
    Object? status = null,
    Object? assignedAt = freezed,
    Object? expiredAt = freezed,
    Object? joinedAt = freezed,
    Object? user = freezed,
    Object? term = freezed,
    Object? roleName = freezed,
    Object? hierarchyLevel = freezed,
    Object? permissions = null,
  }) {
    return _then(
      _$OrganizationMembershipModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        organizationId: null == organizationId
            ? _value.organizationId
            : organizationId // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        roleId: freezed == roleId
            ? _value.roleId
            : roleId // ignore: cast_nullable_to_non_nullable
                  as String?,
        academicTermId: freezed == academicTermId
            ? _value.academicTermId
            : academicTermId // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        assignedAt: freezed == assignedAt
            ? _value.assignedAt
            : assignedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        expiredAt: freezed == expiredAt
            ? _value.expiredAt
            : expiredAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        joinedAt: freezed == joinedAt
            ? _value.joinedAt
            : joinedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        user: freezed == user
            ? _value.user
            : user // ignore: cast_nullable_to_non_nullable
                  as UserModel?,
        term: freezed == term
            ? _value.term
            : term // ignore: cast_nullable_to_non_nullable
                  as AcademicTermModel?,
        roleName: freezed == roleName
            ? _value.roleName
            : roleName // ignore: cast_nullable_to_non_nullable
                  as String?,
        hierarchyLevel: freezed == hierarchyLevel
            ? _value.hierarchyLevel
            : hierarchyLevel // ignore: cast_nullable_to_non_nullable
                  as int?,
        permissions: null == permissions
            ? _value._permissions
            : permissions // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OrganizationMembershipModelImpl
    implements _OrganizationMembershipModel {
  const _$OrganizationMembershipModelImpl({
    required this.id,
    @JsonKey(name: 'organization_id') required this.organizationId,
    @JsonKey(name: 'user_id') required this.userId,
    @JsonKey(name: 'role_id') this.roleId,
    @JsonKey(name: 'academic_term_id') this.academicTermId,
    this.status = 'active',
    @JsonKey(name: 'assigned_at') this.assignedAt,
    @JsonKey(name: 'expired_at') this.expiredAt,
    @JsonKey(name: 'joined_at') this.joinedAt,
    this.user,
    this.term,
    @JsonKey(name: 'role_name') this.roleName,
    @JsonKey(name: 'hierarchy_level') this.hierarchyLevel,
    final List<String> permissions = const [],
  }) : _permissions = permissions;

  factory _$OrganizationMembershipModelImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$OrganizationMembershipModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'organization_id')
  final String organizationId;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  @JsonKey(name: 'role_id')
  final String? roleId;
  @override
  @JsonKey(name: 'academic_term_id')
  final String? academicTermId;
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey(name: 'assigned_at')
  final DateTime? assignedAt;
  @override
  @JsonKey(name: 'expired_at')
  final DateTime? expiredAt;
  @override
  @JsonKey(name: 'joined_at')
  final DateTime? joinedAt;
  // Join fields for UI
  @override
  final UserModel? user;
  @override
  final AcademicTermModel? term;
  @override
  @JsonKey(name: 'role_name')
  final String? roleName;
  @override
  @JsonKey(name: 'hierarchy_level')
  final int? hierarchyLevel;
  final List<String> _permissions;
  @override
  @JsonKey()
  List<String> get permissions {
    if (_permissions is EqualUnmodifiableListView) return _permissions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_permissions);
  }

  @override
  String toString() {
    return 'OrganizationMembershipModel(id: $id, organizationId: $organizationId, userId: $userId, roleId: $roleId, academicTermId: $academicTermId, status: $status, assignedAt: $assignedAt, expiredAt: $expiredAt, joinedAt: $joinedAt, user: $user, term: $term, roleName: $roleName, hierarchyLevel: $hierarchyLevel, permissions: $permissions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrganizationMembershipModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.organizationId, organizationId) ||
                other.organizationId == organizationId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.roleId, roleId) || other.roleId == roleId) &&
            (identical(other.academicTermId, academicTermId) ||
                other.academicTermId == academicTermId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.assignedAt, assignedAt) ||
                other.assignedAt == assignedAt) &&
            (identical(other.expiredAt, expiredAt) ||
                other.expiredAt == expiredAt) &&
            (identical(other.joinedAt, joinedAt) ||
                other.joinedAt == joinedAt) &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.term, term) || other.term == term) &&
            (identical(other.roleName, roleName) ||
                other.roleName == roleName) &&
            (identical(other.hierarchyLevel, hierarchyLevel) ||
                other.hierarchyLevel == hierarchyLevel) &&
            const DeepCollectionEquality().equals(
              other._permissions,
              _permissions,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    organizationId,
    userId,
    roleId,
    academicTermId,
    status,
    assignedAt,
    expiredAt,
    joinedAt,
    user,
    term,
    roleName,
    hierarchyLevel,
    const DeepCollectionEquality().hash(_permissions),
  );

  /// Create a copy of OrganizationMembershipModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrganizationMembershipModelImplCopyWith<_$OrganizationMembershipModelImpl>
  get copyWith =>
      __$$OrganizationMembershipModelImplCopyWithImpl<
        _$OrganizationMembershipModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OrganizationMembershipModelImplToJson(this);
  }
}

abstract class _OrganizationMembershipModel
    implements OrganizationMembershipModel {
  const factory _OrganizationMembershipModel({
    required final String id,
    @JsonKey(name: 'organization_id') required final String organizationId,
    @JsonKey(name: 'user_id') required final String userId,
    @JsonKey(name: 'role_id') final String? roleId,
    @JsonKey(name: 'academic_term_id') final String? academicTermId,
    final String status,
    @JsonKey(name: 'assigned_at') final DateTime? assignedAt,
    @JsonKey(name: 'expired_at') final DateTime? expiredAt,
    @JsonKey(name: 'joined_at') final DateTime? joinedAt,
    final UserModel? user,
    final AcademicTermModel? term,
    @JsonKey(name: 'role_name') final String? roleName,
    @JsonKey(name: 'hierarchy_level') final int? hierarchyLevel,
    final List<String> permissions,
  }) = _$OrganizationMembershipModelImpl;

  factory _OrganizationMembershipModel.fromJson(Map<String, dynamic> json) =
      _$OrganizationMembershipModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'organization_id')
  String get organizationId;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  @JsonKey(name: 'role_id')
  String? get roleId;
  @override
  @JsonKey(name: 'academic_term_id')
  String? get academicTermId;
  @override
  String get status;
  @override
  @JsonKey(name: 'assigned_at')
  DateTime? get assignedAt;
  @override
  @JsonKey(name: 'expired_at')
  DateTime? get expiredAt;
  @override
  @JsonKey(name: 'joined_at')
  DateTime? get joinedAt; // Join fields for UI
  @override
  UserModel? get user;
  @override
  AcademicTermModel? get term;
  @override
  @JsonKey(name: 'role_name')
  String? get roleName;
  @override
  @JsonKey(name: 'hierarchy_level')
  int? get hierarchyLevel;
  @override
  List<String> get permissions;

  /// Create a copy of OrganizationMembershipModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrganizationMembershipModelImplCopyWith<_$OrganizationMembershipModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
