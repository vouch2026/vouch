// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'excuse_request_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ExcuseRequestModel {

 String get id;@JsonKey(name: 'student_id') String get studentId;@JsonKey(name: 'event_id') String get eventId; String get reason;@JsonKey(name: 'supporting_document_url') String get supportingDocumentUrl; String get status;// 'Pending', 'Approved', 'Rejected'
@JsonKey(name: 'rejection_reason') String? get rejectionReason;@JsonKey(name: 'scope_type') String get scopeType;@JsonKey(name: 'scope_id') String get scopeId;@JsonKey(name: 'academic_term_id') String get academicTermId;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt;@JsonKey(name: 'reviewed_by_user_id') String? get reviewedByUserId;@JsonKey(name: 'reviewed_at') DateTime? get reviewedAt;// Join fields
@JsonKey(name: 'student_name') String? get studentName;@JsonKey(name: 'student_id_number') String? get studentIdNumber;@JsonKey(name: 'event_name') String? get eventName;@JsonKey(name: 'reviewed_by_name') String? get reviewedByName;
/// Create a copy of ExcuseRequestModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExcuseRequestModelCopyWith<ExcuseRequestModel> get copyWith => _$ExcuseRequestModelCopyWithImpl<ExcuseRequestModel>(this as ExcuseRequestModel, _$identity);

  /// Serializes this ExcuseRequestModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExcuseRequestModel&&(identical(other.id, id) || other.id == id)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.supportingDocumentUrl, supportingDocumentUrl) || other.supportingDocumentUrl == supportingDocumentUrl)&&(identical(other.status, status) || other.status == status)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason)&&(identical(other.scopeType, scopeType) || other.scopeType == scopeType)&&(identical(other.scopeId, scopeId) || other.scopeId == scopeId)&&(identical(other.academicTermId, academicTermId) || other.academicTermId == academicTermId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.reviewedByUserId, reviewedByUserId) || other.reviewedByUserId == reviewedByUserId)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt)&&(identical(other.studentName, studentName) || other.studentName == studentName)&&(identical(other.studentIdNumber, studentIdNumber) || other.studentIdNumber == studentIdNumber)&&(identical(other.eventName, eventName) || other.eventName == eventName)&&(identical(other.reviewedByName, reviewedByName) || other.reviewedByName == reviewedByName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,studentId,eventId,reason,supportingDocumentUrl,status,rejectionReason,scopeType,scopeId,academicTermId,createdAt,updatedAt,reviewedByUserId,reviewedAt,studentName,studentIdNumber,eventName,reviewedByName);

@override
String toString() {
  return 'ExcuseRequestModel(id: $id, studentId: $studentId, eventId: $eventId, reason: $reason, supportingDocumentUrl: $supportingDocumentUrl, status: $status, rejectionReason: $rejectionReason, scopeType: $scopeType, scopeId: $scopeId, academicTermId: $academicTermId, createdAt: $createdAt, updatedAt: $updatedAt, reviewedByUserId: $reviewedByUserId, reviewedAt: $reviewedAt, studentName: $studentName, studentIdNumber: $studentIdNumber, eventName: $eventName, reviewedByName: $reviewedByName)';
}


}

