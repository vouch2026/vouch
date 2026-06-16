// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'org_membership_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OrgMembershipModel {

 String get organizationId; String get organizationName; String get role; DateTime? get joinedAt; bool get isCurrent; String? get positionTitle;
/// Create a copy of OrgMembershipModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrgMembershipModelCopyWith<OrgMembershipModel> get copyWith => _$OrgMembershipModelCopyWithImpl<OrgMembershipModel>(this as OrgMembershipModel, _$identity);

  /// Serializes this OrgMembershipModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrgMembershipModel&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.organizationName, organizationName) || other.organizationName == organizationName)&&(identical(other.role, role) || other.role == role)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt)&&(identical(other.isCurrent, isCurrent) || other.isCurrent == isCurrent)&&(identical(other.positionTitle, positionTitle) || other.positionTitle == positionTitle));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,organizationId,organizationName,role,joinedAt,isCurrent,positionTitle);

@override
String toString() {
  return 'OrgMembershipModel(organizationId: $organizationId, organizationName: $organizationName, role: $role, joinedAt: $joinedAt, isCurrent: $isCurrent, positionTitle: $positionTitle)';
}


}

/// @nodoc
abstract mixin class $OrgMembershipModelCopyWith<$Res>  {
  factory $OrgMembershipModelCopyWith(OrgMembershipModel value, $Res Function(OrgMembershipModel) _then) = _$OrgMembershipModelCopyWithImpl;
@useResult
$Res call({
 String organizationId, String organizationName, String role, DateTime? joinedAt, bool isCurrent, String? positionTitle
});




}
/// @nodoc
class _$OrgMembershipModelCopyWithImpl<$Res>
    implements $OrgMembershipModelCopyWith<$Res> {
  _$OrgMembershipModelCopyWithImpl(this._self, this._then);

  final OrgMembershipModel _self;
  final $Res Function(OrgMembershipModel) _then;

/// Create a copy of OrgMembershipModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? organizationId = null,Object? organizationName = null,Object? role = null,Object? joinedAt = freezed,Object? isCurrent = null,Object? positionTitle = freezed,}) {
  return _then(_self.copyWith(
organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,organizationName: null == organizationName ? _self.organizationName : organizationName // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isCurrent: null == isCurrent ? _self.isCurrent : isCurrent // ignore: cast_nullable_to_non_nullable
as bool,positionTitle: freezed == positionTitle ? _self.positionTitle : positionTitle // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [OrgMembershipModel].
extension OrgMembershipModelPatterns on OrgMembershipModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrgMembershipModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrgMembershipModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrgMembershipModel value)  $default,){
final _that = this;
switch (_that) {
case _OrgMembershipModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrgMembershipModel value)?  $default,){
final _that = this;
switch (_that) {
case _OrgMembershipModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String organizationId,  String organizationName,  String role,  DateTime? joinedAt,  bool isCurrent,  String? positionTitle)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrgMembershipModel() when $default != null:
return $default(_that.organizationId,_that.organizationName,_that.role,_that.joinedAt,_that.isCurrent,_that.positionTitle);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String organizationId,  String organizationName,  String role,  DateTime? joinedAt,  bool isCurrent,  String? positionTitle)  $default,) {final _that = this;
switch (_that) {
case _OrgMembershipModel():
return $default(_that.organizationId,_that.organizationName,_that.role,_that.joinedAt,_that.isCurrent,_that.positionTitle);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String organizationId,  String organizationName,  String role,  DateTime? joinedAt,  bool isCurrent,  String? positionTitle)?  $default,) {final _that = this;
switch (_that) {
case _OrgMembershipModel() when $default != null:
return $default(_that.organizationId,_that.organizationName,_that.role,_that.joinedAt,_that.isCurrent,_that.positionTitle);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrgMembershipModel implements OrgMembershipModel {
  const _OrgMembershipModel({required this.organizationId, required this.organizationName, required this.role, this.joinedAt, this.isCurrent = true, this.positionTitle});
  factory _OrgMembershipModel.fromJson(Map<String, dynamic> json) => _$OrgMembershipModelFromJson(json);

@override final  String organizationId;
@override final  String organizationName;
@override final  String role;
@override final  DateTime? joinedAt;
@override@JsonKey() final  bool isCurrent;
@override final  String? positionTitle;

/// Create a copy of OrgMembershipModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrgMembershipModelCopyWith<_OrgMembershipModel> get copyWith => __$OrgMembershipModelCopyWithImpl<_OrgMembershipModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrgMembershipModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrgMembershipModel&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.organizationName, organizationName) || other.organizationName == organizationName)&&(identical(other.role, role) || other.role == role)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt)&&(identical(other.isCurrent, isCurrent) || other.isCurrent == isCurrent)&&(identical(other.positionTitle, positionTitle) || other.positionTitle == positionTitle));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,organizationId,organizationName,role,joinedAt,isCurrent,positionTitle);

@override
String toString() {
  return 'OrgMembershipModel(organizationId: $organizationId, organizationName: $organizationName, role: $role, joinedAt: $joinedAt, isCurrent: $isCurrent, positionTitle: $positionTitle)';
}


}

/// @nodoc
abstract mixin class _$OrgMembershipModelCopyWith<$Res> implements $OrgMembershipModelCopyWith<$Res> {
  factory _$OrgMembershipModelCopyWith(_OrgMembershipModel value, $Res Function(_OrgMembershipModel) _then) = __$OrgMembershipModelCopyWithImpl;
@override @useResult
$Res call({
 String organizationId, String organizationName, String role, DateTime? joinedAt, bool isCurrent, String? positionTitle
});




}
/// @nodoc
class __$OrgMembershipModelCopyWithImpl<$Res>
    implements _$OrgMembershipModelCopyWith<$Res> {
  __$OrgMembershipModelCopyWithImpl(this._self, this._then);

  final _OrgMembershipModel _self;
  final $Res Function(_OrgMembershipModel) _then;

/// Create a copy of OrgMembershipModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? organizationId = null,Object? organizationName = null,Object? role = null,Object? joinedAt = freezed,Object? isCurrent = null,Object? positionTitle = freezed,}) {
  return _then(_OrgMembershipModel(
organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,organizationName: null == organizationName ? _self.organizationName : organizationName // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isCurrent: null == isCurrent ? _self.isCurrent : isCurrent // ignore: cast_nullable_to_non_nullable
as bool,positionTitle: freezed == positionTitle ? _self.positionTitle : positionTitle // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
