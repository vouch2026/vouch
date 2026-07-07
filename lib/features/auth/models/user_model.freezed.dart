// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserModel {

 String? get id;// public.users.id
@JsonKey(name: 'auth_id') String get authId; String get email;@JsonKey(name: 'first_name') String? get firstName;@JsonKey(name: 'last_name') String? get lastName;@JsonKey(name: 'student_id_number') String get schoolId;@JsonKey(name: 'faculty_id') String? get facultyId;@JsonKey(name: 'program_id') String? get programId;@JsonKey(name: 'campus_id') String? get campusId;@JsonKey(name: 'year') int? get yearLevel;@JsonKey(name: 'profile_photo_url') String? get avatarUrl;@JsonKey(name: 'organization_ids') List<String> get organizationIds;/// Derived or primary role
 String get role;@JsonKey(name: 'account_status') String get status;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'joined_at') DateTime? get joinedAt;// Join fields (not in users table but useful for UI)
 String? get facultyName; String? get programName;
/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserModelCopyWith<UserModel> get copyWith => _$UserModelCopyWithImpl<UserModel>(this as UserModel, _$identity);

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserModel&&(identical(other.id, id) || other.id == id)&&(identical(other.authId, authId) || other.authId == authId)&&(identical(other.email, email) || other.email == email)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.schoolId, schoolId) || other.schoolId == schoolId)&&(identical(other.facultyId, facultyId) || other.facultyId == facultyId)&&(identical(other.programId, programId) || other.programId == programId)&&(identical(other.campusId, campusId) || other.campusId == campusId)&&(identical(other.yearLevel, yearLevel) || other.yearLevel == yearLevel)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&const DeepCollectionEquality().equals(other.organizationIds, organizationIds)&&(identical(other.role, role) || other.role == role)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt)&&(identical(other.facultyName, facultyName) || other.facultyName == facultyName)&&(identical(other.programName, programName) || other.programName == programName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,authId,email,firstName,lastName,schoolId,facultyId,programId,campusId,yearLevel,avatarUrl,const DeepCollectionEquality().hash(organizationIds),role,status,createdAt,joinedAt,facultyName,programName);

@override
String toString() {
  return 'UserModel(id: $id, authId: $authId, email: $email, firstName: $firstName, lastName: $lastName, schoolId: $schoolId, facultyId: $facultyId, programId: $programId, campusId: $campusId, yearLevel: $yearLevel, avatarUrl: $avatarUrl, organizationIds: $organizationIds, role: $role, status: $status, createdAt: $createdAt, joinedAt: $joinedAt, facultyName: $facultyName, programName: $programName)';
}


}

/// @nodoc
abstract mixin class $UserModelCopyWith<$Res>  {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) _then) = _$UserModelCopyWithImpl;
@useResult
$Res call({
 String? id,@JsonKey(name: 'auth_id') String authId, String email,@JsonKey(name: 'first_name') String? firstName,@JsonKey(name: 'last_name') String? lastName,@JsonKey(name: 'student_id_number') String schoolId,@JsonKey(name: 'faculty_id') String? facultyId,@JsonKey(name: 'program_id') String? programId,@JsonKey(name: 'campus_id') String? campusId,@JsonKey(name: 'year') int? yearLevel,@JsonKey(name: 'profile_photo_url') String? avatarUrl,@JsonKey(name: 'organization_ids') List<String> organizationIds, String role,@JsonKey(name: 'account_status') String status,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'joined_at') DateTime? joinedAt, String? facultyName, String? programName
});




}
/// @nodoc
class _$UserModelCopyWithImpl<$Res>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._self, this._then);

  final UserModel _self;
  final $Res Function(UserModel) _then;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? authId = null,Object? email = null,Object? firstName = freezed,Object? lastName = freezed,Object? schoolId = null,Object? facultyId = freezed,Object? programId = freezed,Object? campusId = freezed,Object? yearLevel = freezed,Object? avatarUrl = freezed,Object? organizationIds = null,Object? role = null,Object? status = null,Object? createdAt = freezed,Object? joinedAt = freezed,Object? facultyName = freezed,Object? programName = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,authId: null == authId ? _self.authId : authId // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,schoolId: null == schoolId ? _self.schoolId : schoolId // ignore: cast_nullable_to_non_nullable
