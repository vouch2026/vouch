// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'account_deletion_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AccountDeletionRequest {

 String get id;@JsonKey(name: 'user_id') String get userId; String get email;@JsonKey(name: 'student_id_number') String get studentIdNumber;@JsonKey(name: 'full_name') String get fullName;@JsonKey(name: 'acknowledged_clearance') bool get acknowledgedClearance;@JsonKey(name: 'acknowledged_data_loss') bool get acknowledgedDataLoss; String get status;@JsonKey(name: 'created_at') DateTime? get createdAt;
/// Create a copy of AccountDeletionRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccountDeletionRequestCopyWith<AccountDeletionRequest> get copyWith => _$AccountDeletionRequestCopyWithImpl<AccountDeletionRequest>(this as AccountDeletionRequest, _$identity);

  /// Serializes this AccountDeletionRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AccountDeletionRequest&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.email, email) || other.email == email)&&(identical(other.studentIdNumber, studentIdNumber) || other.studentIdNumber == studentIdNumber)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.acknowledgedClearance, acknowledgedClearance) || other.acknowledgedClearance == acknowledgedClearance)&&(identical(other.acknowledgedDataLoss, acknowledgedDataLoss) || other.acknowledgedDataLoss == acknowledgedDataLoss)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,email,studentIdNumber,fullName,acknowledgedClearance,acknowledgedDataLoss,status,createdAt);

