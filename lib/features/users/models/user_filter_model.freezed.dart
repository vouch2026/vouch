// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_filter_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UserFilterModel {

 String? get searchQuery; String? get campusId; String? get facultyId; String? get programId; String? get status; int? get yearLevel; String? get position; String? get role; DateTime? get startDate; DateTime? get endDate; String get sortBy; bool get ascending;
/// Create a copy of UserFilterModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserFilterModelCopyWith<UserFilterModel> get copyWith => _$UserFilterModelCopyWithImpl<UserFilterModel>(this as UserFilterModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserFilterModel&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.campusId, campusId) || other.campusId == campusId)&&(identical(other.facultyId, facultyId) || other.facultyId == facultyId)&&(identical(other.programId, programId) || other.programId == programId)&&(identical(other.status, status) || other.status == status)&&(identical(other.yearLevel, yearLevel) || other.yearLevel == yearLevel)&&(identical(other.position, position) || other.position == position)&&(identical(other.role, role) || other.role == role)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.sortBy, sortBy) || other.sortBy == sortBy)&&(identical(other.ascending, ascending) || other.ascending == ascending));
}


@override
int get hashCode => Object.hash(runtimeType,searchQuery,campusId,facultyId,programId,status,yearLevel,position,role,startDate,endDate,sortBy,ascending);

@override
String toString() {
  return 'UserFilterModel(searchQuery: $searchQuery, campusId: $campusId, facultyId: $facultyId, programId: $programId, status: $status, yearLevel: $yearLevel, position: $position, role: $role, startDate: $startDate, endDate: $endDate, sortBy: $sortBy, ascending: $ascending)';
}


}

/// @nodoc
abstract mixin class $UserFilterModelCopyWith<$Res>  {
  factory $UserFilterModelCopyWith(UserFilterModel value, $Res Function(UserFilterModel) _then) = _$UserFilterModelCopyWithImpl;
@useResult
$Res call({
 String? searchQuery, String? campusId, String? facultyId, String? programId, String? status, int? yearLevel, String? position, String? role, DateTime? startDate, DateTime? endDate, String sortBy, bool ascending
});




}
/// @nodoc
class _$UserFilterModelCopyWithImpl<$Res>
    implements $UserFilterModelCopyWith<$Res> {
  _$UserFilterModelCopyWithImpl(this._self, this._then);

  final UserFilterModel _self;
  final $Res Function(UserFilterModel) _then;

/// Create a copy of UserFilterModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? searchQuery = freezed,Object? campusId = freezed,Object? facultyId = freezed,Object? programId = freezed,Object? status = freezed,Object? yearLevel = freezed,Object? position = freezed,Object? role = freezed,Object? startDate = freezed,Object? endDate = freezed,Object? sortBy = null,Object? ascending = null,}) {
  return _then(_self.copyWith(
searchQuery: freezed == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String?,campusId: freezed == campusId ? _self.campusId : campusId // ignore: cast_nullable_to_non_nullable
as String?,facultyId: freezed == facultyId ? _self.facultyId : facultyId // ignore: cast_nullable_to_non_nullable
as String?,programId: freezed == programId ? _self.programId : programId // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,yearLevel: freezed == yearLevel ? _self.yearLevel : yearLevel // ignore: cast_nullable_to_non_nullable
as int?,position: freezed == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as String?,role: freezed == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String?,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,sortBy: null == sortBy ? _self.sortBy : sortBy // ignore: cast_nullable_to_non_nullable
as String,ascending: null == ascending ? _self.ascending : ascending // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [UserFilterModel].
extension UserFilterModelPatterns on UserFilterModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserFilterModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserFilterModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserFilterModel value)  $default,){
final _that = this;
switch (_that) {
case _UserFilterModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserFilterModel value)?  $default,){
final _that = this;
switch (_that) {
case _UserFilterModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? searchQuery,  String? campusId,  String? facultyId,  String? programId,  String? status,  int? yearLevel,  String? position,  String? role,  DateTime? startDate,  DateTime? endDate,  String sortBy,  bool ascending)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserFilterModel() when $default != null:
return $default(_that.searchQuery,_that.campusId,_that.facultyId,_that.programId,_that.status,_that.yearLevel,_that.position,_that.role,_that.startDate,_that.endDate,_that.sortBy,_that.ascending);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? searchQuery,  String? campusId,  String? facultyId,  String? programId,  String? status,  int? yearLevel,  String? position,  String? role,  DateTime? startDate,  DateTime? endDate,  String sortBy,  bool ascending)  $default,) {final _that = this;
switch (_that) {
case _UserFilterModel():
return $default(_that.searchQuery,_that.campusId,_that.facultyId,_that.programId,_that.status,_that.yearLevel,_that.position,_that.role,_that.startDate,_that.endDate,_that.sortBy,_that.ascending);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? searchQuery,  String? campusId,  String? facultyId,  String? programId,  String? status,  int? yearLevel,  String? position,  String? role,  DateTime? startDate,  DateTime? endDate,  String sortBy,  bool ascending)?  $default,) {final _that = this;
switch (_that) {
case _UserFilterModel() when $default != null:
return $default(_that.searchQuery,_that.campusId,_that.facultyId,_that.programId,_that.status,_that.yearLevel,_that.position,_that.role,_that.startDate,_that.endDate,_that.sortBy,_that.ascending);case _:
  return null;

}
}

}

