// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'student_payment_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StudentPaymentModel {

 String? get id;@JsonKey(name: 'student_id') String get studentId;@JsonKey(name: 'fee_id') String get feeId;@JsonKey(name: 'reference_number') String get referenceNumber;@JsonKey(name: 'proof_photo_url') String? get proofPhotoUrl;@JsonKey(name: 'payment_receiver_id') String? get paymentReceiverId;@JsonKey(name: 'rejection_note') String? get rejectionNote; String get status;@JsonKey(name: 'amount_paid') double get amountPaid;@JsonKey(name: 'paid_at') DateTime? get paidAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt;@JsonKey(name: 'received_by_user_id') String? get receivedByUserId;// Virtual fields for display
@JsonKey(includeFromJson: true, includeToJson: false) String? get studentName;@JsonKey(includeFromJson: true, includeToJson: false) String? get studentIdNumber;@JsonKey(includeFromJson: true, includeToJson: false) String? get feeName;
/// Create a copy of StudentPaymentModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StudentPaymentModelCopyWith<StudentPaymentModel> get copyWith => _$StudentPaymentModelCopyWithImpl<StudentPaymentModel>(this as StudentPaymentModel, _$identity);

  /// Serializes this StudentPaymentModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StudentPaymentModel&&(identical(other.id, id) || other.id == id)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.feeId, feeId) || other.feeId == feeId)&&(identical(other.referenceNumber, referenceNumber) || other.referenceNumber == referenceNumber)&&(identical(other.proofPhotoUrl, proofPhotoUrl) || other.proofPhotoUrl == proofPhotoUrl)&&(identical(other.paymentReceiverId, paymentReceiverId) || other.paymentReceiverId == paymentReceiverId)&&(identical(other.rejectionNote, rejectionNote) || other.rejectionNote == rejectionNote)&&(identical(other.status, status) || other.status == status)&&(identical(other.amountPaid, amountPaid) || other.amountPaid == amountPaid)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.receivedByUserId, receivedByUserId) || other.receivedByUserId == receivedByUserId)&&(identical(other.studentName, studentName) || other.studentName == studentName)&&(identical(other.studentIdNumber, studentIdNumber) || other.studentIdNumber == studentIdNumber)&&(identical(other.feeName, feeName) || other.feeName == feeName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,studentId,feeId,referenceNumber,proofPhotoUrl,paymentReceiverId,rejectionNote,status,amountPaid,paidAt,updatedAt,receivedByUserId,studentName,studentIdNumber,feeName);

@override
String toString() {
  return 'StudentPaymentModel(id: $id, studentId: $studentId, feeId: $feeId, referenceNumber: $referenceNumber, proofPhotoUrl: $proofPhotoUrl, paymentReceiverId: $paymentReceiverId, rejectionNote: $rejectionNote, status: $status, amountPaid: $amountPaid, paidAt: $paidAt, updatedAt: $updatedAt, receivedByUserId: $receivedByUserId, studentName: $studentName, studentIdNumber: $studentIdNumber, feeName: $feeName)';
}


}

