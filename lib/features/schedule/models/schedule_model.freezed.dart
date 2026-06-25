// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'schedule_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ScheduleModel {

 String? get id;@JsonKey(name: 'user_id') String? get userId;@JsonKey(name: 'subject_code') String get subjectCode;@JsonKey(name: 'subject_name') String get subjectName; String get teacher;@JsonKey(name: 'start_time') String get startTime;@JsonKey(name: 'end_time') String get endTime; List<String> get days; String get room;@JsonKey(name: 'academic_term_id') String get academicTermId;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt;// Local-only sync fields: 'synced', 'to_create', 'to_update', 'to_delete'
 String get syncStatus;
/// Create a copy of ScheduleModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScheduleModelCopyWith<ScheduleModel> get copyWith => _$ScheduleModelCopyWithImpl<ScheduleModel>(this as ScheduleModel, _$identity);

  /// Serializes this ScheduleModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScheduleModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.subjectCode, subjectCode) || other.subjectCode == subjectCode)&&(identical(other.subjectName, subjectName) || other.subjectName == subjectName)&&(identical(other.teacher, teacher) || other.teacher == teacher)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&const DeepCollectionEquality().equals(other.days, days)&&(identical(other.room, room) || other.room == room)&&(identical(other.academicTermId, academicTermId) || other.academicTermId == academicTermId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,subjectCode,subjectName,teacher,startTime,endTime,const DeepCollectionEquality().hash(days),room,academicTermId,createdAt,updatedAt,syncStatus);

@override
String toString() {
  return 'ScheduleModel(id: $id, userId: $userId, subjectCode: $subjectCode, subjectName: $subjectName, teacher: $teacher, startTime: $startTime, endTime: $endTime, days: $days, room: $room, academicTermId: $academicTermId, createdAt: $createdAt, updatedAt: $updatedAt, syncStatus: $syncStatus)';
}


}

