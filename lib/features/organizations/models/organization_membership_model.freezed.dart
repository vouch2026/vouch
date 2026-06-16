// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'organization_membership_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OrganizationMembershipModel {

 String get id;@JsonKey(name: 'organization_id') String get organizationId;@JsonKey(name: 'user_id') String get userId;@JsonKey(name: 'role_id') String? get roleId;@JsonKey(name: 'academic_term_id') String? get academicTermId; String get status;@JsonKey(name: 'assigned_at') DateTime? get assignedAt;@JsonKey(name: 'expired_at') DateTime? get expiredAt;@JsonKey(name: 'joined_at') DateTime? get joinedAt;@JsonKey(name: 'auto_sign_clearance') bool get autoSignClearance;// Join fields for UI
 UserModel? get user; AcademicTermModel? get term;@JsonKey(name: 'role_name') String? get roleName;@JsonKey(name: 'hierarchy_level') int? get hierarchyLevel; List<String> get permissions;
/// Create a copy of OrganizationMembershipModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrganizationMembershipModelCopyWith<OrganizationMembershipModel> get copyWith => _$OrganizationMembershipModelCopyWithImpl<OrganizationMembershipModel>(this as OrganizationMembershipModel, _$identity);

  /// Serializes this OrganizationMembershipModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrganizationMembershipModel&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.roleId, roleId) || other.roleId == roleId)&&(identical(other.academicTermId, academicTermId) || other.academicTermId == academicTermId)&&(identical(other.status, status) || other.status == status)&&(identical(other.assignedAt, assignedAt) || other.assignedAt == assignedAt)&&(identical(other.expiredAt, expiredAt) || other.expiredAt == expiredAt)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt)&&(identical(other.autoSignClearance, autoSignClearance) || other.autoSignClearance == autoSignClearance)&&(identical(other.user, user) || other.user == user)&&(identical(other.term, term) || other.term == term)&&(identical(other.roleName, roleName) || other.roleName == roleName)&&(identical(other.hierarchyLevel, hierarchyLevel) || other.hierarchyLevel == hierarchyLevel)&&const DeepCollectionEquality().equals(other.permissions, permissions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,organizationId,userId,roleId,academicTermId,status,assignedAt,expiredAt,joinedAt,autoSignClearance,user,term,roleName,hierarchyLevel,const DeepCollectionEquality().hash(permissions));

@override
String toString() {
  return 'OrganizationMembershipModel(id: $id, organizationId: $organizationId, userId: $userId, roleId: $roleId, academicTermId: $academicTermId, status: $status, assignedAt: $assignedAt, expiredAt: $expiredAt, joinedAt: $joinedAt, autoSignClearance: $autoSignClearance, user: $user, term: $term, roleName: $roleName, hierarchyLevel: $hierarchyLevel, permissions: $permissions)';
}


}

/// @nodoc
abstract mixin class $OrganizationMembershipModelCopyWith<$Res>  {
  factory $OrganizationMembershipModelCopyWith(OrganizationMembershipModel value, $Res Function(OrganizationMembershipModel) _then) = _$OrganizationMembershipModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'organization_id') String organizationId,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'role_id') String? roleId,@JsonKey(name: 'academic_term_id') String? academicTermId, String status,@JsonKey(name: 'assigned_at') DateTime? assignedAt,@JsonKey(name: 'expired_at') DateTime? expiredAt,@JsonKey(name: 'joined_at') DateTime? joinedAt,@JsonKey(name: 'auto_sign_clearance') bool autoSignClearance, UserModel? user, AcademicTermModel? term,@JsonKey(name: 'role_name') String? roleName,@JsonKey(name: 'hierarchy_level') int? hierarchyLevel, List<String> permissions
});