@override
String toString() {
  return 'AccountDeletionRequest(id: $id, userId: $userId, email: $email, studentIdNumber: $studentIdNumber, fullName: $fullName, acknowledgedClearance: $acknowledgedClearance, acknowledgedDataLoss: $acknowledgedDataLoss, status: $status, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $AccountDeletionRequestCopyWith<$Res>  {
  factory $AccountDeletionRequestCopyWith(AccountDeletionRequest value, $Res Function(AccountDeletionRequest) _then) = _$AccountDeletionRequestCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId, String email,@JsonKey(name: 'student_id_number') String studentIdNumber,@JsonKey(name: 'full_name') String fullName,@JsonKey(name: 'acknowledged_clearance') bool acknowledgedClearance,@JsonKey(name: 'acknowledged_data_loss') bool acknowledgedDataLoss, String status,@JsonKey(name: 'created_at') DateTime? createdAt
});




}
/// @nodoc
class _$AccountDeletionRequestCopyWithImpl<$Res>
    implements $AccountDeletionRequestCopyWith<$Res> {
  _$AccountDeletionRequestCopyWithImpl(this._self, this._then);

  final AccountDeletionRequest _self;
  final $Res Function(AccountDeletionRequest) _then;

/// Create a copy of AccountDeletionRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? email = null,Object? studentIdNumber = null,Object? fullName = null,Object? acknowledgedClearance = null,Object? acknowledgedDataLoss = null,Object? status = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,studentIdNumber: null == studentIdNumber ? _self.studentIdNumber : studentIdNumber // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,acknowledgedClearance: null == acknowledgedClearance ? _self.acknowledgedClearance : acknowledgedClearance // ignore: cast_nullable_to_non_nullable
as bool,acknowledgedDataLoss: null == acknowledgedDataLoss ? _self.acknowledgedDataLoss : acknowledgedDataLoss // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [AccountDeletionRequest].
extension AccountDeletionRequestPatterns on AccountDeletionRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AccountDeletionRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AccountDeletionRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AccountDeletionRequest value)  $default,){
final _that = this;
switch (_that) {
case _AccountDeletionRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AccountDeletionRequest value)?  $default,){
final _that = this;
switch (_that) {
case _AccountDeletionRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId,  String email, @JsonKey(name: 'student_id_number')  String studentIdNumber, @JsonKey(name: 'full_name')  String fullName, @JsonKey(name: 'acknowledged_clearance')  bool acknowledgedClearance, @JsonKey(name: 'acknowledged_data_loss')  bool acknowledgedDataLoss,  String status, @JsonKey(name: 'created_at')  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AccountDeletionRequest() when $default != null:
return $default(_that.id,_that.userId,_that.email,_that.studentIdNumber,_that.fullName,_that.acknowledgedClearance,_that.acknowledgedDataLoss,_that.status,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId,  String email, @JsonKey(name: 'student_id_number')  String studentIdNumber, @JsonKey(name: 'full_name')  String fullName, @JsonKey(name: 'acknowledged_clearance')  bool acknowledgedClearance, @JsonKey(name: 'acknowledged_data_loss')  bool acknowledgedDataLoss,  String status, @JsonKey(name: 'created_at')  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _AccountDeletionRequest():
return $default(_that.id,_that.userId,_that.email,_that.studentIdNumber,_that.fullName,_that.acknowledgedClearance,_that.acknowledgedDataLoss,_that.status,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'user_id')  String userId,  String email, @JsonKey(name: 'student_id_number')  String studentIdNumber, @JsonKey(name: 'full_name')  String fullName, @JsonKey(name: 'acknowledged_clearance')  bool acknowledgedClearance, @JsonKey(name: 'acknowledged_data_loss')  bool acknowledgedDataLoss,  String status, @JsonKey(name: 'created_at')  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _AccountDeletionRequest() when $default != null:
return $default(_that.id,_that.userId,_that.email,_that.studentIdNumber,_that.fullName,_that.acknowledgedClearance,_that.acknowledgedDataLoss,_that.status,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AccountDeletionRequest implements AccountDeletionRequest {
  const _AccountDeletionRequest({required this.id, @JsonKey(name: 'user_id') required this.userId, required this.email, @JsonKey(name: 'student_id_number') required this.studentIdNumber, @JsonKey(name: 'full_name') required this.fullName, @JsonKey(name: 'acknowledged_clearance') required this.acknowledgedClearance, @JsonKey(name: 'acknowledged_data_loss') required this.acknowledgedDataLoss, this.status = 'pending', @JsonKey(name: 'created_at') this.createdAt});
  factory _AccountDeletionRequest.fromJson(Map<String, dynamic> json) => _$AccountDeletionRequestFromJson(json);

@override final  String id;
@override@JsonKey(name: 'user_id') final  String userId;
@override final  String email;
@override@JsonKey(name: 'student_id_number') final  String studentIdNumber;
@override@JsonKey(name: 'full_name') final  String fullName;
@override@JsonKey(name: 'acknowledged_clearance') final  bool acknowledgedClearance;
@override@JsonKey(name: 'acknowledged_data_loss') final  bool acknowledgedDataLoss;
@override@JsonKey() final  String status;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;

/// Create a copy of AccountDeletionRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AccountDeletionRequestCopyWith<_AccountDeletionRequest> get copyWith => __$AccountDeletionRequestCopyWithImpl<_AccountDeletionRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AccountDeletionRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AccountDeletionRequest&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.email, email) || other.email == email)&&(identical(other.studentIdNumber, studentIdNumber) || other.studentIdNumber == studentIdNumber)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.acknowledgedClearance, acknowledgedClearance) || other.acknowledgedClearance == acknowledgedClearance)&&(identical(other.acknowledgedDataLoss, acknowledgedDataLoss) || other.acknowledgedDataLoss == acknowledgedDataLoss)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,email,studentIdNumber,fullName,acknowledgedClearance,acknowledgedDataLoss,status,createdAt);

@override
String toString() {
  return 'AccountDeletionRequest(id: $id, userId: $userId, email: $email, studentIdNumber: $studentIdNumber, fullName: $fullName, acknowledgedClearance: $acknowledgedClearance, acknowledgedDataLoss: $acknowledgedDataLoss, status: $status, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$AccountDeletionRequestCopyWith<$Res> implements $AccountDeletionRequestCopyWith<$Res> {
  factory _$AccountDeletionRequestCopyWith(_AccountDeletionRequest value, $Res Function(_AccountDeletionRequest) _then) = __$AccountDeletionRequestCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId, String email,@JsonKey(name: 'student_id_number') String studentIdNumber,@JsonKey(name: 'full_name') String fullName,@JsonKey(name: 'acknowledged_clearance') bool acknowledgedClearance,@JsonKey(name: 'acknowledged_data_loss') bool acknowledgedDataLoss, String status,@JsonKey(name: 'created_at') DateTime? createdAt
});




}
/// @nodoc
class __$AccountDeletionRequestCopyWithImpl<$Res>
    implements _$AccountDeletionRequestCopyWith<$Res> {
  __$AccountDeletionRequestCopyWithImpl(this._self, this._then);

  final _AccountDeletionRequest _self;
  final $Res Function(_AccountDeletionRequest) _then;

/// Create a copy of AccountDeletionRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? email = null,Object? studentIdNumber = null,Object? fullName = null,Object? acknowledgedClearance = null,Object? acknowledgedDataLoss = null,Object? status = null,Object? createdAt = freezed,}) {
  return _then(_AccountDeletionRequest(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,studentIdNumber: null == studentIdNumber ? _self.studentIdNumber : studentIdNumber // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,acknowledgedClearance: null == acknowledgedClearance ? _self.acknowledgedClearance : acknowledgedClearance // ignore: cast_nullable_to_non_nullable
as bool,acknowledgedDataLoss: null == acknowledgedDataLoss ? _self.acknowledgedDataLoss : acknowledgedDataLoss // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