/// @nodoc
abstract mixin class $ScheduleModelCopyWith<$Res>  {
  factory $ScheduleModelCopyWith(ScheduleModel value, $Res Function(ScheduleModel) _then) = _$ScheduleModelCopyWithImpl;
@useResult
$Res call({
 String? id,@JsonKey(name: 'user_id') String? userId,@JsonKey(name: 'subject_code') String subjectCode,@JsonKey(name: 'subject_name') String subjectName, String teacher,@JsonKey(name: 'start_time') String startTime,@JsonKey(name: 'end_time') String endTime, List<String> days, String room,@JsonKey(name: 'academic_term_id') String academicTermId,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt, String syncStatus
});




}
/// @nodoc
class _$ScheduleModelCopyWithImpl<$Res>
    implements $ScheduleModelCopyWith<$Res> {
  _$ScheduleModelCopyWithImpl(this._self, this._then);

  final ScheduleModel _self;
  final $Res Function(ScheduleModel) _then;

/// Create a copy of ScheduleModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? userId = freezed,Object? subjectCode = null,Object? subjectName = null,Object? teacher = null,Object? startTime = null,Object? endTime = null,Object? days = null,Object? room = null,Object? academicTermId = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? syncStatus = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,subjectCode: null == subjectCode ? _self.subjectCode : subjectCode // ignore: cast_nullable_to_non_nullable
as String,subjectName: null == subjectName ? _self.subjectName : subjectName // ignore: cast_nullable_to_non_nullable
as String,teacher: null == teacher ? _self.teacher : teacher // ignore: cast_nullable_to_non_nullable
as String,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as String,days: null == days ? _self.days : days // ignore: cast_nullable_to_non_nullable
as List<String>,room: null == room ? _self.room : room // ignore: cast_nullable_to_non_nullable
as String,academicTermId: null == academicTermId ? _self.academicTermId : academicTermId // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ScheduleModel].
extension ScheduleModelPatterns on ScheduleModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScheduleModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScheduleModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScheduleModel value)  $default,){
final _that = this;
switch (_that) {
case _ScheduleModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScheduleModel value)?  $default,){
final _that = this;
switch (_that) {
case _ScheduleModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'user_id')  String? userId, @JsonKey(name: 'subject_code')  String subjectCode, @JsonKey(name: 'subject_name')  String subjectName,  String teacher, @JsonKey(name: 'start_time')  String startTime, @JsonKey(name: 'end_time')  String endTime,  List<String> days,  String room, @JsonKey(name: 'academic_term_id')  String academicTermId, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt,  String syncStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScheduleModel() when $default != null:
return $default(_that.id,_that.userId,_that.subjectCode,_that.subjectName,_that.teacher,_that.startTime,_that.endTime,_that.days,_that.room,_that.academicTermId,_that.createdAt,_that.updatedAt,_that.syncStatus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'user_id')  String? userId, @JsonKey(name: 'subject_code')  String subjectCode, @JsonKey(name: 'subject_name')  String subjectName,  String teacher, @JsonKey(name: 'start_time')  String startTime, @JsonKey(name: 'end_time')  String endTime,  List<String> days,  String room, @JsonKey(name: 'academic_term_id')  String academicTermId, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt,  String syncStatus)  $default,) {final _that = this;
switch (_that) {
case _ScheduleModel():
return $default(_that.id,_that.userId,_that.subjectCode,_that.subjectName,_that.teacher,_that.startTime,_that.endTime,_that.days,_that.room,_that.academicTermId,_that.createdAt,_that.updatedAt,_that.syncStatus);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id, @JsonKey(name: 'user_id')  String? userId, @JsonKey(name: 'subject_code')  String subjectCode, @JsonKey(name: 'subject_name')  String subjectName,  String teacher, @JsonKey(name: 'start_time')  String startTime, @JsonKey(name: 'end_time')  String endTime,  List<String> days,  String room, @JsonKey(name: 'academic_term_id')  String academicTermId, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt,  String syncStatus)?  $default,) {final _that = this;
switch (_that) {
case _ScheduleModel() when $default != null:
return $default(_that.id,_that.userId,_that.subjectCode,_that.subjectName,_that.teacher,_that.startTime,_that.endTime,_that.days,_that.room,_that.academicTermId,_that.createdAt,_that.updatedAt,_that.syncStatus);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ScheduleModel implements ScheduleModel {
  const _ScheduleModel({this.id, @JsonKey(name: 'user_id') this.userId, @JsonKey(name: 'subject_code') required this.subjectCode, @JsonKey(name: 'subject_name') required this.subjectName, this.teacher = '', @JsonKey(name: 'start_time') required this.startTime, @JsonKey(name: 'end_time') required this.endTime, required final  List<String> days, this.room = '', @JsonKey(name: 'academic_term_id') required this.academicTermId, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt, this.syncStatus = 'synced'}): _days = days;
  factory _ScheduleModel.fromJson(Map<String, dynamic> json) => _$ScheduleModelFromJson(json);

@override final  String? id;
@override@JsonKey(name: 'user_id') final  String? userId;
@override@JsonKey(name: 'subject_code') final  String subjectCode;
@override@JsonKey(name: 'subject_name') final  String subjectName;
@override@JsonKey() final  String teacher;
@override@JsonKey(name: 'start_time') final  String startTime;
@override@JsonKey(name: 'end_time') final  String endTime;
 final  List<String> _days;
@override List<String> get days {
  if (_days is EqualUnmodifiableListView) return _days;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_days);
}

@override@JsonKey() final  String room;
@override@JsonKey(name: 'academic_term_id') final  String academicTermId;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;
// Local-only sync fields: 'synced', 'to_create', 'to_update', 'to_delete'
@override@JsonKey() final  String syncStatus;

/// Create a copy of ScheduleModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScheduleModelCopyWith<_ScheduleModel> get copyWith => __$ScheduleModelCopyWithImpl<_ScheduleModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScheduleModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScheduleModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.subjectCode, subjectCode) || other.subjectCode == subjectCode)&&(identical(other.subjectName, subjectName) || other.subjectName == subjectName)&&(identical(other.teacher, teacher) || other.teacher == teacher)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&const DeepCollectionEquality().equals(other._days, _days)&&(identical(other.room, room) || other.room == room)&&(identical(other.academicTermId, academicTermId) || other.academicTermId == academicTermId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,subjectCode,subjectName,teacher,startTime,endTime,const DeepCollectionEquality().hash(_days),room,academicTermId,createdAt,updatedAt,syncStatus);

@override
String toString() {
  return 'ScheduleModel(id: $id, userId: $userId, subjectCode: $subjectCode, subjectName: $subjectName, teacher: $teacher, startTime: $startTime, endTime: $endTime, days: $days, room: $room, academicTermId: $academicTermId, createdAt: $createdAt, updatedAt: $updatedAt, syncStatus: $syncStatus)';
}


}

/// @nodoc
abstract mixin class _$ScheduleModelCopyWith<$Res> implements $ScheduleModelCopyWith<$Res> {
  factory _$ScheduleModelCopyWith(_ScheduleModel value, $Res Function(_ScheduleModel) _then) = __$ScheduleModelCopyWithImpl;
@override @useResult
$Res call({
 String? id,@JsonKey(name: 'user_id') String? userId,@JsonKey(name: 'subject_code') String subjectCode,@JsonKey(name: 'subject_name') String subjectName, String teacher,@JsonKey(name: 'start_time') String startTime,@JsonKey(name: 'end_time') String endTime, List<String> days, String room,@JsonKey(name: 'academic_term_id') String academicTermId,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt, String syncStatus
});




}
/// @nodoc
class __$ScheduleModelCopyWithImpl<$Res>
    implements _$ScheduleModelCopyWith<$Res> {
  __$ScheduleModelCopyWithImpl(this._self, this._then);

  final _ScheduleModel _self;
  final $Res Function(_ScheduleModel) _then;

/// Create a copy of ScheduleModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? userId = freezed,Object? subjectCode = null,Object? subjectName = null,Object? teacher = null,Object? startTime = null,Object? endTime = null,Object? days = null,Object? room = null,Object? academicTermId = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? syncStatus = null,}) {
  return _then(_ScheduleModel(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,subjectCode: null == subjectCode ? _self.subjectCode : subjectCode // ignore: cast_nullable_to_non_nullable
as String,subjectName: null == subjectName ? _self.subjectName : subjectName // ignore: cast_nullable_to_non_nullable
as String,teacher: null == teacher ? _self.teacher : teacher // ignore: cast_nullable_to_non_nullable
as String,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as String,days: null == days ? _self._days : days // ignore: cast_nullable_to_non_nullable
as List<String>,room: null == room ? _self.room : room // ignore: cast_nullable_to_non_nullable
as String,academicTermId: null == academicTermId ? _self.academicTermId : academicTermId // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