as String,facultyId: freezed == facultyId ? _self.facultyId : facultyId // ignore: cast_nullable_to_non_nullable
as String?,programId: freezed == programId ? _self.programId : programId // ignore: cast_nullable_to_non_nullable
as String?,campusId: freezed == campusId ? _self.campusId : campusId // ignore: cast_nullable_to_non_nullable
as String?,yearLevel: freezed == yearLevel ? _self.yearLevel : yearLevel // ignore: cast_nullable_to_non_nullable
as int?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,organizationIds: null == organizationIds ? _self.organizationIds : organizationIds // ignore: cast_nullable_to_non_nullable
as List<String>,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,facultyName: freezed == facultyName ? _self.facultyName : facultyName // ignore: cast_nullable_to_non_nullable
as String?,programName: freezed == programName ? _self.programName : programName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserModel].
extension UserModelPatterns on UserModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserModel value)  $default,){
final _that = this;
switch (_that) {
case _UserModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserModel value)?  $default,){
final _that = this;
switch (_that) {
case _UserModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'auth_id')  String authId,  String email, @JsonKey(name: 'first_name')  String? firstName, @JsonKey(name: 'last_name')  String? lastName, @JsonKey(name: 'student_id_number')  String schoolId, @JsonKey(name: 'faculty_id')  String? facultyId, @JsonKey(name: 'program_id')  String? programId, @JsonKey(name: 'campus_id')  String? campusId, @JsonKey(name: 'year')  int? yearLevel, @JsonKey(name: 'profile_photo_url')  String? avatarUrl, @JsonKey(name: 'organization_ids')  List<String> organizationIds,  String role, @JsonKey(name: 'account_status')  String status, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'joined_at')  DateTime? joinedAt,  String? facultyName,  String? programName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that.id,_that.authId,_that.email,_that.firstName,_that.lastName,_that.schoolId,_that.facultyId,_that.programId,_that.campusId,_that.yearLevel,_that.avatarUrl,_that.organizationIds,_that.role,_that.status,_that.createdAt,_that.joinedAt,_that.facultyName,_that.programName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'auth_id')  String authId,  String email, @JsonKey(name: 'first_name')  String? firstName, @JsonKey(name: 'last_name')  String? lastName, @JsonKey(name: 'student_id_number')  String schoolId, @JsonKey(name: 'faculty_id')  String? facultyId, @JsonKey(name: 'program_id')  String? programId, @JsonKey(name: 'campus_id')  String? campusId, @JsonKey(name: 'year')  int? yearLevel, @JsonKey(name: 'profile_photo_url')  String? avatarUrl, @JsonKey(name: 'organization_ids')  List<String> organizationIds,  String role, @JsonKey(name: 'account_status')  String status, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'joined_at')  DateTime? joinedAt,  String? facultyName,  String? programName)  $default,) {final _that = this;
switch (_that) {
case _UserModel():
return $default(_that.id,_that.authId,_that.email,_that.firstName,_that.lastName,_that.schoolId,_that.facultyId,_that.programId,_that.campusId,_that.yearLevel,_that.avatarUrl,_that.organizationIds,_that.role,_that.status,_that.createdAt,_that.joinedAt,_that.facultyName,_that.programName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id, @JsonKey(name: 'auth_id')  String authId,  String email, @JsonKey(name: 'first_name')  String? firstName, @JsonKey(name: 'last_name')  String? lastName, @JsonKey(name: 'student_id_number')  String schoolId, @JsonKey(name: 'faculty_id')  String? facultyId, @JsonKey(name: 'program_id')  String? programId, @JsonKey(name: 'campus_id')  String? campusId, @JsonKey(name: 'year')  int? yearLevel, @JsonKey(name: 'profile_photo_url')  String? avatarUrl, @JsonKey(name: 'organization_ids')  List<String> organizationIds,  String role, @JsonKey(name: 'account_status')  String status, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'joined_at')  DateTime? joinedAt,  String? facultyName,  String? programName)?  $default,) {final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that.id,_that.authId,_that.email,_that.firstName,_that.lastName,_that.schoolId,_that.facultyId,_that.programId,_that.campusId,_that.yearLevel,_that.avatarUrl,_that.organizationIds,_that.role,_that.status,_that.createdAt,_that.joinedAt,_that.facultyName,_that.programName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserModel extends UserModel {
  const _UserModel({this.id, @JsonKey(name: 'auth_id') required this.authId, required this.email, @JsonKey(name: 'first_name') this.firstName, @JsonKey(name: 'last_name') this.lastName, @JsonKey(name: 'student_id_number') required this.schoolId, @JsonKey(name: 'faculty_id') this.facultyId, @JsonKey(name: 'program_id') this.programId, @JsonKey(name: 'campus_id') this.campusId, @JsonKey(name: 'year') this.yearLevel, @JsonKey(name: 'profile_photo_url') this.avatarUrl, @JsonKey(name: 'organization_ids') final  List<String> organizationIds = const [], this.role = 'student', @JsonKey(name: 'account_status') this.status = 'active', @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'joined_at') this.joinedAt, this.facultyName, this.programName}): _organizationIds = organizationIds,super._();
  factory _UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

@override final  String? id;
// public.users.id
@override@JsonKey(name: 'auth_id') final  String authId;
@override final  String email;
@override@JsonKey(name: 'first_name') final  String? firstName;
@override@JsonKey(name: 'last_name') final  String? lastName;
@override@JsonKey(name: 'student_id_number') final  String schoolId;
@override@JsonKey(name: 'faculty_id') final  String? facultyId;
@override@JsonKey(name: 'program_id') final  String? programId;
@override@JsonKey(name: 'campus_id') final  String? campusId;
@override@JsonKey(name: 'year') final  int? yearLevel;
@override@JsonKey(name: 'profile_photo_url') final  String? avatarUrl;
 final  List<String> _organizationIds;
@override@JsonKey(name: 'organization_ids') List<String> get organizationIds {
  if (_organizationIds is EqualUnmodifiableListView) return _organizationIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_organizationIds);
}