$UserModelCopyWith<$Res>? get user;$AcademicTermModelCopyWith<$Res>? get term;

}
/// @nodoc
class _$OrganizationMembershipModelCopyWithImpl<$Res>
    implements $OrganizationMembershipModelCopyWith<$Res> {
  _$OrganizationMembershipModelCopyWithImpl(this._self, this._then);

  final OrganizationMembershipModel _self;
  final $Res Function(OrganizationMembershipModel) _then;

/// Create a copy of OrganizationMembershipModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organizationId = null,Object? userId = null,Object? roleId = freezed,Object? academicTermId = freezed,Object? status = null,Object? assignedAt = freezed,Object? expiredAt = freezed,Object? joinedAt = freezed,Object? autoSignClearance = null,Object? user = freezed,Object? term = freezed,Object? roleName = freezed,Object? hierarchyLevel = freezed,Object? permissions = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,roleId: freezed == roleId ? _self.roleId : roleId // ignore: cast_nullable_to_non_nullable
as String?,academicTermId: freezed == academicTermId ? _self.academicTermId : academicTermId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,assignedAt: freezed == assignedAt ? _self.assignedAt : assignedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiredAt: freezed == expiredAt ? _self.expiredAt : expiredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,autoSignClearance: null == autoSignClearance ? _self.autoSignClearance : autoSignClearance // ignore: cast_nullable_to_non_nullable
as bool,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserModel?,term: freezed == term ? _self.term : term // ignore: cast_nullable_to_non_nullable
as AcademicTermModel?,roleName: freezed == roleName ? _self.roleName : roleName // ignore: cast_nullable_to_non_nullable
as String?,hierarchyLevel: freezed == hierarchyLevel ? _self.hierarchyLevel : hierarchyLevel // ignore: cast_nullable_to_non_nullable
as int?,permissions: null == permissions ? _self.permissions : permissions // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}
/// Create a copy of OrganizationMembershipModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserModelCopyWith<$Res>? get user {
    if (_self.user == null) {
    return null;
  }

  return $UserModelCopyWith<$Res>(_self.user!, (value) {
    return _then(_self.copyWith(user: value));
  });
}/// Create a copy of OrganizationMembershipModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AcademicTermModelCopyWith<$Res>? get term {
    if (_self.term == null) {
    return null;
  }

  return $AcademicTermModelCopyWith<$Res>(_self.term!, (value) {
    return _then(_self.copyWith(term: value));
  });
}
}


