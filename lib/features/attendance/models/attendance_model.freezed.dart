// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'attendance_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AttendanceModel {

 String? get id;@JsonKey(name: 'student_id') String get studentId;@JsonKey(name: 'event_id') String get eventId;@JsonKey(name: 'actual_time_in') DateTime? get actualTimeIn;@JsonKey(name: 'actual_time_out') DateTime? get actualTimeOut; String get status;@JsonKey(name: 'scanned_by_user_id') String? get scannedByUserId;@JsonKey(name: 'override_reason') String? get overrideReason;@JsonKey(name: 'updated_at') DateTime? get updatedAt;
/// Create a copy of AttendanceModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AttendanceModelCopyWith<AttendanceModel> get copyWith => _$AttendanceModelCopyWithImpl<AttendanceModel>(this as AttendanceModel, _$identity);

  /// Serializes this AttendanceModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AttendanceModel&&(identical(other.id, id) || other.id == id)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.actualTimeIn, actualTimeIn) || other.actualTimeIn == actualTimeIn)&&(identical(other.actualTimeOut, actualTimeOut) || other.actualTimeOut == actualTimeOut)&&(identical(other.status, status) || other.status == status)&&(identical(other.scannedByUserId, scannedByUserId) || other.scannedByUserId == scannedByUserId)&&(identical(other.overrideReason, overrideReason) || other.overrideReason == overrideReason)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,studentId,eventId,actualTimeIn,actualTimeOut,status,scannedByUserId,overrideReason,updatedAt);

