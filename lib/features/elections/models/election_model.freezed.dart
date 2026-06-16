// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'election_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ElectionModel {

 String get id; String get name; String get organizationId; String get type;// Organization, SSC, Department, COMSELEC
 DateTime get startTime; DateTime get endTime; String get status;// draft, upcoming, ongoing, completed, archived, cancelled
 String get createdBy; DateTime? get createdAt; int? get candidateCount; int? get votesCast;
/// Create a copy of ElectionModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ElectionModelCopyWith<ElectionModel> get copyWith => _$ElectionModelCopyWithImpl<ElectionModel>(this as ElectionModel, _$identity);

  /// Serializes this ElectionModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ElectionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.type, type) || other.type == type)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.candidateCount, candidateCount) || other.candidateCount == candidateCount)&&(identical(other.votesCast, votesCast) || other.votesCast == votesCast));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,organizationId,type,startTime,endTime,status,createdBy,createdAt,candidateCount,votesCast);

@override
String toString() {
  return 'ElectionModel(id: $id, name: $name, organizationId: $organizationId, type: $type, startTime: $startTime, endTime: $endTime, status: $status, createdBy: $createdBy, createdAt: $createdAt, candidateCount: $candidateCount, votesCast: $votesCast)';
}


}

/// @nodoc
abstract mixin class $ElectionModelCopyWith<$Res>  {
  factory $ElectionModelCopyWith(ElectionModel value, $Res Function(ElectionModel) _then) = _$ElectionModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, String organizationId, String type, DateTime startTime, DateTime endTime, String status, String createdBy, DateTime? createdAt, int? candidateCount, int? votesCast
});




}
/// @nodoc
class _$ElectionModelCopyWithImpl<$Res>
    implements $ElectionModelCopyWith<$Res> {
  _$ElectionModelCopyWithImpl(this._self, this._then);

  final ElectionModel _self;
  final $Res Function(ElectionModel) _then;

/// Create a copy of ElectionModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? organizationId = null,Object? type = null,Object? startTime = null,Object? endTime = null,Object? status = null,Object? createdBy = null,Object? createdAt = freezed,Object? candidateCount = freezed,Object? votesCast = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,candidateCount: freezed == candidateCount ? _self.candidateCount : candidateCount // ignore: cast_nullable_to_non_nullable
as int?,votesCast: freezed == votesCast ? _self.votesCast : votesCast // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [ElectionModel].
extension ElectionModelPatterns on ElectionModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ElectionModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ElectionModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ElectionModel value)  $default,){
final _that = this;
switch (_that) {
case _ElectionModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ElectionModel value)?  $default,){
final _that = this;
switch (_that) {
case _ElectionModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String organizationId,  String type,  DateTime startTime,  DateTime endTime,  String status,  String createdBy,  DateTime? createdAt,  int? candidateCount,  int? votesCast)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ElectionModel() when $default != null:
return $default(_that.id,_that.name,_that.organizationId,_that.type,_that.startTime,_that.endTime,_that.status,_that.createdBy,_that.createdAt,_that.candidateCount,_that.votesCast);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String organizationId,  String type,  DateTime startTime,  DateTime endTime,  String status,  String createdBy,  DateTime? createdAt,  int? candidateCount,  int? votesCast)  $default,) {final _that = this;
switch (_that) {
case _ElectionModel():
return $default(_that.id,_that.name,_that.organizationId,_that.type,_that.startTime,_that.endTime,_that.status,_that.createdBy,_that.createdAt,_that.candidateCount,_that.votesCast);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String organizationId,  String type,  DateTime startTime,  DateTime endTime,  String status,  String createdBy,  DateTime? createdAt,  int? candidateCount,  int? votesCast)?  $default,) {final _that = this;
switch (_that) {
case _ElectionModel() when $default != null:
return $default(_that.id,_that.name,_that.organizationId,_that.type,_that.startTime,_that.endTime,_that.status,_that.createdBy,_that.createdAt,_that.candidateCount,_that.votesCast);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ElectionModel implements ElectionModel {
  const _ElectionModel({required this.id, required this.name, required this.organizationId, required this.type, required this.startTime, required this.endTime, this.status = 'draft', required this.createdBy, this.createdAt, this.candidateCount, this.votesCast});
  factory _ElectionModel.fromJson(Map<String, dynamic> json) => _$ElectionModelFromJson(json);

@override final  String id;
@override final  String name;
@override final  String organizationId;
@override final  String type;
// Organization, SSC, Department, COMSELEC
@override final  DateTime startTime;
@override final  DateTime endTime;
@override@JsonKey() final  String status;
// draft, upcoming, ongoing, completed, archived, cancelled
@override final  String createdBy;
@override final  DateTime? createdAt;
@override final  int? candidateCount;
@override final  int? votesCast;

/// Create a copy of ElectionModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ElectionModelCopyWith<_ElectionModel> get copyWith => __$ElectionModelCopyWithImpl<_ElectionModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ElectionModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ElectionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.type, type) || other.type == type)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.candidateCount, candidateCount) || other.candidateCount == candidateCount)&&(identical(other.votesCast, votesCast) || other.votesCast == votesCast));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,organizationId,type,startTime,endTime,status,createdBy,createdAt,candidateCount,votesCast);

@override
String toString() {
  return 'ElectionModel(id: $id, name: $name, organizationId: $organizationId, type: $type, startTime: $startTime, endTime: $endTime, status: $status, createdBy: $createdBy, createdAt: $createdAt, candidateCount: $candidateCount, votesCast: $votesCast)';
}


}

/// @nodoc
abstract mixin class _$ElectionModelCopyWith<$Res> implements $ElectionModelCopyWith<$Res> {
  factory _$ElectionModelCopyWith(_ElectionModel value, $Res Function(_ElectionModel) _then) = __$ElectionModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String organizationId, String type, DateTime startTime, DateTime endTime, String status, String createdBy, DateTime? createdAt, int? candidateCount, int? votesCast
});




}
/// @nodoc
class __$ElectionModelCopyWithImpl<$Res>
    implements _$ElectionModelCopyWith<$Res> {
  __$ElectionModelCopyWithImpl(this._self, this._then);

  final _ElectionModel _self;
  final $Res Function(_ElectionModel) _then;

/// Create a copy of ElectionModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? organizationId = null,Object? type = null,Object? startTime = null,Object? endTime = null,Object? status = null,Object? createdBy = null,Object? createdAt = freezed,Object? candidateCount = freezed,Object? votesCast = freezed,}) {
  return _then(_ElectionModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,candidateCount: freezed == candidateCount ? _self.candidateCount : candidateCount // ignore: cast_nullable_to_non_nullable
as int?,votesCast: freezed == votesCast ? _self.votesCast : votesCast // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