/// Adds pattern-matching-related methods to [OrganizationMembershipModel].
extension OrganizationMembershipModelPatterns on OrganizationMembershipModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrganizationMembershipModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrganizationMembershipModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrganizationMembershipModel value)  $default,){
final _that = this;
switch (_that) {
case _OrganizationMembershipModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrganizationMembershipModel value)?  $default,){
final _that = this;
switch (_that) {
case _OrganizationMembershipModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'role_id')  String? roleId, @JsonKey(name: 'academic_term_id')  String? academicTermId,  String status, @JsonKey(name: 'assigned_at')  DateTime? assignedAt, @JsonKey(name: 'expired_at')  DateTime? expiredAt, @JsonKey(name: 'joined_at')  DateTime? joinedAt, @JsonKey(name: 'auto_sign_clearance')  bool autoSignClearance,  UserModel? user,  AcademicTermModel? term, @JsonKey(name: 'role_name')  String? roleName, @JsonKey(name: 'hierarchy_level')  int? hierarchyLevel,  List<String> permissions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrganizationMembershipModel() when $default != null:
return $default(_that.id,_that.organizationId,_that.userId,_that.roleId,_that.academicTermId,_that.status,_that.assignedAt,_that.expiredAt,_that.joinedAt,_that.autoSignClearance,_that.user,_that.term,_that.roleName,_that.hierarchyLevel,_that.permissions);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'role_id')  String? roleId, @JsonKey(name: 'academic_term_id')  String? academicTermId,  String status, @JsonKey(name: 'assigned_at')  DateTime? assignedAt, @JsonKey(name: 'expired_at')  DateTime? expiredAt, @JsonKey(name: 'joined_at')  DateTime? joinedAt, @JsonKey(name: 'auto_sign_clearance')  bool autoSignClearance,  UserModel? user,  AcademicTermModel? term, @JsonKey(name: 'role_name')  String? roleName, @JsonKey(name: 'hierarchy_level')  int? hierarchyLevel,  List<String> permissions)  $default,) {final _that = this;
switch (_that) {
case _OrganizationMembershipModel():
return $default(_that.id,_that.organizationId,_that.userId,_that.roleId,_that.academicTermId,_that.status,_that.assignedAt,_that.expiredAt,_that.joinedAt,_that.autoSignClearance,_that.user,_that.term,_that.roleName,_that.hierarchyLevel,_that.permissions);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'role_id')  String? roleId, @JsonKey(name: 'academic_term_id')  String? academicTermId,  String status, @JsonKey(name: 'assigned_at')  DateTime? assignedAt, @JsonKey(name: 'expired_at')  DateTime? expiredAt, @JsonKey(name: 'joined_at')  DateTime? joinedAt, @JsonKey(name: 'auto_sign_clearance')  bool autoSignClearance,  UserModel? user,  AcademicTermModel? term, @JsonKey(name: 'role_name')  String? roleName, @JsonKey(name: 'hierarchy_level')  int? hierarchyLevel,  List<String> permissions)?  $default,) {final _that = this;
switch (_that) {
case _OrganizationMembershipModel() when $default != null:
return $default(_that.id,_that.organizationId,_that.userId,_that.roleId,_that.academicTermId,_that.status,_that.assignedAt,_that.expiredAt,_that.joinedAt,_that.autoSignClearance,_that.user,_that.term,_that.roleName,_that.hierarchyLevel,_that.permissions);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrganizationMembershipModel implements OrganizationMembershipModel {
  const _OrganizationMembershipModel({required this.id, @JsonKey(name: 'organization_id') required this.organizationId, @JsonKey(name: 'user_id') required this.userId, @JsonKey(name: 'role_id') this.roleId, @JsonKey(name: 'academic_term_id') this.academicTermId, this.status = 'active', @JsonKey(name: 'assigned_at') this.assignedAt, @JsonKey(name: 'expired_at') this.expiredAt, @JsonKey(name: 'joined_at') this.joinedAt, @JsonKey(name: 'auto_sign_clearance') this.autoSignClearance = false, this.user, this.term, @JsonKey(name: 'role_name') this.roleName, @JsonKey(name: 'hierarchy_level') this.hierarchyLevel, final  List<String> permissions = const []}): _permissions = permissions;
  factory _OrganizationMembershipModel.fromJson(Map<String, dynamic> json) => _$OrganizationMembershipModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'organization_id') final  String organizationId;
@override@JsonKey(name: 'user_id') final  String userId;
@override@JsonKey(name: 'role_id') final  String? roleId;
@override@JsonKey(name: 'academic_term_id') final  String? academicTermId;
@override@JsonKey() final  String status;
@override@JsonKey(name: 'assigned_at') final  DateTime? assignedAt;
@override@JsonKey(name: 'expired_at') final  DateTime? expiredAt;
@override@JsonKey(name: 'joined_at') final  DateTime? joinedAt;
@override@JsonKey(name: 'auto_sign_clearance') final  bool autoSignClearance;
// Join fields for UI
@override final  UserModel? user;
@override final  AcademicTermModel? term;
@override@JsonKey(name: 'role_name') final  String? roleName;
@override@JsonKey(name: 'hierarchy_level') final  int? hierarchyLevel;
 final  List<String> _permissions;
@override@JsonKey() List<String> get permissions {
  if (_permissions is EqualUnmodifiableListView) return _permissions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_permissions);
}


/// Create a copy of OrganizationMembershipModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrganizationMembershipModelCopyWith<_OrganizationMembershipModel> get copyWith => __$OrganizationMembershipModelCopyWithImpl<_OrganizationMembershipModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrganizationMembershipModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrganizationMembershipModel&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.roleId, roleId) || other.roleId == roleId)&&(identical(other.academicTermId, academicTermId) || other.academicTermId == academicTermId)&&(identical(other.status, status) || other.status == status)&&(identical(other.assignedAt, assignedAt) || other.assignedAt == assignedAt)&&(identical(other.expiredAt, expiredAt) || other.expiredAt == expiredAt)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt)&&(identical(other.autoSignClearance, autoSignClearance) || other.autoSignClearance == autoSignClearance)&&(identical(other.user, user) || other.user == user)&&(identical(other.term, term) || other.term == term)&&(identical(other.roleName, roleName) || other.roleName == roleName)&&(identical(other.hierarchyLevel, hierarchyLevel) || other.hierarchyLevel == hierarchyLevel)&&const DeepCollectionEquality().equals(other._permissions, _permissions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,organizationId,userId,roleId,academicTermId,status,assignedAt,expiredAt,joinedAt,autoSignClearance,user,term,roleName,hierarchyLevel,const DeepCollectionEquality().hash(_permissions));

@override
String toString() {
  return 'OrganizationMembershipModel(id: $id, organizationId: $organizationId, userId: $userId, roleId: $roleId, academicTermId: $academicTermId, status: $status, assignedAt: $assignedAt, expiredAt: $expiredAt, joinedAt: $joinedAt, autoSignClearance: $autoSignClearance, user: $user, term: $term, roleName: $roleName, hierarchyLevel: $hierarchyLevel, permissions: $permissions)';
}


}