/// Derived or primary role
@override@JsonKey() final  String role;
@override@JsonKey(name: 'account_status') final  String status;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'joined_at') final  DateTime? joinedAt;
// Join fields (not in users table but useful for UI)
@override final  String? facultyName;
@override final  String? programName;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserModelCopyWith<_UserModel> get copyWith => __$UserModelCopyWithImpl<_UserModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserModel&&(identical(other.id, id) || other.id == id)&&(identical(other.authId, authId) || other.authId == authId)&&(identical(other.email, email) || other.email == email)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.schoolId, schoolId) || other.schoolId == schoolId)&&(identical(other.facultyId, facultyId) || other.facultyId == facultyId)&&(identical(other.programId, programId) || other.programId == programId)&&(identical(other.campusId, campusId) || other.campusId == campusId)&&(identical(other.yearLevel, yearLevel) || other.yearLevel == yearLevel)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&const DeepCollectionEquality().equals(other._organizationIds, _organizationIds)&&(identical(other.role, role) || other.role == role)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt)&&(identical(other.facultyName, facultyName) || other.facultyName == facultyName)&&(identical(other.programName, programName) || other.programName == programName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,authId,email,firstName,lastName,schoolId,facultyId,programId,campusId,yearLevel,avatarUrl,const DeepCollectionEquality().hash(_organizationIds),role,status,createdAt,joinedAt,facultyName,programName);

@override
String toString() {
  return 'UserModel(id: $id, authId: $authId, email: $email, firstName: $firstName, lastName: $lastName, schoolId: $schoolId, facultyId: $facultyId, programId: $programId, campusId: $campusId, yearLevel: $yearLevel, avatarUrl: $avatarUrl, organizationIds: $organizationIds, role: $role, status: $status, createdAt: $createdAt, joinedAt: $joinedAt, facultyName: $facultyName, programName: $programName)';
}


}

/// @nodoc
abstract mixin class _$UserModelCopyWith<$Res> implements $UserModelCopyWith<$Res> {
  factory _$UserModelCopyWith(_UserModel value, $Res Function(_UserModel) _then) = __$UserModelCopyWithImpl;
@override @useResult
$Res call({
 String? id,@JsonKey(name: 'auth_id') String authId, String email,@JsonKey(name: 'first_name') String? firstName,@JsonKey(name: 'last_name') String? lastName,@JsonKey(name: 'student_id_number') String schoolId,@JsonKey(name: 'faculty_id') String? facultyId,@JsonKey(name: 'program_id') String? programId,@JsonKey(name: 'campus_id') String? campusId,@JsonKey(name: 'year') int? yearLevel,@JsonKey(name: 'profile_photo_url') String? avatarUrl,@JsonKey(name: 'organization_ids') List<String> organizationIds, String role,@JsonKey(name: 'account_status') String status,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'joined_at') DateTime? joinedAt, String? facultyName, String? programName
});




}
/// @nodoc
class __$UserModelCopyWithImpl<$Res>
    implements _$UserModelCopyWith<$Res> {
  __$UserModelCopyWithImpl(this._self, this._then);

  final _UserModel _self;
  final $Res Function(_UserModel) _then;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? authId = null,Object? email = null,Object? firstName = freezed,Object? lastName = freezed,Object? schoolId = null,Object? facultyId = freezed,Object? programId = freezed,Object? campusId = freezed,Object? yearLevel = freezed,Object? avatarUrl = freezed,Object? organizationIds = null,Object? role = null,Object? status = null,Object? createdAt = freezed,Object? joinedAt = freezed,Object? facultyName = freezed,Object? programName = freezed,}) {
  return _then(_UserModel(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,authId: null == authId ? _self.authId : authId // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,schoolId: null == schoolId ? _self.schoolId : schoolId // ignore: cast_nullable_to_non_nullable
as String,facultyId: freezed == facultyId ? _self.facultyId : facultyId // ignore: cast_nullable_to_non_nullable
as String?,programId: freezed == programId ? _self.programId : programId // ignore: cast_nullable_to_non_nullable
as String?,campusId: freezed == campusId ? _self.campusId : campusId // ignore: cast_nullable_to_non_nullable
as String?,yearLevel: freezed == yearLevel ? _self.yearLevel : yearLevel // ignore: cast_nullable_to_non_nullable
as int?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,organizationIds: null == organizationIds ? _self._organizationIds : organizationIds // ignore: cast_nullable_to_non_nullable
as List<String>,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,facultyName: freezed == facultyName ? _self.facultyName : facultyName // ignore: cast_nullable_to_non_nullable
as String?,programName: freezed == programName ? _self.programName : programName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