/// @nodoc
abstract mixin class $ExcuseRequestModelCopyWith<$Res>  {
  factory $ExcuseRequestModelCopyWith(ExcuseRequestModel value, $Res Function(ExcuseRequestModel) _then) = _$ExcuseRequestModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'student_id') String studentId,@JsonKey(name: 'event_id') String eventId, String reason,@JsonKey(name: 'supporting_document_url') String supportingDocumentUrl, String status,@JsonKey(name: 'rejection_reason') String? rejectionReason,@JsonKey(name: 'scope_type') String scopeType,@JsonKey(name: 'scope_id') String scopeId,@JsonKey(name: 'academic_term_id') String academicTermId,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt,@JsonKey(name: 'reviewed_by_user_id') String? reviewedByUserId,@JsonKey(name: 'reviewed_at') DateTime? reviewedAt,@JsonKey(name: 'student_name') String? studentName,@JsonKey(name: 'student_id_number') String? studentIdNumber,@JsonKey(name: 'event_name') String? eventName,@JsonKey(name: 'reviewed_by_name') String? reviewedByName
});




}
/// @nodoc
class _$ExcuseRequestModelCopyWithImpl<$Res>
    implements $ExcuseRequestModelCopyWith<$Res> {
  _$ExcuseRequestModelCopyWithImpl(this._self, this._then);

  final ExcuseRequestModel _self;
  final $Res Function(ExcuseRequestModel) _then;

/// Create a copy of ExcuseRequestModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? studentId = null,Object? eventId = null,Object? reason = null,Object? supportingDocumentUrl = null,Object? status = null,Object? rejectionReason = freezed,Object? scopeType = null,Object? scopeId = null,Object? academicTermId = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? reviewedByUserId = freezed,Object? reviewedAt = freezed,Object? studentName = freezed,Object? studentIdNumber = freezed,Object? eventName = freezed,Object? reviewedByName = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,studentId: null == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,supportingDocumentUrl: null == supportingDocumentUrl ? _self.supportingDocumentUrl : supportingDocumentUrl // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,rejectionReason: freezed == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String?,scopeType: null == scopeType ? _self.scopeType : scopeType // ignore: cast_nullable_to_non_nullable
as String,scopeId: null == scopeId ? _self.scopeId : scopeId // ignore: cast_nullable_to_non_nullable
as String,academicTermId: null == academicTermId ? _self.academicTermId : academicTermId // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,reviewedByUserId: freezed == reviewedByUserId ? _self.reviewedByUserId : reviewedByUserId // ignore: cast_nullable_to_non_nullable
as String?,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,studentName: freezed == studentName ? _self.studentName : studentName // ignore: cast_nullable_to_non_nullable
as String?,studentIdNumber: freezed == studentIdNumber ? _self.studentIdNumber : studentIdNumber // ignore: cast_nullable_to_non_nullable
as String?,eventName: freezed == eventName ? _self.eventName : eventName // ignore: cast_nullable_to_non_nullable
as String?,reviewedByName: freezed == reviewedByName ? _self.reviewedByName : reviewedByName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ExcuseRequestModel].
extension ExcuseRequestModelPatterns on ExcuseRequestModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExcuseRequestModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExcuseRequestModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExcuseRequestModel value)  $default,){
final _that = this;
switch (_that) {
case _ExcuseRequestModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExcuseRequestModel value)?  $default,){
final _that = this;
switch (_that) {
case _ExcuseRequestModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'student_id')  String studentId, @JsonKey(name: 'event_id')  String eventId,  String reason, @JsonKey(name: 'supporting_document_url')  String supportingDocumentUrl,  String status, @JsonKey(name: 'rejection_reason')  String? rejectionReason, @JsonKey(name: 'scope_type')  String scopeType, @JsonKey(name: 'scope_id')  String scopeId, @JsonKey(name: 'academic_term_id')  String academicTermId, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt, @JsonKey(name: 'reviewed_by_user_id')  String? reviewedByUserId, @JsonKey(name: 'reviewed_at')  DateTime? reviewedAt, @JsonKey(name: 'student_name')  String? studentName, @JsonKey(name: 'student_id_number')  String? studentIdNumber, @JsonKey(name: 'event_name')  String? eventName, @JsonKey(name: 'reviewed_by_name')  String? reviewedByName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExcuseRequestModel() when $default != null:
return $default(_that.id,_that.studentId,_that.eventId,_that.reason,_that.supportingDocumentUrl,_that.status,_that.rejectionReason,_that.scopeType,_that.scopeId,_that.academicTermId,_that.createdAt,_that.updatedAt,_that.reviewedByUserId,_that.reviewedAt,_that.studentName,_that.studentIdNumber,_that.eventName,_that.reviewedByName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'student_id')  String studentId, @JsonKey(name: 'event_id')  String eventId,  String reason, @JsonKey(name: 'supporting_document_url')  String supportingDocumentUrl,  String status, @JsonKey(name: 'rejection_reason')  String? rejectionReason, @JsonKey(name: 'scope_type')  String scopeType, @JsonKey(name: 'scope_id')  String scopeId, @JsonKey(name: 'academic_term_id')  String academicTermId, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt, @JsonKey(name: 'reviewed_by_user_id')  String? reviewedByUserId, @JsonKey(name: 'reviewed_at')  DateTime? reviewedAt, @JsonKey(name: 'student_name')  String? studentName, @JsonKey(name: 'student_id_number')  String? studentIdNumber, @JsonKey(name: 'event_name')  String? eventName, @JsonKey(name: 'reviewed_by_name')  String? reviewedByName)  $default,) {final _that = this;
switch (_that) {
case _ExcuseRequestModel():
return $default(_that.id,_that.studentId,_that.eventId,_that.reason,_that.supportingDocumentUrl,_that.status,_that.rejectionReason,_that.scopeType,_that.scopeId,_that.academicTermId,_that.createdAt,_that.updatedAt,_that.reviewedByUserId,_that.reviewedAt,_that.studentName,_that.studentIdNumber,_that.eventName,_that.reviewedByName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'student_id')  String studentId, @JsonKey(name: 'event_id')  String eventId,  String reason, @JsonKey(name: 'supporting_document_url')  String supportingDocumentUrl,  String status, @JsonKey(name: 'rejection_reason')  String? rejectionReason, @JsonKey(name: 'scope_type')  String scopeType, @JsonKey(name: 'scope_id')  String scopeId, @JsonKey(name: 'academic_term_id')  String academicTermId, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt, @JsonKey(name: 'reviewed_by_user_id')  String? reviewedByUserId, @JsonKey(name: 'reviewed_at')  DateTime? reviewedAt, @JsonKey(name: 'student_name')  String? studentName, @JsonKey(name: 'student_id_number')  String? studentIdNumber, @JsonKey(name: 'event_name')  String? eventName, @JsonKey(name: 'reviewed_by_name')  String? reviewedByName)?  $default,) {final _that = this;
switch (_that) {
case _ExcuseRequestModel() when $default != null:
return $default(_that.id,_that.studentId,_that.eventId,_that.reason,_that.supportingDocumentUrl,_that.status,_that.rejectionReason,_that.scopeType,_that.scopeId,_that.academicTermId,_that.createdAt,_that.updatedAt,_that.reviewedByUserId,_that.reviewedAt,_that.studentName,_that.studentIdNumber,_that.eventName,_that.reviewedByName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExcuseRequestModel implements ExcuseRequestModel {
  const _ExcuseRequestModel({required this.id, @JsonKey(name: 'student_id') required this.studentId, @JsonKey(name: 'event_id') required this.eventId, required this.reason, @JsonKey(name: 'supporting_document_url') required this.supportingDocumentUrl, this.status = 'Pending', @JsonKey(name: 'rejection_reason') this.rejectionReason, @JsonKey(name: 'scope_type') required this.scopeType, @JsonKey(name: 'scope_id') required this.scopeId, @JsonKey(name: 'academic_term_id') required this.academicTermId, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt, @JsonKey(name: 'reviewed_by_user_id') this.reviewedByUserId, @JsonKey(name: 'reviewed_at') this.reviewedAt, @JsonKey(name: 'student_name') this.studentName, @JsonKey(name: 'student_id_number') this.studentIdNumber, @JsonKey(name: 'event_name') this.eventName, @JsonKey(name: 'reviewed_by_name') this.reviewedByName});
  factory _ExcuseRequestModel.fromJson(Map<String, dynamic> json) => _$ExcuseRequestModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'student_id') final  String studentId;
@override@JsonKey(name: 'event_id') final  String eventId;
@override final  String reason;
@override@JsonKey(name: 'supporting_document_url') final  String supportingDocumentUrl;
@override@JsonKey() final  String status;
// 'Pending', 'Approved', 'Rejected'
@override@JsonKey(name: 'rejection_reason') final  String? rejectionReason;
@override@JsonKey(name: 'scope_type') final  String scopeType;
@override@JsonKey(name: 'scope_id') final  String scopeId;
@override@JsonKey(name: 'academic_term_id') final  String academicTermId;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;
@override@JsonKey(name: 'reviewed_by_user_id') final  String? reviewedByUserId;
@override@JsonKey(name: 'reviewed_at') final  DateTime? reviewedAt;
// Join fields
@override@JsonKey(name: 'student_name') final  String? studentName;
@override@JsonKey(name: 'student_id_number') final  String? studentIdNumber;
@override@JsonKey(name: 'event_name') final  String? eventName;
@override@JsonKey(name: 'reviewed_by_name') final  String? reviewedByName;

/// Create a copy of ExcuseRequestModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExcuseRequestModelCopyWith<_ExcuseRequestModel> get copyWith => __$ExcuseRequestModelCopyWithImpl<_ExcuseRequestModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExcuseRequestModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExcuseRequestModel&&(identical(other.id, id) || other.id == id)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.supportingDocumentUrl, supportingDocumentUrl) || other.supportingDocumentUrl == supportingDocumentUrl)&&(identical(other.status, status) || other.status == status)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason)&&(identical(other.scopeType, scopeType) || other.scopeType == scopeType)&&(identical(other.scopeId, scopeId) || other.scopeId == scopeId)&&(identical(other.academicTermId, academicTermId) || other.academicTermId == academicTermId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.reviewedByUserId, reviewedByUserId) || other.reviewedByUserId == reviewedByUserId)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt)&&(identical(other.studentName, studentName) || other.studentName == studentName)&&(identical(other.studentIdNumber, studentIdNumber) || other.studentIdNumber == studentIdNumber)&&(identical(other.eventName, eventName) || other.eventName == eventName)&&(identical(other.reviewedByName, reviewedByName) || other.reviewedByName == reviewedByName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,studentId,eventId,reason,supportingDocumentUrl,status,rejectionReason,scopeType,scopeId,academicTermId,createdAt,updatedAt,reviewedByUserId,reviewedAt,studentName,studentIdNumber,eventName,reviewedByName);

@override
String toString() {
  return 'ExcuseRequestModel(id: $id, studentId: $studentId, eventId: $eventId, reason: $reason, supportingDocumentUrl: $supportingDocumentUrl, status: $status, rejectionReason: $rejectionReason, scopeType: $scopeType, scopeId: $scopeId, academicTermId: $academicTermId, createdAt: $createdAt, updatedAt: $updatedAt, reviewedByUserId: $reviewedByUserId, reviewedAt: $reviewedAt, studentName: $studentName, studentIdNumber: $studentIdNumber, eventName: $eventName, reviewedByName: $reviewedByName)';
}


}

/// @nodoc
abstract mixin class _$ExcuseRequestModelCopyWith<$Res> implements $ExcuseRequestModelCopyWith<$Res> {
  factory _$ExcuseRequestModelCopyWith(_ExcuseRequestModel value, $Res Function(_ExcuseRequestModel) _then) = __$ExcuseRequestModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'student_id') String studentId,@JsonKey(name: 'event_id') String eventId, String reason,@JsonKey(name: 'supporting_document_url') String supportingDocumentUrl, String status,@JsonKey(name: 'rejection_reason') String? rejectionReason,@JsonKey(name: 'scope_type') String scopeType,@JsonKey(name: 'scope_id') String scopeId,@JsonKey(name: 'academic_term_id') String academicTermId,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt,@JsonKey(name: 'reviewed_by_user_id') String? reviewedByUserId,@JsonKey(name: 'reviewed_at') DateTime? reviewedAt,@JsonKey(name: 'student_name') String? studentName,@JsonKey(name: 'student_id_number') String? studentIdNumber,@JsonKey(name: 'event_name') String? eventName,@JsonKey(name: 'reviewed_by_name') String? reviewedByName
});




}
/// @nodoc
class __$ExcuseRequestModelCopyWithImpl<$Res>
    implements _$ExcuseRequestModelCopyWith<$Res> {
  __$ExcuseRequestModelCopyWithImpl(this._self, this._then);

  final _ExcuseRequestModel _self;
  final $Res Function(_ExcuseRequestModel) _then;

/// Create a copy of ExcuseRequestModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? studentId = null,Object? eventId = null,Object? reason = null,Object? supportingDocumentUrl = null,Object? status = null,Object? rejectionReason = freezed,Object? scopeType = null,Object? scopeId = null,Object? academicTermId = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? reviewedByUserId = freezed,Object? reviewedAt = freezed,Object? studentName = freezed,Object? studentIdNumber = freezed,Object? eventName = freezed,Object? reviewedByName = freezed,}) {
  return _then(_ExcuseRequestModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,studentId: null == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,supportingDocumentUrl: null == supportingDocumentUrl ? _self.supportingDocumentUrl : supportingDocumentUrl // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,rejectionReason: freezed == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String?,scopeType: null == scopeType ? _self.scopeType : scopeType // ignore: cast_nullable_to_non_nullable
as String,scopeId: null == scopeId ? _self.scopeId : scopeId // ignore: cast_nullable_to_non_nullable
as String,academicTermId: null == academicTermId ? _self.academicTermId : academicTermId // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,reviewedByUserId: freezed == reviewedByUserId ? _self.reviewedByUserId : reviewedByUserId // ignore: cast_nullable_to_non_nullable
as String?,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,studentName: freezed == studentName ? _self.studentName : studentName // ignore: cast_nullable_to_non_nullable
as String?,studentIdNumber: freezed == studentIdNumber ? _self.studentIdNumber : studentIdNumber // ignore: cast_nullable_to_non_nullable
as String?,eventName: freezed == eventName ? _self.eventName : eventName // ignore: cast_nullable_to_non_nullable
as String?,reviewedByName: freezed == reviewedByName ? _self.reviewedByName : reviewedByName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
