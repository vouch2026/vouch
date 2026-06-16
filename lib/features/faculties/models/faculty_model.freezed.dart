// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'faculty_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FacultyModel {

 String get id; String get name; String get code;@JsonKey(name: 'campus_id') String get campusId;@JsonKey(name: 'dean_id') String? get deanId; String? get deanName; String get status;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt;
/// Create a copy of FacultyModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FacultyModelCopyWith<FacultyModel> get copyWith => _$FacultyModelCopyWithImpl<FacultyModel>(this as FacultyModel, _$identity);

  /// Serializes this FacultyModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FacultyModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.code, code) || other.code == code)&&(identical(other.campusId, campusId) || other.campusId == campusId)&&(identical(other.deanId, deanId) || other.deanId == deanId)&&(identical(other.deanName, deanName) || other.deanName == deanName)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,code,campusId,deanId,deanName,status,createdAt,updatedAt);

@override
String toString() {
  return 'FacultyModel(id: $id, name: $name, code: $code, campusId: $campusId, deanId: $deanId, deanName: $deanName, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $FacultyModelCopyWith<$Res>  {
  factory $FacultyModelCopyWith(FacultyModel value, $Res Function(FacultyModel) _then) = _$FacultyModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, String code,@JsonKey(name: 'campus_id') String campusId,@JsonKey(name: 'dean_id') String? deanId, String? deanName, String status,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class _$FacultyModelCopyWithImpl<$Res>
    implements $FacultyModelCopyWith<$Res> {
  _$FacultyModelCopyWithImpl(this._self, this._then);

  final FacultyModel _self;
  final $Res Function(FacultyModel) _then;

/// Create a copy of FacultyModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? code = null,Object? campusId = null,Object? deanId = freezed,Object? deanName = freezed,Object? status = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,campusId: null == campusId ? _self.campusId : campusId // ignore: cast_nullable_to_non_nullable
as String,deanId: freezed == deanId ? _self.deanId : deanId // ignore: cast_nullable_to_non_nullable
as String?,deanName: freezed == deanName ? _self.deanName : deanName // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [FacultyModel].
extension FacultyModelPatterns on FacultyModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FacultyModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FacultyModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FacultyModel value)  $default,){
final _that = this;
switch (_that) {
case _FacultyModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FacultyModel value)?  $default,){
final _that = this;
switch (_that) {
case _FacultyModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String code, @JsonKey(name: 'campus_id')  String campusId, @JsonKey(name: 'dean_id')  String? deanId,  String? deanName,  String status, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FacultyModel() when $default != null:
return $default(_that.id,_that.name,_that.code,_that.campusId,_that.deanId,_that.deanName,_that.status,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String code, @JsonKey(name: 'campus_id')  String campusId, @JsonKey(name: 'dean_id')  String? deanId,  String? deanName,  String status, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _FacultyModel():
return $default(_that.id,_that.name,_that.code,_that.campusId,_that.deanId,_that.deanName,_that.status,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String code, @JsonKey(name: 'campus_id')  String campusId, @JsonKey(name: 'dean_id')  String? deanId,  String? deanName,  String status, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _FacultyModel() when $default != null:
return $default(_that.id,_that.name,_that.code,_that.campusId,_that.deanId,_that.deanName,_that.status,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FacultyModel implements FacultyModel {
  const _FacultyModel({required this.id, required this.name, required this.code, @JsonKey(name: 'campus_id') required this.campusId, @JsonKey(name: 'dean_id') this.deanId, this.deanName, this.status = 'active', @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt});
  factory _FacultyModel.fromJson(Map<String, dynamic> json) => _$FacultyModelFromJson(json);

@override final  String id;
@override final  String name;
@override final  String code;
@override@JsonKey(name: 'campus_id') final  String campusId;
@override@JsonKey(name: 'dean_id') final  String? deanId;
@override final  String? deanName;
@override@JsonKey() final  String status;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;

/// Create a copy of FacultyModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FacultyModelCopyWith<_FacultyModel> get copyWith => __$FacultyModelCopyWithImpl<_FacultyModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FacultyModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FacultyModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.code, code) || other.code == code)&&(identical(other.campusId, campusId) || other.campusId == campusId)&&(identical(other.deanId, deanId) || other.deanId == deanId)&&(identical(other.deanName, deanName) || other.deanName == deanName)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,code,campusId,deanId,deanName,status,createdAt,updatedAt);

@override
String toString() {
  return 'FacultyModel(id: $id, name: $name, code: $code, campusId: $campusId, deanId: $deanId, deanName: $deanName, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$FacultyModelCopyWith<$Res> implements $FacultyModelCopyWith<$Res> {
  factory _$FacultyModelCopyWith(_FacultyModel value, $Res Function(_FacultyModel) _then) = __$FacultyModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String code,@JsonKey(name: 'campus_id') String campusId,@JsonKey(name: 'dean_id') String? deanId, String? deanName, String status,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class __$FacultyModelCopyWithImpl<$Res>
    implements _$FacultyModelCopyWith<$Res> {
  __$FacultyModelCopyWithImpl(this._self, this._then);

  final _FacultyModel _self;
  final $Res Function(_FacultyModel) _then;

/// Create a copy of FacultyModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? code = null,Object? campusId = null,Object? deanId = freezed,Object? deanName = freezed,Object? status = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_FacultyModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,campusId: null == campusId ? _self.campusId : campusId // ignore: cast_nullable_to_non_nullable
as String,deanId: freezed == deanId ? _self.deanId : deanId // ignore: cast_nullable_to_non_nullable
as String?,deanName: freezed == deanName ? _self.deanName : deanName // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
