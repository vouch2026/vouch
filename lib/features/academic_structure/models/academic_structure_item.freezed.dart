// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'academic_structure_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AcademicStructureItem {

 String get campusName; String get facultyName; String get programName; String get programId; String get facultyId; String get campusId; String? get programHeadName; int get studentCount; int get orgCount; String get status;
/// Create a copy of AcademicStructureItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AcademicStructureItemCopyWith<AcademicStructureItem> get copyWith => _$AcademicStructureItemCopyWithImpl<AcademicStructureItem>(this as AcademicStructureItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AcademicStructureItem&&(identical(other.campusName, campusName) || other.campusName == campusName)&&(identical(other.facultyName, facultyName) || other.facultyName == facultyName)&&(identical(other.programName, programName) || other.programName == programName)&&(identical(other.programId, programId) || other.programId == programId)&&(identical(other.facultyId, facultyId) || other.facultyId == facultyId)&&(identical(other.campusId, campusId) || other.campusId == campusId)&&(identical(other.programHeadName, programHeadName) || other.programHeadName == programHeadName)&&(identical(other.studentCount, studentCount) || other.studentCount == studentCount)&&(identical(other.orgCount, orgCount) || other.orgCount == orgCount)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,campusName,facultyName,programName,programId,facultyId,campusId,programHeadName,studentCount,orgCount,status);

@override
String toString() {
  return 'AcademicStructureItem(campusName: $campusName, facultyName: $facultyName, programName: $programName, programId: $programId, facultyId: $facultyId, campusId: $campusId, programHeadName: $programHeadName, studentCount: $studentCount, orgCount: $orgCount, status: $status)';
}


}

