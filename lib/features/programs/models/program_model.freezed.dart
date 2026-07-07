// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'program_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProgramModel {

 String get id; String get name; String get code;@JsonKey(name: 'faculty_id') String get facultyId;@JsonKey(name: 'program_head_id') String? get programHeadId; String? get programHeadName;@JsonKey(name: 'logo_url') String? get logoUrl; String get status;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt;
/// Create a copy of ProgramModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProgramModelCopyWith<ProgramModel> get copyWith => _$ProgramModelCopyWithImpl<ProgramModel>(this as ProgramModel, _$identity);

  /// Serializes this ProgramModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProgramModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.code, code) || other.code == code)&&(identical(other.facultyId, facultyId) || other.facultyId == facultyId)&&(identical(other.programHeadId, programHeadId) || other.programHeadId == programHeadId)&&(identical(other.programHeadName, programHeadName) || other.programHeadName == programHeadName)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,code,facultyId,programHeadId,programHeadName,logoUrl,status,createdAt,updatedAt);

@override
String toString() {
  return 'ProgramModel(id: $id, name: $name, code: $code, facultyId: $facultyId, programHeadId: $programHeadId, programHeadName: $programHeadName, logoUrl: $logoUrl, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ProgramModelCopyWith<$Res>  {
  factory $ProgramModelCopyWith(ProgramModel value, $Res Function(ProgramModel) _then) = _$ProgramModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, String code,@JsonKey(name: 'faculty_id') String facultyId,@JsonKey(name: 'program_head_id') String? programHeadId, String? programHeadName,@JsonKey(name: 'logo_url') String? logoUrl, String status,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class _$ProgramModelCopyWithImpl<$Res>
    implements $ProgramModelCopyWith<$Res> {
  _$ProgramModelCopyWithImpl(this._self, this._then);

  final ProgramModel _self;
  final $Res Function(ProgramModel) _then;

/// Create a copy of ProgramModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? code = null,Object? facultyId = null,Object? programHeadId = freezed,Object? programHeadName = freezed,Object? logoUrl = freezed,Object? status = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,facultyId: null == facultyId ? _self.facultyId : facultyId // ignore: cast_nullable_to_non_nullable
as String,programHeadId: freezed == programHeadId ? _self.programHeadId : programHeadId // ignore: cast_nullable_to_non_nullable
as String?,programHeadName: freezed == programHeadName ? _self.programHeadName : programHeadName // ignore: cast_nullable_to_non_nullable
as String?,logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProgramModel].
extension ProgramModelPatterns on ProgramModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProgramModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProgramModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProgramModel value)  $default,){
final _that = this;
switch (_that) {
case _ProgramModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProgramModel value)?  $default,){
final _that = this;
switch (_that) {
case _ProgramModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String code, @JsonKey(name: 'faculty_id')  String facultyId, @JsonKey(name: 'program_head_id')  String? programHeadId,  String? programHeadName, @JsonKey(name: 'logo_url')  String? logoUrl,  String status, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProgramModel() when $default != null:
return $default(_that.id,_that.name,_that.code,_that.facultyId,_that.programHeadId,_that.programHeadName,_that.logoUrl,_that.status,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String code, @JsonKey(name: 'faculty_id')  String facultyId, @JsonKey(name: 'program_head_id')  String? programHeadId,  String? programHeadName, @JsonKey(name: 'logo_url')  String? logoUrl,  String status, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ProgramModel():
return $default(_that.id,_that.name,_that.code,_that.facultyId,_that.programHeadId,_that.programHeadName,_that.logoUrl,_that.status,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String code, @JsonKey(name: 'faculty_id')  String facultyId, @JsonKey(name: 'program_head_id')  String? programHeadId,  String? programHeadName, @JsonKey(name: 'logo_url')  String? logoUrl,  String status, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ProgramModel() when $default != null:
return $default(_that.id,_that.name,_that.code,_that.facultyId,_that.programHeadId,_that.programHeadName,_that.logoUrl,_that.status,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProgramModel implements ProgramModel {
  const _ProgramModel({required this.id, required this.name, required this.code, @JsonKey(name: 'faculty_id') required this.facultyId, @JsonKey(name: 'program_head_id') this.programHeadId, this.programHeadName, @JsonKey(name: 'logo_url') this.logoUrl, this.status = 'active', @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt});
  factory _ProgramModel.fromJson(Map<String, dynamic> json) => _$ProgramModelFromJson(json);

@override final  String id;
@override final  String name;
@override final  String code;
@override@JsonKey(name: 'faculty_id') final  String facultyId;
@override@JsonKey(name: 'program_head_id') final  String? programHeadId;
@override final  String? programHeadName;
@override@JsonKey(name: 'logo_url') final  String? logoUrl;
@override@JsonKey() final  String status;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;

/// Create a copy of ProgramModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProgramModelCopyWith<_ProgramModel> get copyWith => __$ProgramModelCopyWithImpl<_ProgramModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProgramModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProgramModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.code, code) || other.code == code)&&(identical(other.facultyId, facultyId) || other.facultyId == facultyId)&&(identical(other.programHeadId, programHeadId) || other.programHeadId == programHeadId)&&(identical(other.programHeadName, programHeadName) || other.programHeadName == programHeadName)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,code,facultyId,programHeadId,programHeadName,logoUrl,status,createdAt,updatedAt);

@override
String toString() {
  return 'ProgramModel(id: $id, name: $name, code: $code, facultyId: $facultyId, programHeadId: $programHeadId, programHeadName: $programHeadName, logoUrl: $logoUrl, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ProgramModelCopyWith<$Res> implements $ProgramModelCopyWith<$Res> {
  factory _$ProgramModelCopyWith(_ProgramModel value, $Res Function(_ProgramModel) _then) = __$ProgramModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String code,@JsonKey(name: 'faculty_id') String facultyId,@JsonKey(name: 'program_head_id') String? programHeadId, String? programHeadName,@JsonKey(name: 'logo_url') String? logoUrl, String status,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class __$ProgramModelCopyWithImpl<$Res>
    implements _$ProgramModelCopyWith<$Res> {
  __$ProgramModelCopyWithImpl(this._self, this._then);

  final _ProgramModel _self;
  final $Res Function(_ProgramModel) _then;

/// Create a copy of ProgramModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? code = null,Object? facultyId = null,Object? programHeadId = freezed,Object? programHeadName = freezed,Object? logoUrl = freezed,Object? status = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_ProgramModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,facultyId: null == facultyId ? _self.facultyId : facultyId // ignore: cast_nullable_to_non_nullable
as String,programHeadId: freezed == programHeadId ? _self.programHeadId : programHeadId // ignore: cast_nullable_to_non_nullable
as String?,programHeadName: freezed == programHeadName ? _self.programHeadName : programHeadName // ignore: cast_nullable_to_non_nullable
as String?,logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