/// @nodoc


class _UserFilterModel implements UserFilterModel {
  const _UserFilterModel({this.searchQuery, this.campusId, this.facultyId, this.programId, this.status, this.yearLevel, this.position, this.role, this.startDate, this.endDate, this.sortBy = 'name', this.ascending = true});
  

@override final  String? searchQuery;
@override final  String? campusId;
@override final  String? facultyId;
@override final  String? programId;
@override final  String? status;
@override final  int? yearLevel;
@override final  String? position;
@override final  String? role;
@override final  DateTime? startDate;
@override final  DateTime? endDate;
@override@JsonKey() final  String sortBy;
@override@JsonKey() final  bool ascending;

/// Create a copy of UserFilterModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserFilterModelCopyWith<_UserFilterModel> get copyWith => __$UserFilterModelCopyWithImpl<_UserFilterModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserFilterModel&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.campusId, campusId) || other.campusId == campusId)&&(identical(other.facultyId, facultyId) || other.facultyId == facultyId)&&(identical(other.programId, programId) || other.programId == programId)&&(identical(other.status, status) || other.status == status)&&(identical(other.yearLevel, yearLevel) || other.yearLevel == yearLevel)&&(identical(other.position, position) || other.position == position)&&(identical(other.role, role) || other.role == role)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.sortBy, sortBy) || other.sortBy == sortBy)&&(identical(other.ascending, ascending) || other.ascending == ascending));
}


@override
int get hashCode => Object.hash(runtimeType,searchQuery,campusId,facultyId,programId,status,yearLevel,position,role,startDate,endDate,sortBy,ascending);

@override
String toString() {
  return 'UserFilterModel(searchQuery: $searchQuery, campusId: $campusId, facultyId: $facultyId, programId: $programId, status: $status, yearLevel: $yearLevel, position: $position, role: $role, startDate: $startDate, endDate: $endDate, sortBy: $sortBy, ascending: $ascending)';
}


}

/// @nodoc
abstract mixin class _$UserFilterModelCopyWith<$Res> implements $UserFilterModelCopyWith<$Res> {
  factory _$UserFilterModelCopyWith(_UserFilterModel value, $Res Function(_UserFilterModel) _then) = __$UserFilterModelCopyWithImpl;
@override @useResult
$Res call({
 String? searchQuery, String? campusId, String? facultyId, String? programId, String? status, int? yearLevel, String? position, String? role, DateTime? startDate, DateTime? endDate, String sortBy, bool ascending
});




}
/// @nodoc
class __$UserFilterModelCopyWithImpl<$Res>
    implements _$UserFilterModelCopyWith<$Res> {
  __$UserFilterModelCopyWithImpl(this._self, this._then);

  final _UserFilterModel _self;
  final $Res Function(_UserFilterModel) _then;

/// Create a copy of UserFilterModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? searchQuery = freezed,Object? campusId = freezed,Object? facultyId = freezed,Object? programId = freezed,Object? status = freezed,Object? yearLevel = freezed,Object? position = freezed,Object? role = freezed,Object? startDate = freezed,Object? endDate = freezed,Object? sortBy = null,Object? ascending = null,}) {
  return _then(_UserFilterModel(
searchQuery: freezed == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String?,campusId: freezed == campusId ? _self.campusId : campusId // ignore: cast_nullable_to_non_nullable
as String?,facultyId: freezed == facultyId ? _self.facultyId : facultyId // ignore: cast_nullable_to_non_nullable
as String?,programId: freezed == programId ? _self.programId : programId // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,yearLevel: freezed == yearLevel ? _self.yearLevel : yearLevel // ignore: cast_nullable_to_non_nullable
as int?,position: freezed == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as String?,role: freezed == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String?,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,sortBy: null == sortBy ? _self.sortBy : sortBy // ignore: cast_nullable_to_non_nullable
as String,ascending: null == ascending ? _self.ascending : ascending // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
