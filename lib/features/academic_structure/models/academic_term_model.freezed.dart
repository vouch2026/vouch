// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'academic_term_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AcademicTermModel {

 String get id;@JsonKey(name: 'academic_year') String get academicYear; String get semester;@JsonKey(name: 'is_active') bool get isActive;@JsonKey(name: 'created_at') DateTime? get createdAt;
/// Create a copy of AcademicTermModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AcademicTermModelCopyWith<AcademicTermModel> get copyWith => _$AcademicTermModelCopyWithImpl<AcademicTermModel>(this as AcademicTermModel, _$identity);

  /// Serializes this AcademicTermModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AcademicTermModel&&(identical(other.id, id) || other.id == id)&&(identical(other.academicYear, academicYear) || other.academicYear == academicYear)&&(identical(other.semester, semester) || other.semester == semester)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,academicYear,semester,isActive,createdAt);

@override
String toString() {
  return 'AcademicTermModel(id: $id, academicYear: $academicYear, semester: $semester, isActive: $isActive, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $AcademicTermModelCopyWith<$Res>  {
  factory $AcademicTermModelCopyWith(AcademicTermModel value, $Res Function(AcademicTermModel) _then) = _$AcademicTermModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'academic_year') String academicYear, String semester,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'created_at') DateTime? createdAt
});




}
/// @nodoc
class _$AcademicTermModelCopyWithImpl<$Res>
    implements $AcademicTermModelCopyWith<$Res> {
  _$AcademicTermModelCopyWithImpl(this._self, this._then);

  final AcademicTermModel _self;
  final $Res Function(AcademicTermModel) _then;

/// Create a copy of AcademicTermModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? academicYear = null,Object? semester = null,Object? isActive = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,academicYear: null == academicYear ? _self.academicYear : academicYear // ignore: cast_nullable_to_non_nullable
as String,semester: null == semester ? _self.semester : semester // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [AcademicTermModel].
extension AcademicTermModelPatterns on AcademicTermModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AcademicTermModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AcademicTermModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AcademicTermModel value)  $default,){
final _that = this;
switch (_that) {
case _AcademicTermModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AcademicTermModel value)?  $default,){
final _that = this;
switch (_that) {
case _AcademicTermModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'academic_year')  String academicYear,  String semester, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'created_at')  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AcademicTermModel() when $default != null:
return $default(_that.id,_that.academicYear,_that.semester,_that.isActive,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'academic_year')  String academicYear,  String semester, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'created_at')  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _AcademicTermModel():
return $default(_that.id,_that.academicYear,_that.semester,_that.isActive,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'academic_year')  String academicYear,  String semester, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'created_at')  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _AcademicTermModel() when $default != null:
return $default(_that.id,_that.academicYear,_that.semester,_that.isActive,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AcademicTermModel implements AcademicTermModel {
  const _AcademicTermModel({required this.id, @JsonKey(name: 'academic_year') required this.academicYear, required this.semester, @JsonKey(name: 'is_active') this.isActive = false, @JsonKey(name: 'created_at') this.createdAt});
  factory _AcademicTermModel.fromJson(Map<String, dynamic> json) => _$AcademicTermModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'academic_year') final  String academicYear;
@override final  String semester;
@override@JsonKey(name: 'is_active') final  bool isActive;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;

/// Create a copy of AcademicTermModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AcademicTermModelCopyWith<_AcademicTermModel> get copyWith => __$AcademicTermModelCopyWithImpl<_AcademicTermModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AcademicTermModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AcademicTermModel&&(identical(other.id, id) || other.id == id)&&(identical(other.academicYear, academicYear) || other.academicYear == academicYear)&&(identical(other.semester, semester) || other.semester == semester)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,academicYear,semester,isActive,createdAt);

@override
String toString() {
  return 'AcademicTermModel(id: $id, academicYear: $academicYear, semester: $semester, isActive: $isActive, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$AcademicTermModelCopyWith<$Res> implements $AcademicTermModelCopyWith<$Res> {
  factory _$AcademicTermModelCopyWith(_AcademicTermModel value, $Res Function(_AcademicTermModel) _then) = __$AcademicTermModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'academic_year') String academicYear, String semester,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'created_at') DateTime? createdAt
});




}
/// @nodoc
class __$AcademicTermModelCopyWithImpl<$Res>
    implements _$AcademicTermModelCopyWith<$Res> {
  __$AcademicTermModelCopyWithImpl(this._self, this._then);

  final _AcademicTermModel _self;
  final $Res Function(_AcademicTermModel) _then;

/// Create a copy of AcademicTermModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? academicYear = null,Object? semester = null,Object? isActive = null,Object? createdAt = freezed,}) {
  return _then(_AcademicTermModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,academicYear: null == academicYear ? _self.academicYear : academicYear // ignore: cast_nullable_to_non_nullable
as String,semester: null == semester ? _self.semester : semester // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