/// @nodoc
abstract mixin class $StudentPaymentModelCopyWith<$Res>  {
  factory $StudentPaymentModelCopyWith(StudentPaymentModel value, $Res Function(StudentPaymentModel) _then) = _$StudentPaymentModelCopyWithImpl;
@useResult
$Res call({
 String? id,@JsonKey(name: 'student_id') String studentId,@JsonKey(name: 'fee_id') String feeId,@JsonKey(name: 'reference_number') String referenceNumber,@JsonKey(name: 'proof_photo_url') String? proofPhotoUrl,@JsonKey(name: 'payment_receiver_id') String? paymentReceiverId,@JsonKey(name: 'rejection_note') String? rejectionNote, String status,@JsonKey(name: 'amount_paid') double amountPaid,@JsonKey(name: 'paid_at') DateTime? paidAt,@JsonKey(name: 'updated_at') DateTime? updatedAt,@JsonKey(name: 'received_by_user_id') String? receivedByUserId,@JsonKey(includeFromJson: true, includeToJson: false) String? studentName,@JsonKey(includeFromJson: true, includeToJson: false) String? studentIdNumber,@JsonKey(includeFromJson: true, includeToJson: false) String? feeName
});




}
/// @nodoc
class _$StudentPaymentModelCopyWithImpl<$Res>
    implements $StudentPaymentModelCopyWith<$Res> {
  _$StudentPaymentModelCopyWithImpl(this._self, this._then);

  final StudentPaymentModel _self;
  final $Res Function(StudentPaymentModel) _then;

/// Create a copy of StudentPaymentModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? studentId = null,Object? feeId = null,Object? referenceNumber = null,Object? proofPhotoUrl = freezed,Object? paymentReceiverId = freezed,Object? rejectionNote = freezed,Object? status = null,Object? amountPaid = null,Object? paidAt = freezed,Object? updatedAt = freezed,Object? receivedByUserId = freezed,Object? studentName = freezed,Object? studentIdNumber = freezed,Object? feeName = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,studentId: null == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String,feeId: null == feeId ? _self.feeId : feeId // ignore: cast_nullable_to_non_nullable
as String,referenceNumber: null == referenceNumber ? _self.referenceNumber : referenceNumber // ignore: cast_nullable_to_non_nullable
as String,proofPhotoUrl: freezed == proofPhotoUrl ? _self.proofPhotoUrl : proofPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,paymentReceiverId: freezed == paymentReceiverId ? _self.paymentReceiverId : paymentReceiverId // ignore: cast_nullable_to_non_nullable
as String?,rejectionNote: freezed == rejectionNote ? _self.rejectionNote : rejectionNote // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,amountPaid: null == amountPaid ? _self.amountPaid : amountPaid // ignore: cast_nullable_to_non_nullable
as double,paidAt: freezed == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,receivedByUserId: freezed == receivedByUserId ? _self.receivedByUserId : receivedByUserId // ignore: cast_nullable_to_non_nullable
as String?,studentName: freezed == studentName ? _self.studentName : studentName // ignore: cast_nullable_to_non_nullable
as String?,studentIdNumber: freezed == studentIdNumber ? _self.studentIdNumber : studentIdNumber // ignore: cast_nullable_to_non_nullable
as String?,feeName: freezed == feeName ? _self.feeName : feeName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [StudentPaymentModel].
extension StudentPaymentModelPatterns on StudentPaymentModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StudentPaymentModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StudentPaymentModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StudentPaymentModel value)  $default,){
final _that = this;
switch (_that) {
case _StudentPaymentModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StudentPaymentModel value)?  $default,){
final _that = this;
switch (_that) {
case _StudentPaymentModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'student_id')  String studentId, @JsonKey(name: 'fee_id')  String feeId, @JsonKey(name: 'reference_number')  String referenceNumber, @JsonKey(name: 'proof_photo_url')  String? proofPhotoUrl, @JsonKey(name: 'payment_receiver_id')  String? paymentReceiverId, @JsonKey(name: 'rejection_note')  String? rejectionNote,  String status, @JsonKey(name: 'amount_paid')  double amountPaid, @JsonKey(name: 'paid_at')  DateTime? paidAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt, @JsonKey(name: 'received_by_user_id')  String? receivedByUserId, @JsonKey(includeFromJson: true, includeToJson: false)  String? studentName, @JsonKey(includeFromJson: true, includeToJson: false)  String? studentIdNumber, @JsonKey(includeFromJson: true, includeToJson: false)  String? feeName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StudentPaymentModel() when $default != null:
return $default(_that.id,_that.studentId,_that.feeId,_that.referenceNumber,_that.proofPhotoUrl,_that.paymentReceiverId,_that.rejectionNote,_that.status,_that.amountPaid,_that.paidAt,_that.updatedAt,_that.receivedByUserId,_that.studentName,_that.studentIdNumber,_that.feeName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'student_id')  String studentId, @JsonKey(name: 'fee_id')  String feeId, @JsonKey(name: 'reference_number')  String referenceNumber, @JsonKey(name: 'proof_photo_url')  String? proofPhotoUrl, @JsonKey(name: 'payment_receiver_id')  String? paymentReceiverId, @JsonKey(name: 'rejection_note')  String? rejectionNote,  String status, @JsonKey(name: 'amount_paid')  double amountPaid, @JsonKey(name: 'paid_at')  DateTime? paidAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt, @JsonKey(name: 'received_by_user_id')  String? receivedByUserId, @JsonKey(includeFromJson: true, includeToJson: false)  String? studentName, @JsonKey(includeFromJson: true, includeToJson: false)  String? studentIdNumber, @JsonKey(includeFromJson: true, includeToJson: false)  String? feeName)  $default,) {final _that = this;
switch (_that) {
case _StudentPaymentModel():
return $default(_that.id,_that.studentId,_that.feeId,_that.referenceNumber,_that.proofPhotoUrl,_that.paymentReceiverId,_that.rejectionNote,_that.status,_that.amountPaid,_that.paidAt,_that.updatedAt,_that.receivedByUserId,_that.studentName,_that.studentIdNumber,_that.feeName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id, @JsonKey(name: 'student_id')  String studentId, @JsonKey(name: 'fee_id')  String feeId, @JsonKey(name: 'reference_number')  String referenceNumber, @JsonKey(name: 'proof_photo_url')  String? proofPhotoUrl, @JsonKey(name: 'payment_receiver_id')  String? paymentReceiverId, @JsonKey(name: 'rejection_note')  String? rejectionNote,  String status, @JsonKey(name: 'amount_paid')  double amountPaid, @JsonKey(name: 'paid_at')  DateTime? paidAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt, @JsonKey(name: 'received_by_user_id')  String? receivedByUserId, @JsonKey(includeFromJson: true, includeToJson: false)  String? studentName, @JsonKey(includeFromJson: true, includeToJson: false)  String? studentIdNumber, @JsonKey(includeFromJson: true, includeToJson: false)  String? feeName)?  $default,) {final _that = this;
switch (_that) {
case _StudentPaymentModel() when $default != null:
return $default(_that.id,_that.studentId,_that.feeId,_that.referenceNumber,_that.proofPhotoUrl,_that.paymentReceiverId,_that.rejectionNote,_that.status,_that.amountPaid,_that.paidAt,_that.updatedAt,_that.receivedByUserId,_that.studentName,_that.studentIdNumber,_that.feeName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StudentPaymentModel implements StudentPaymentModel {
  const _StudentPaymentModel({this.id, @JsonKey(name: 'student_id') required this.studentId, @JsonKey(name: 'fee_id') required this.feeId, @JsonKey(name: 'reference_number') required this.referenceNumber, @JsonKey(name: 'proof_photo_url') this.proofPhotoUrl, @JsonKey(name: 'payment_receiver_id') this.paymentReceiverId, @JsonKey(name: 'rejection_note') this.rejectionNote, this.status = 'Pending', @JsonKey(name: 'amount_paid') required this.amountPaid, @JsonKey(name: 'paid_at') this.paidAt, @JsonKey(name: 'updated_at') this.updatedAt, @JsonKey(name: 'received_by_user_id') this.receivedByUserId, @JsonKey(includeFromJson: true, includeToJson: false) this.studentName, @JsonKey(includeFromJson: true, includeToJson: false) this.studentIdNumber, @JsonKey(includeFromJson: true, includeToJson: false) this.feeName});
  factory _StudentPaymentModel.fromJson(Map<String, dynamic> json) => _$StudentPaymentModelFromJson(json);

@override final  String? id;
@override@JsonKey(name: 'student_id') final  String studentId;
@override@JsonKey(name: 'fee_id') final  String feeId;
@override@JsonKey(name: 'reference_number') final  String referenceNumber;
@override@JsonKey(name: 'proof_photo_url') final  String? proofPhotoUrl;
@override@JsonKey(name: 'payment_receiver_id') final  String? paymentReceiverId;
@override@JsonKey(name: 'rejection_note') final  String? rejectionNote;
@override@JsonKey() final  String status;
@override@JsonKey(name: 'amount_paid') final  double amountPaid;
@override@JsonKey(name: 'paid_at') final  DateTime? paidAt;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;
@override@JsonKey(name: 'received_by_user_id') final  String? receivedByUserId;
// Virtual fields for display
@override@JsonKey(includeFromJson: true, includeToJson: false) final  String? studentName;
@override@JsonKey(includeFromJson: true, includeToJson: false) final  String? studentIdNumber;
@override@JsonKey(includeFromJson: true, includeToJson: false) final  String? feeName;

/// Create a copy of StudentPaymentModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StudentPaymentModelCopyWith<_StudentPaymentModel> get copyWith => __$StudentPaymentModelCopyWithImpl<_StudentPaymentModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StudentPaymentModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StudentPaymentModel&&(identical(other.id, id) || other.id == id)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.feeId, feeId) || other.feeId == feeId)&&(identical(other.referenceNumber, referenceNumber) || other.referenceNumber == referenceNumber)&&(identical(other.proofPhotoUrl, proofPhotoUrl) || other.proofPhotoUrl == proofPhotoUrl)&&(identical(other.paymentReceiverId, paymentReceiverId) || other.paymentReceiverId == paymentReceiverId)&&(identical(other.rejectionNote, rejectionNote) || other.rejectionNote == rejectionNote)&&(identical(other.status, status) || other.status == status)&&(identical(other.amountPaid, amountPaid) || other.amountPaid == amountPaid)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.receivedByUserId, receivedByUserId) || other.receivedByUserId == receivedByUserId)&&(identical(other.studentName, studentName) || other.studentName == studentName)&&(identical(other.studentIdNumber, studentIdNumber) || other.studentIdNumber == studentIdNumber)&&(identical(other.feeName, feeName) || other.feeName == feeName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,studentId,feeId,referenceNumber,proofPhotoUrl,paymentReceiverId,rejectionNote,status,amountPaid,paidAt,updatedAt,receivedByUserId,studentName,studentIdNumber,feeName);

@override
String toString() {
  return 'StudentPaymentModel(id: $id, studentId: $studentId, feeId: $feeId, referenceNumber: $referenceNumber, proofPhotoUrl: $proofPhotoUrl, paymentReceiverId: $paymentReceiverId, rejectionNote: $rejectionNote, status: $status, amountPaid: $amountPaid, paidAt: $paidAt, updatedAt: $updatedAt, receivedByUserId: $receivedByUserId, studentName: $studentName, studentIdNumber: $studentIdNumber, feeName: $feeName)';
}


}

/// @nodoc
abstract mixin class _$StudentPaymentModelCopyWith<$Res> implements $StudentPaymentModelCopyWith<$Res> {
  factory _$StudentPaymentModelCopyWith(_StudentPaymentModel value, $Res Function(_StudentPaymentModel) _then) = __$StudentPaymentModelCopyWithImpl;
@override @useResult
$Res call({
 String? id,@JsonKey(name: 'student_id') String studentId,@JsonKey(name: 'fee_id') String feeId,@JsonKey(name: 'reference_number') String referenceNumber,@JsonKey(name: 'proof_photo_url') String? proofPhotoUrl,@JsonKey(name: 'payment_receiver_id') String? paymentReceiverId,@JsonKey(name: 'rejection_note') String? rejectionNote, String status,@JsonKey(name: 'amount_paid') double amountPaid,@JsonKey(name: 'paid_at') DateTime? paidAt,@JsonKey(name: 'updated_at') DateTime? updatedAt,@JsonKey(name: 'received_by_user_id') String? receivedByUserId,@JsonKey(includeFromJson: true, includeToJson: false) String? studentName,@JsonKey(includeFromJson: true, includeToJson: false) String? studentIdNumber,@JsonKey(includeFromJson: true, includeToJson: false) String? feeName
});




}
/// @nodoc
class __$StudentPaymentModelCopyWithImpl<$Res>
    implements _$StudentPaymentModelCopyWith<$Res> {
  __$StudentPaymentModelCopyWithImpl(this._self, this._then);

  final _StudentPaymentModel _self;
  final $Res Function(_StudentPaymentModel) _then;

/// Create a copy of StudentPaymentModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? studentId = null,Object? feeId = null,Object? referenceNumber = null,Object? proofPhotoUrl = freezed,Object? paymentReceiverId = freezed,Object? rejectionNote = freezed,Object? status = null,Object? amountPaid = null,Object? paidAt = freezed,Object? updatedAt = freezed,Object? receivedByUserId = freezed,Object? studentName = freezed,Object? studentIdNumber = freezed,Object? feeName = freezed,}) {
  return _then(_StudentPaymentModel(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,studentId: null == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String,feeId: null == feeId ? _self.feeId : feeId // ignore: cast_nullable_to_non_nullable
as String,referenceNumber: null == referenceNumber ? _self.referenceNumber : referenceNumber // ignore: cast_nullable_to_non_nullable
as String,proofPhotoUrl: freezed == proofPhotoUrl ? _self.proofPhotoUrl : proofPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,paymentReceiverId: freezed == paymentReceiverId ? _self.paymentReceiverId : paymentReceiverId // ignore: cast_nullable_to_non_nullable
as String?,rejectionNote: freezed == rejectionNote ? _self.rejectionNote : rejectionNote // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,amountPaid: null == amountPaid ? _self.amountPaid : amountPaid // ignore: cast_nullable_to_non_nullable
as double,paidAt: freezed == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,receivedByUserId: freezed == receivedByUserId ? _self.receivedByUserId : receivedByUserId // ignore: cast_nullable_to_non_nullable
as String?,studentName: freezed == studentName ? _self.studentName : studentName // ignore: cast_nullable_to_non_nullable
as String?,studentIdNumber: freezed == studentIdNumber ? _self.studentIdNumber : studentIdNumber // ignore: cast_nullable_to_non_nullable
as String?,feeName: freezed == feeName ? _self.feeName : feeName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