@override
String toString() {
  return 'AttendanceModel(id: $id, studentId: $studentId, eventId: $eventId, actualTimeIn: $actualTimeIn, actualTimeOut: $actualTimeOut, status: $status, scannedByUserId: $scannedByUserId, overrideReason: $overrideReason, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $AttendanceModelCopyWith<$Res>  {
  factory $AttendanceModelCopyWith(AttendanceModel value, $Res Function(AttendanceModel) _then) = _$AttendanceModelCopyWithImpl;
@useResult
$Res call({
 String? id,@JsonKey(name: 'student_id') String studentId,@JsonKey(name: 'event_id') String eventId,@JsonKey(name: 'actual_time_in') DateTime? actualTimeIn,@JsonKey(name: 'actual_time_out') DateTime? actualTimeOut, String status,@JsonKey(name: 'scanned_by_user_id') String? scannedByUserId,@JsonKey(name: 'override_reason') String? overrideReason,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class _$AttendanceModelCopyWithImpl<$Res>
    implements $AttendanceModelCopyWith<$Res> {
  _$AttendanceModelCopyWithImpl(this._self, this._then);

  final AttendanceModel _self;
  final $Res Function(AttendanceModel) _then;

/// Create a copy of AttendanceModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? studentId = null,Object? eventId = null,Object? actualTimeIn = freezed,Object? actualTimeOut = freezed,Object? status = null,Object? scannedByUserId = freezed,Object? overrideReason = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,studentId: null == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,actualTimeIn: freezed == actualTimeIn ? _self.actualTimeIn : actualTimeIn // ignore: cast_nullable_to_non_nullable
as DateTime?,actualTimeOut: freezed == actualTimeOut ? _self.actualTimeOut : actualTimeOut // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,scannedByUserId: freezed == scannedByUserId ? _self.scannedByUserId : scannedByUserId // ignore: cast_nullable_to_non_nullable
as String?,overrideReason: freezed == overrideReason ? _self.overrideReason : overrideReason // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [AttendanceModel].
extension AttendanceModelPatterns on AttendanceModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AttendanceModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AttendanceModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AttendanceModel value)  $default,){
final _that = this;
switch (_that) {
case _AttendanceModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AttendanceModel value)?  $default,){
final _that = this;
switch (_that) {
case _AttendanceModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'student_id')  String studentId, @JsonKey(name: 'event_id')  String eventId, @JsonKey(name: 'actual_time_in')  DateTime? actualTimeIn, @JsonKey(name: 'actual_time_out')  DateTime? actualTimeOut,  String status, @JsonKey(name: 'scanned_by_user_id')  String? scannedByUserId, @JsonKey(name: 'override_reason')  String? overrideReason, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AttendanceModel() when $default != null:
return $default(_that.id,_that.studentId,_that.eventId,_that.actualTimeIn,_that.actualTimeOut,_that.status,_that.scannedByUserId,_that.overrideReason,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'student_id')  String studentId, @JsonKey(name: 'event_id')  String eventId, @JsonKey(name: 'actual_time_in')  DateTime? actualTimeIn, @JsonKey(name: 'actual_time_out')  DateTime? actualTimeOut,  String status, @JsonKey(name: 'scanned_by_user_id')  String? scannedByUserId, @JsonKey(name: 'override_reason')  String? overrideReason, @JsonKey(name: 'updated_at')  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _AttendanceModel():
return $default(_that.id,_that.studentId,_that.eventId,_that.actualTimeIn,_that.actualTimeOut,_that.status,_that.scannedByUserId,_that.overrideReason,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id, @JsonKey(name: 'student_id')  String studentId, @JsonKey(name: 'event_id')  String eventId, @JsonKey(name: 'actual_time_in')  DateTime? actualTimeIn, @JsonKey(name: 'actual_time_out')  DateTime? actualTimeOut,  String status, @JsonKey(name: 'scanned_by_user_id')  String? scannedByUserId, @JsonKey(name: 'override_reason')  String? overrideReason, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _AttendanceModel() when $default != null:
return $default(_that.id,_that.studentId,_that.eventId,_that.actualTimeIn,_that.actualTimeOut,_that.status,_that.scannedByUserId,_that.overrideReason,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AttendanceModel implements AttendanceModel {
  const _AttendanceModel({this.id, @JsonKey(name: 'student_id') required this.studentId, @JsonKey(name: 'event_id') required this.eventId, @JsonKey(name: 'actual_time_in') this.actualTimeIn, @JsonKey(name: 'actual_time_out') this.actualTimeOut, this.status = 'Pending', @JsonKey(name: 'scanned_by_user_id') this.scannedByUserId, @JsonKey(name: 'override_reason') this.overrideReason, @JsonKey(name: 'updated_at') this.updatedAt});
  factory _AttendanceModel.fromJson(Map<String, dynamic> json) => _$AttendanceModelFromJson(json);

@override final  String? id;
@override@JsonKey(name: 'student_id') final  String studentId;
@override@JsonKey(name: 'event_id') final  String eventId;
@override@JsonKey(name: 'actual_time_in') final  DateTime? actualTimeIn;
@override@JsonKey(name: 'actual_time_out') final  DateTime? actualTimeOut;
@override@JsonKey() final  String status;
@override@JsonKey(name: 'scanned_by_user_id') final  String? scannedByUserId;
@override@JsonKey(name: 'override_reason') final  String? overrideReason;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;

/// Create a copy of AttendanceModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AttendanceModelCopyWith<_AttendanceModel> get copyWith => __$AttendanceModelCopyWithImpl<_AttendanceModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AttendanceModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AttendanceModel&&(identical(other.id, id) || other.id == id)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.actualTimeIn, actualTimeIn) || other.actualTimeIn == actualTimeIn)&&(identical(other.actualTimeOut, actualTimeOut) || other.actualTimeOut == actualTimeOut)&&(identical(other.status, status) || other.status == status)&&(identical(other.scannedByUserId, scannedByUserId) || other.scannedByUserId == scannedByUserId)&&(identical(other.overrideReason, overrideReason) || other.overrideReason == overrideReason)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,studentId,eventId,actualTimeIn,actualTimeOut,status,scannedByUserId,overrideReason,updatedAt);

@override
String toString() {
  return 'AttendanceModel(id: $id, studentId: $studentId, eventId: $eventId, actualTimeIn: $actualTimeIn, actualTimeOut: $actualTimeOut, status: $status, scannedByUserId: $scannedByUserId, overrideReason: $overrideReason, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$AttendanceModelCopyWith<$Res> implements $AttendanceModelCopyWith<$Res> {
  factory _$AttendanceModelCopyWith(_AttendanceModel value, $Res Function(_AttendanceModel) _then) = __$AttendanceModelCopyWithImpl;
@override @useResult
$Res call({
 String? id,@JsonKey(name: 'student_id') String studentId,@JsonKey(name: 'event_id') String eventId,@JsonKey(name: 'actual_time_in') DateTime? actualTimeIn,@JsonKey(name: 'actual_time_out') DateTime? actualTimeOut, String status,@JsonKey(name: 'scanned_by_user_id') String? scannedByUserId,@JsonKey(name: 'override_reason') String? overrideReason,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class __$AttendanceModelCopyWithImpl<$Res>
    implements _$AttendanceModelCopyWith<$Res> {
  __$AttendanceModelCopyWithImpl(this._self, this._then);

  final _AttendanceModel _self;
  final $Res Function(_AttendanceModel) _then;

/// Create a copy of AttendanceModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? studentId = null,Object? eventId = null,Object? actualTimeIn = freezed,Object? actualTimeOut = freezed,Object? status = null,Object? scannedByUserId = freezed,Object? overrideReason = freezed,Object? updatedAt = freezed,}) {
  return _then(_AttendanceModel(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,studentId: null == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,actualTimeIn: freezed == actualTimeIn ? _self.actualTimeIn : actualTimeIn // ignore: cast_nullable_to_non_nullable
as DateTime?,actualTimeOut: freezed == actualTimeOut ? _self.actualTimeOut : actualTimeOut // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,scannedByUserId: freezed == scannedByUserId ? _self.scannedByUserId : scannedByUserId // ignore: cast_nullable_to_non_nullable
as String?,overrideReason: freezed == overrideReason ? _self.overrideReason : overrideReason // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