/// @nodoc
abstract mixin class _$OrganizationMembershipModelCopyWith<$Res> implements $OrganizationMembershipModelCopyWith<$Res> {
  factory _$OrganizationMembershipModelCopyWith(_OrganizationMembershipModel value, $Res Function(_OrganizationMembershipModel) _then) = __$OrganizationMembershipModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'organization_id') String organizationId,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'role_id') String? roleId,@JsonKey(name: 'academic_term_id') String? academicTermId, String status,@JsonKey(name: 'assigned_at') DateTime? assignedAt,@JsonKey(name: 'expired_at') DateTime? expiredAt,@JsonKey(name: 'joined_at') DateTime? joinedAt,@JsonKey(name: 'auto_sign_clearance') bool autoSignClearance, UserModel? user, AcademicTermModel? term,@JsonKey(name: 'role_name') String? roleName,@JsonKey(name: 'hierarchy_level') int? hierarchyLevel, List<String> permissions
});


@override $UserModelCopyWith<$Res>? get user;@override $AcademicTermModelCopyWith<$Res>? get term;

}
/// @nodoc
class __$OrganizationMembershipModelCopyWithImpl<$Res>
    implements _$OrganizationMembershipModelCopyWith<$Res> {
  __$OrganizationMembershipModelCopyWithImpl(this._self, this._then);

  final _OrganizationMembershipModel _self;
  final $Res Function(_OrganizationMembershipModel) _then;

/// Create a copy of OrganizationMembershipModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organizationId = null,Object? userId = null,Object? roleId = freezed,Object? academicTermId = freezed,Object? status = null,Object? assignedAt = freezed,Object? expiredAt = freezed,Object? joinedAt = freezed,Object? autoSignClearance = null,Object? user = freezed,Object? term = freezed,Object? roleName = freezed,Object? hierarchyLevel = freezed,Object? permissions = null,}) {
  return _then(_OrganizationMembershipModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,roleId: freezed == roleId ? _self.roleId : roleId // ignore: cast_nullable_to_non_nullable
as String?,academicTermId: freezed == academicTermId ? _self.academicTermId : academicTermId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,assignedAt: freezed == assignedAt ? _self.assignedAt : assignedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiredAt: freezed == expiredAt ? _self.expiredAt : expiredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,autoSignClearance: null == autoSignClearance ? _self.autoSignClearance : autoSignClearance // ignore: cast_nullable_to_non_nullable
as bool,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserModel?,term: freezed == term ? _self.term : term // ignore: cast_nullable_to_non_nullable
as AcademicTermModel?,roleName: freezed == roleName ? _self.roleName : roleName // ignore: cast_nullable_to_non_nullable
as String?,hierarchyLevel: freezed == hierarchyLevel ? _self.hierarchyLevel : hierarchyLevel // ignore: cast_nullable_to_non_nullable
as int?,permissions: null == permissions ? _self._permissions : permissions // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

/// Create a copy of OrganizationMembershipModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserModelCopyWith<$Res>? get user {
    if (_self.user == null) {
    return null;
  }

  return $UserModelCopyWith<$Res>(_self.user!, (value) {
    return _then(_self.copyWith(user: value));
  });
}/// Create a copy of OrganizationMembershipModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AcademicTermModelCopyWith<$Res>? get term {
    if (_self.term == null) {
    return null;
  }

  return $AcademicTermModelCopyWith<$Res>(_self.term!, (value) {
    return _then(_self.copyWith(term: value));
  });
}
}

// dart format on