/// @nodoc
abstract mixin class $AcademicStructureItemCopyWith<$Res>  {
  factory $AcademicStructureItemCopyWith(AcademicStructureItem value, $Res Function(AcademicStructureItem) _then) = _$AcademicStructureItemCopyWithImpl;
@useResult
$Res call({
 String campusName, String facultyName, String programName, String programId, String facultyId, String campusId, String? programHeadName, int studentCount, int orgCount, String status
});




}
/// @nodoc
class _$AcademicStructureItemCopyWithImpl<$Res>
    implements $AcademicStructureItemCopyWith<$Res> {
  _$AcademicStructureItemCopyWithImpl(this._self, this._then);

  final AcademicStructureItem _self;
  final $Res Function(AcademicStructureItem) _then;

/// Create a copy of AcademicStructureItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? campusName = null,Object? facultyName = null,Object? programName = null,Object? programId = null,Object? facultyId = null,Object? campusId = null,Object? programHeadName = freezed,Object? studentCount = null,Object? orgCount = null,Object? status = null,}) {
  return _then(_self.copyWith(
campusName: null == campusName ? _self.campusName : campusName // ignore: cast_nullable_to_non_nullable
as String,facultyName: null == facultyName ? _self.facultyName : facultyName // ignore: cast_nullable_to_non_nullable
as String,programName: null == programName ? _self.programName : programName // ignore: cast_nullable_to_non_nullable
as String,programId: null == programId ? _self.programId : programId // ignore: cast_nullable_to_non_nullable
as String,facultyId: null == facultyId ? _self.facultyId : facultyId // ignore: cast_nullable_to_non_nullable
as String,campusId: null == campusId ? _self.campusId : campusId // ignore: cast_nullable_to_non_nullable
as String,programHeadName: freezed == programHeadName ? _self.programHeadName : programHeadName // ignore: cast_nullable_to_non_nullable
as String?,studentCount: null == studentCount ? _self.studentCount : studentCount // ignore: cast_nullable_to_non_nullable
as int,orgCount: null == orgCount ? _self.orgCount : orgCount // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AcademicStructureItem].
extension AcademicStructureItemPatterns on AcademicStructureItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AcademicStructureItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AcademicStructureItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AcademicStructureItem value)  $default,){
final _that = this;
switch (_that) {
case _AcademicStructureItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AcademicStructureItem value)?  $default,){
final _that = this;
switch (_that) {
case _AcademicStructureItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String campusName,  String facultyName,  String programName,  String programId,  String facultyId,  String campusId,  String? programHeadName,  int studentCount,  int orgCount,  String status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AcademicStructureItem() when $default != null:
return $default(_that.campusName,_that.facultyName,_that.programName,_that.programId,_that.facultyId,_that.campusId,_that.programHeadName,_that.studentCount,_that.orgCount,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String campusName,  String facultyName,  String programName,  String programId,  String facultyId,  String campusId,  String? programHeadName,  int studentCount,  int orgCount,  String status)  $default,) {final _that = this;
switch (_that) {
case _AcademicStructureItem():
return $default(_that.campusName,_that.facultyName,_that.programName,_that.programId,_that.facultyId,_that.campusId,_that.programHeadName,_that.studentCount,_that.orgCount,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String campusName,  String facultyName,  String programName,  String programId,  String facultyId,  String campusId,  String? programHeadName,  int studentCount,  int orgCount,  String status)?  $default,) {final _that = this;
switch (_that) {
case _AcademicStructureItem() when $default != null:
return $default(_that.campusName,_that.facultyName,_that.programName,_that.programId,_that.facultyId,_that.campusId,_that.programHeadName,_that.studentCount,_that.orgCount,_that.status);case _:
  return null;

}
}

}

/// @nodoc


class _AcademicStructureItem implements AcademicStructureItem {
  const _AcademicStructureItem({required this.campusName, required this.facultyName, required this.programName, required this.programId, required this.facultyId, required this.campusId, this.programHeadName, this.studentCount = 0, this.orgCount = 0, this.status = 'Active'});
  

@override final  String campusName;
@override final  String facultyName;
@override final  String programName;
@override final  String programId;
@override final  String facultyId;
@override final  String campusId;
@override final  String? programHeadName;
@override@JsonKey() final  int studentCount;
@override@JsonKey() final  int orgCount;
@override@JsonKey() final  String status;

/// Create a copy of AcademicStructureItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AcademicStructureItemCopyWith<_AcademicStructureItem> get copyWith => __$AcademicStructureItemCopyWithImpl<_AcademicStructureItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AcademicStructureItem&&(identical(other.campusName, campusName) || other.campusName == campusName)&&(identical(other.facultyName, facultyName) || other.facultyName == facultyName)&&(identical(other.programName, programName) || other.programName == programName)&&(identical(other.programId, programId) || other.programId == programId)&&(identical(other.facultyId, facultyId) || other.facultyId == facultyId)&&(identical(other.campusId, campusId) || other.campusId == campusId)&&(identical(other.programHeadName, programHeadName) || other.programHeadName == programHeadName)&&(identical(other.studentCount, studentCount) || other.studentCount == studentCount)&&(identical(other.orgCount, orgCount) || other.orgCount == orgCount)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,campusName,facultyName,programName,programId,facultyId,campusId,programHeadName,studentCount,orgCount,status);

@override
String toString() {
  return 'AcademicStructureItem(campusName: $campusName, facultyName: $facultyName, programName: $programName, programId: $programId, facultyId: $facultyId, campusId: $campusId, programHeadName: $programHeadName, studentCount: $studentCount, orgCount: $orgCount, status: $status)';
}


}

/// @nodoc
abstract mixin class _$AcademicStructureItemCopyWith<$Res> implements $AcademicStructureItemCopyWith<$Res> {
  factory _$AcademicStructureItemCopyWith(_AcademicStructureItem value, $Res Function(_AcademicStructureItem) _then) = __$AcademicStructureItemCopyWithImpl;
@override @useResult
$Res call({
 String campusName, String facultyName, String programName, String programId, String facultyId, String campusId, String? programHeadName, int studentCount, int orgCount, String status
});




}
/// @nodoc
class __$AcademicStructureItemCopyWithImpl<$Res>
    implements _$AcademicStructureItemCopyWith<$Res> {
  __$AcademicStructureItemCopyWithImpl(this._self, this._then);

  final _AcademicStructureItem _self;
  final $Res Function(_AcademicStructureItem) _then;

/// Create a copy of AcademicStructureItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? campusName = null,Object? facultyName = null,Object? programName = null,Object? programId = null,Object? facultyId = null,Object? campusId = null,Object? programHeadName = freezed,Object? studentCount = null,Object? orgCount = null,Object? status = null,}) {
  return _then(_AcademicStructureItem(
campusName: null == campusName ? _self.campusName : campusName // ignore: cast_nullable_to_non_nullable
as String,facultyName: null == facultyName ? _self.facultyName : facultyName // ignore: cast_nullable_to_non_nullable
as String,programName: null == programName ? _self.programName : programName // ignore: cast_nullable_to_non_nullable
as String,programId: null == programId ? _self.programId : programId // ignore: cast_nullable_to_non_nullable
as String,facultyId: null == facultyId ? _self.facultyId : facultyId // ignore: cast_nullable_to_non_nullable
as String,campusId: null == campusId ? _self.campusId : campusId // ignore: cast_nullable_to_non_nullable
as String,programHeadName: freezed == programHeadName ? _self.programHeadName : programHeadName // ignore: cast_nullable_to_non_nullable
as String?,studentCount: null == studentCount ? _self.studentCount : studentCount // ignore: cast_nullable_to_non_nullable
as int,orgCount: null == orgCount ? _self.orgCount : orgCount // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
