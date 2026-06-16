// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'voter_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VoterModel {

 String get id; String get userId; String get electionId; String get studentNumber; String get fullName; String? get campusName; String? get facultyName; String? get programName; String get status;// eligible, voted, not_voted, restricted
 DateTime? get votedAt;
/// Create a copy of VoterModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoterModelCopyWith<VoterModel> get copyWith => _$VoterModelCopyWithImpl<VoterModel>(this as VoterModel, _$identity);

  /// Serializes this VoterModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoterModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.electionId, electionId) || other.electionId == electionId)&&(identical(other.studentNumber, studentNumber) || other.studentNumber == studentNumber)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.campusName, campusName) || other.campusName == campusName)&&(identical(other.facultyName, facultyName) || other.facultyName == facultyName)&&(identical(other.programName, programName) || other.programName == programName)&&(identical(other.status, status) || other.status == status)&&(identical(other.votedAt, votedAt) || other.votedAt == votedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,electionId,studentNumber,fullName,campusName,facultyName,programName,status,votedAt);

@override
String toString() {
  return 'VoterModel(id: $id, userId: $userId, electionId: $electionId, studentNumber: $studentNumber, fullName: $fullName, campusName: $campusName, facultyName: $facultyName, programName: $programName, status: $status, votedAt: $votedAt)';
}


}

/// @nodoc
abstract mixin class $VoterModelCopyWith<$Res>  {
  factory $VoterModelCopyWith(VoterModel value, $Res Function(VoterModel) _then) = _$VoterModelCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String electionId, String studentNumber, String fullName, String? campusName, String? facultyName, String? programName, String status, DateTime? votedAt
});




}
/// @nodoc
class _$VoterModelCopyWithImpl<$Res>
    implements $VoterModelCopyWith<$Res> {
  _$VoterModelCopyWithImpl(this._self, this._then);

  final VoterModel _self;
  final $Res Function(VoterModel) _then;

/// Create a copy of VoterModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? electionId = null,Object? studentNumber = null,Object? fullName = null,Object? campusName = freezed,Object? facultyName = freezed,Object? programName = freezed,Object? status = null,Object? votedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,electionId: null == electionId ? _self.electionId : electionId // ignore: cast_nullable_to_non_nullable
as String,studentNumber: null == studentNumber ? _self.studentNumber : studentNumber // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,campusName: freezed == campusName ? _self.campusName : campusName // ignore: cast_nullable_to_non_nullable
as String?,facultyName: freezed == facultyName ? _self.facultyName : facultyName // ignore: cast_nullable_to_non_nullable
as String?,programName: freezed == programName ? _self.programName : programName // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,votedAt: freezed == votedAt ? _self.votedAt : votedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [VoterModel].
extension VoterModelPatterns on VoterModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VoterModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VoterModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VoterModel value)  $default,){
final _that = this;
switch (_that) {
case _VoterModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VoterModel value)?  $default,){
final _that = this;
switch (_that) {
case _VoterModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String electionId,  String studentNumber,  String fullName,  String? campusName,  String? facultyName,  String? programName,  String status,  DateTime? votedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VoterModel() when $default != null:
return $default(_that.id,_that.userId,_that.electionId,_that.studentNumber,_that.fullName,_that.campusName,_that.facultyName,_that.programName,_that.status,_that.votedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String electionId,  String studentNumber,  String fullName,  String? campusName,  String? facultyName,  String? programName,  String status,  DateTime? votedAt)  $default,) {final _that = this;
switch (_that) {
case _VoterModel():
return $default(_that.id,_that.userId,_that.electionId,_that.studentNumber,_that.fullName,_that.campusName,_that.facultyName,_that.programName,_that.status,_that.votedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String electionId,  String studentNumber,  String fullName,  String? campusName,  String? facultyName,  String? programName,  String status,  DateTime? votedAt)?  $default,) {final _that = this;
switch (_that) {
case _VoterModel() when $default != null:
return $default(_that.id,_that.userId,_that.electionId,_that.studentNumber,_that.fullName,_that.campusName,_that.facultyName,_that.programName,_that.status,_that.votedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VoterModel implements VoterModel {
  const _VoterModel({required this.id, required this.userId, required this.electionId, required this.studentNumber, required this.fullName, this.campusName, this.facultyName, this.programName, this.status = 'eligible', this.votedAt});
  factory _VoterModel.fromJson(Map<String, dynamic> json) => _$VoterModelFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String electionId;
@override final  String studentNumber;
@override final  String fullName;
@override final  String? campusName;
@override final  String? facultyName;
@override final  String? programName;
@override@JsonKey() final  String status;
// eligible, voted, not_voted, restricted
@override final  DateTime? votedAt;

/// Create a copy of VoterModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VoterModelCopyWith<_VoterModel> get copyWith => __$VoterModelCopyWithImpl<_VoterModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VoterModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VoterModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.electionId, electionId) || other.electionId == electionId)&&(identical(other.studentNumber, studentNumber) || other.studentNumber == studentNumber)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.campusName, campusName) || other.campusName == campusName)&&(identical(other.facultyName, facultyName) || other.facultyName == facultyName)&&(identical(other.programName, programName) || other.programName == programName)&&(identical(other.status, status) || other.status == status)&&(identical(other.votedAt, votedAt) || other.votedAt == votedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,electionId,studentNumber,fullName,campusName,facultyName,programName,status,votedAt);

@override
String toString() {
  return 'VoterModel(id: $id, userId: $userId, electionId: $electionId, studentNumber: $studentNumber, fullName: $fullName, campusName: $campusName, facultyName: $facultyName, programName: $programName, status: $status, votedAt: $votedAt)';
}


}

/// @nodoc
abstract mixin class _$VoterModelCopyWith<$Res> implements $VoterModelCopyWith<$Res> {
  factory _$VoterModelCopyWith(_VoterModel value, $Res Function(_VoterModel) _then) = __$VoterModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String electionId, String studentNumber, String fullName, String? campusName, String? facultyName, String? programName, String status, DateTime? votedAt
});




}
/// @nodoc
class __$VoterModelCopyWithImpl<$Res>
    implements _$VoterModelCopyWith<$Res> {
  __$VoterModelCopyWithImpl(this._self, this._then);

  final _VoterModel _self;
  final $Res Function(_VoterModel) _then;

/// Create a copy of VoterModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? electionId = null,Object? studentNumber = null,Object? fullName = null,Object? campusName = freezed,Object? facultyName = freezed,Object? programName = freezed,Object? status = null,Object? votedAt = freezed,}) {
  return _then(_VoterModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,electionId: null == electionId ? _self.electionId : electionId // ignore: cast_nullable_to_non_nullable
as String,studentNumber: null == studentNumber ? _self.studentNumber : studentNumber // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,campusName: freezed == campusName ? _self.campusName : campusName // ignore: cast_nullable_to_non_nullable
as String?,facultyName: freezed == facultyName ? _self.facultyName : facultyName // ignore: cast_nullable_to_non_nullable
as String?,programName: freezed == programName ? _self.programName : programName // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,votedAt: freezed == votedAt ? _self.votedAt : votedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
