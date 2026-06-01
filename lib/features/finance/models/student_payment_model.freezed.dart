// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'student_payment_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

StudentPaymentModel _$StudentPaymentModelFromJson(Map<String, dynamic> json) {
  return _StudentPaymentModel.fromJson(json);
}

/// @nodoc
mixin _$StudentPaymentModel {
  String? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'student_id')
  String get studentId => throw _privateConstructorUsedError;
  @JsonKey(name: 'fee_id')
  String get feeId => throw _privateConstructorUsedError;
  @JsonKey(name: 'reference_number')
  String get referenceNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'proof_photo_url')
  String? get proofPhotoUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'payment_receiver_id')
  String? get paymentReceiverId => throw _privateConstructorUsedError;
  @JsonKey(name: 'rejection_note')
  String? get rejectionNote => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'amount_paid')
  double get amountPaid => throw _privateConstructorUsedError;
  @JsonKey(name: 'paid_at')
  DateTime? get paidAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'received_by_user_id')
  String? get receivedByUserId => throw _privateConstructorUsedError; // Virtual fields for display
  @JsonKey(includeFromJson: true, includeToJson: false)
  String? get studentName => throw _privateConstructorUsedError;
  @JsonKey(includeFromJson: true, includeToJson: false)
  String? get studentIdNumber => throw _privateConstructorUsedError;
  @JsonKey(includeFromJson: true, includeToJson: false)
  String? get feeName => throw _privateConstructorUsedError;

  /// Serializes this StudentPaymentModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StudentPaymentModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StudentPaymentModelCopyWith<StudentPaymentModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StudentPaymentModelCopyWith<$Res> {
  factory $StudentPaymentModelCopyWith(
    StudentPaymentModel value,
    $Res Function(StudentPaymentModel) then,
  ) = _$StudentPaymentModelCopyWithImpl<$Res, StudentPaymentModel>;
  @useResult
  $Res call({
    String? id,
    @JsonKey(name: 'student_id') String studentId,
    @JsonKey(name: 'fee_id') String feeId,
    @JsonKey(name: 'reference_number') String referenceNumber,
    @JsonKey(name: 'proof_photo_url') String? proofPhotoUrl,
    @JsonKey(name: 'payment_receiver_id') String? paymentReceiverId,
    @JsonKey(name: 'rejection_note') String? rejectionNote,
    String status,
    @JsonKey(name: 'amount_paid') double amountPaid,
    @JsonKey(name: 'paid_at') DateTime? paidAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @JsonKey(name: 'received_by_user_id') String? receivedByUserId,
    @JsonKey(includeFromJson: true, includeToJson: false) String? studentName,
    @JsonKey(includeFromJson: true, includeToJson: false)
    String? studentIdNumber,
    @JsonKey(includeFromJson: true, includeToJson: false) String? feeName,
  });
}

/// @nodoc
class _$StudentPaymentModelCopyWithImpl<$Res, $Val extends StudentPaymentModel>
    implements $StudentPaymentModelCopyWith<$Res> {
  _$StudentPaymentModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StudentPaymentModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? studentId = null,
    Object? feeId = null,
    Object? referenceNumber = null,
    Object? proofPhotoUrl = freezed,
    Object? paymentReceiverId = freezed,
    Object? rejectionNote = freezed,
    Object? status = null,
    Object? amountPaid = null,
    Object? paidAt = freezed,
    Object? updatedAt = freezed,
    Object? receivedByUserId = freezed,
    Object? studentName = freezed,
    Object? studentIdNumber = freezed,
    Object? feeName = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String?,
            studentId: null == studentId
                ? _value.studentId
                : studentId // ignore: cast_nullable_to_non_nullable
                      as String,
            feeId: null == feeId
                ? _value.feeId
                : feeId // ignore: cast_nullable_to_non_nullable
                      as String,
            referenceNumber: null == referenceNumber
                ? _value.referenceNumber
                : referenceNumber // ignore: cast_nullable_to_non_nullable
                      as String,
            proofPhotoUrl: freezed == proofPhotoUrl
                ? _value.proofPhotoUrl
                : proofPhotoUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            paymentReceiverId: freezed == paymentReceiverId
                ? _value.paymentReceiverId
                : paymentReceiverId // ignore: cast_nullable_to_non_nullable
                      as String?,
            rejectionNote: freezed == rejectionNote
                ? _value.rejectionNote
                : rejectionNote // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            amountPaid: null == amountPaid
                ? _value.amountPaid
                : amountPaid // ignore: cast_nullable_to_non_nullable
                      as double,
            paidAt: freezed == paidAt
                ? _value.paidAt
                : paidAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            receivedByUserId: freezed == receivedByUserId
                ? _value.receivedByUserId
                : receivedByUserId // ignore: cast_nullable_to_non_nullable
                      as String?,
            studentName: freezed == studentName
                ? _value.studentName
                : studentName // ignore: cast_nullable_to_non_nullable
                      as String?,
            studentIdNumber: freezed == studentIdNumber
                ? _value.studentIdNumber
                : studentIdNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
            feeName: freezed == feeName
                ? _value.feeName
                : feeName // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StudentPaymentModelImplCopyWith<$Res>
    implements $StudentPaymentModelCopyWith<$Res> {
  factory _$$StudentPaymentModelImplCopyWith(
    _$StudentPaymentModelImpl value,
    $Res Function(_$StudentPaymentModelImpl) then,
  ) = __$$StudentPaymentModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? id,
    @JsonKey(name: 'student_id') String studentId,
    @JsonKey(name: 'fee_id') String feeId,
    @JsonKey(name: 'reference_number') String referenceNumber,
    @JsonKey(name: 'proof_photo_url') String? proofPhotoUrl,
    @JsonKey(name: 'payment_receiver_id') String? paymentReceiverId,
    @JsonKey(name: 'rejection_note') String? rejectionNote,
    String status,
    @JsonKey(name: 'amount_paid') double amountPaid,
    @JsonKey(name: 'paid_at') DateTime? paidAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @JsonKey(name: 'received_by_user_id') String? receivedByUserId,
    @JsonKey(includeFromJson: true, includeToJson: false) String? studentName,
    @JsonKey(includeFromJson: true, includeToJson: false)
    String? studentIdNumber,
    @JsonKey(includeFromJson: true, includeToJson: false) String? feeName,
  });
}

/// @nodoc
class __$$StudentPaymentModelImplCopyWithImpl<$Res>
    extends _$StudentPaymentModelCopyWithImpl<$Res, _$StudentPaymentModelImpl>
    implements _$$StudentPaymentModelImplCopyWith<$Res> {
  __$$StudentPaymentModelImplCopyWithImpl(
    _$StudentPaymentModelImpl _value,
    $Res Function(_$StudentPaymentModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StudentPaymentModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? studentId = null,
    Object? feeId = null,
    Object? referenceNumber = null,
    Object? proofPhotoUrl = freezed,
    Object? paymentReceiverId = freezed,
    Object? rejectionNote = freezed,
    Object? status = null,
    Object? amountPaid = null,
    Object? paidAt = freezed,
    Object? updatedAt = freezed,
    Object? receivedByUserId = freezed,
    Object? studentName = freezed,
    Object? studentIdNumber = freezed,
    Object? feeName = freezed,
  }) {
    return _then(
      _$StudentPaymentModelImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String?,
        studentId: null == studentId
            ? _value.studentId
            : studentId // ignore: cast_nullable_to_non_nullable
                  as String,
        feeId: null == feeId
            ? _value.feeId
            : feeId // ignore: cast_nullable_to_non_nullable
                  as String,
        referenceNumber: null == referenceNumber
            ? _value.referenceNumber
            : referenceNumber // ignore: cast_nullable_to_non_nullable
                  as String,
        proofPhotoUrl: freezed == proofPhotoUrl
            ? _value.proofPhotoUrl
            : proofPhotoUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        paymentReceiverId: freezed == paymentReceiverId
            ? _value.paymentReceiverId
            : paymentReceiverId // ignore: cast_nullable_to_non_nullable
                  as String?,
        rejectionNote: freezed == rejectionNote
            ? _value.rejectionNote
            : rejectionNote // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        amountPaid: null == amountPaid
            ? _value.amountPaid
            : amountPaid // ignore: cast_nullable_to_non_nullable
                  as double,
        paidAt: freezed == paidAt
            ? _value.paidAt
            : paidAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        receivedByUserId: freezed == receivedByUserId
            ? _value.receivedByUserId
            : receivedByUserId // ignore: cast_nullable_to_non_nullable
                  as String?,
        studentName: freezed == studentName
            ? _value.studentName
            : studentName // ignore: cast_nullable_to_non_nullable
                  as String?,
        studentIdNumber: freezed == studentIdNumber
            ? _value.studentIdNumber
            : studentIdNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
        feeName: freezed == feeName
            ? _value.feeName
            : feeName // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StudentPaymentModelImpl implements _StudentPaymentModel {
  const _$StudentPaymentModelImpl({
    this.id,
    @JsonKey(name: 'student_id') required this.studentId,
    @JsonKey(name: 'fee_id') required this.feeId,
    @JsonKey(name: 'reference_number') required this.referenceNumber,
    @JsonKey(name: 'proof_photo_url') this.proofPhotoUrl,
    @JsonKey(name: 'payment_receiver_id') this.paymentReceiverId,
    @JsonKey(name: 'rejection_note') this.rejectionNote,
    this.status = 'Pending',
    @JsonKey(name: 'amount_paid') required this.amountPaid,
    @JsonKey(name: 'paid_at') this.paidAt,
    @JsonKey(name: 'updated_at') this.updatedAt,
    @JsonKey(name: 'received_by_user_id') this.receivedByUserId,
    @JsonKey(includeFromJson: true, includeToJson: false) this.studentName,
    @JsonKey(includeFromJson: true, includeToJson: false) this.studentIdNumber,
    @JsonKey(includeFromJson: true, includeToJson: false) this.feeName,
  });

  factory _$StudentPaymentModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$StudentPaymentModelImplFromJson(json);

  @override
  final String? id;
  @override
  @JsonKey(name: 'student_id')
  final String studentId;
  @override
  @JsonKey(name: 'fee_id')
  final String feeId;
  @override
  @JsonKey(name: 'reference_number')
  final String referenceNumber;
  @override
  @JsonKey(name: 'proof_photo_url')
  final String? proofPhotoUrl;
  @override
  @JsonKey(name: 'payment_receiver_id')
  final String? paymentReceiverId;
  @override
  @JsonKey(name: 'rejection_note')
  final String? rejectionNote;
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey(name: 'amount_paid')
  final double amountPaid;
  @override
  @JsonKey(name: 'paid_at')
  final DateTime? paidAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  @override
  @JsonKey(name: 'received_by_user_id')
  final String? receivedByUserId;
  // Virtual fields for display
  @override
  @JsonKey(includeFromJson: true, includeToJson: false)
  final String? studentName;
  @override
  @JsonKey(includeFromJson: true, includeToJson: false)
  final String? studentIdNumber;
  @override
  @JsonKey(includeFromJson: true, includeToJson: false)
  final String? feeName;

  @override
  String toString() {
    return 'StudentPaymentModel(id: $id, studentId: $studentId, feeId: $feeId, referenceNumber: $referenceNumber, proofPhotoUrl: $proofPhotoUrl, paymentReceiverId: $paymentReceiverId, rejectionNote: $rejectionNote, status: $status, amountPaid: $amountPaid, paidAt: $paidAt, updatedAt: $updatedAt, receivedByUserId: $receivedByUserId, studentName: $studentName, studentIdNumber: $studentIdNumber, feeName: $feeName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StudentPaymentModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.studentId, studentId) ||
                other.studentId == studentId) &&
            (identical(other.feeId, feeId) || other.feeId == feeId) &&
            (identical(other.referenceNumber, referenceNumber) ||
                other.referenceNumber == referenceNumber) &&
            (identical(other.proofPhotoUrl, proofPhotoUrl) ||
                other.proofPhotoUrl == proofPhotoUrl) &&
            (identical(other.paymentReceiverId, paymentReceiverId) ||
                other.paymentReceiverId == paymentReceiverId) &&
            (identical(other.rejectionNote, rejectionNote) ||
                other.rejectionNote == rejectionNote) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.amountPaid, amountPaid) ||
                other.amountPaid == amountPaid) &&
            (identical(other.paidAt, paidAt) || other.paidAt == paidAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.receivedByUserId, receivedByUserId) ||
                other.receivedByUserId == receivedByUserId) &&
            (identical(other.studentName, studentName) ||
                other.studentName == studentName) &&
            (identical(other.studentIdNumber, studentIdNumber) ||
                other.studentIdNumber == studentIdNumber) &&
            (identical(other.feeName, feeName) || other.feeName == feeName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    studentId,
    feeId,
    referenceNumber,
    proofPhotoUrl,
    paymentReceiverId,
    rejectionNote,
    status,
    amountPaid,
    paidAt,
    updatedAt,
    receivedByUserId,
    studentName,
    studentIdNumber,
    feeName,
  );

  /// Create a copy of StudentPaymentModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StudentPaymentModelImplCopyWith<_$StudentPaymentModelImpl> get copyWith =>
      __$$StudentPaymentModelImplCopyWithImpl<_$StudentPaymentModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$StudentPaymentModelImplToJson(this);
  }
}

abstract class _StudentPaymentModel implements StudentPaymentModel {
  const factory _StudentPaymentModel({
    final String? id,
    @JsonKey(name: 'student_id') required final String studentId,
    @JsonKey(name: 'fee_id') required final String feeId,
    @JsonKey(name: 'reference_number') required final String referenceNumber,
    @JsonKey(name: 'proof_photo_url') final String? proofPhotoUrl,
    @JsonKey(name: 'payment_receiver_id') final String? paymentReceiverId,
    @JsonKey(name: 'rejection_note') final String? rejectionNote,
    final String status,
    @JsonKey(name: 'amount_paid') required final double amountPaid,
    @JsonKey(name: 'paid_at') final DateTime? paidAt,
    @JsonKey(name: 'updated_at') final DateTime? updatedAt,
    @JsonKey(name: 'received_by_user_id') final String? receivedByUserId,
    @JsonKey(includeFromJson: true, includeToJson: false)
    final String? studentName,
    @JsonKey(includeFromJson: true, includeToJson: false)
    final String? studentIdNumber,
    @JsonKey(includeFromJson: true, includeToJson: false) final String? feeName,
  }) = _$StudentPaymentModelImpl;

  factory _StudentPaymentModel.fromJson(Map<String, dynamic> json) =
      _$StudentPaymentModelImpl.fromJson;

  @override
  String? get id;
  @override
  @JsonKey(name: 'student_id')
  String get studentId;
  @override
  @JsonKey(name: 'fee_id')
  String get feeId;
  @override
  @JsonKey(name: 'reference_number')
  String get referenceNumber;
  @override
  @JsonKey(name: 'proof_photo_url')
  String? get proofPhotoUrl;
  @override
  @JsonKey(name: 'payment_receiver_id')
  String? get paymentReceiverId;
  @override
  @JsonKey(name: 'rejection_note')
  String? get rejectionNote;
  @override
  String get status;
  @override
  @JsonKey(name: 'amount_paid')
  double get amountPaid;
  @override
  @JsonKey(name: 'paid_at')
  DateTime? get paidAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;
  @override
  @JsonKey(name: 'received_by_user_id')
  String? get receivedByUserId; // Virtual fields for display
  @override
  @JsonKey(includeFromJson: true, includeToJson: false)
  String? get studentName;
  @override
  @JsonKey(includeFromJson: true, includeToJson: false)
  String? get studentIdNumber;
  @override
  @JsonKey(includeFromJson: true, includeToJson: false)
  String? get feeName;

  /// Create a copy of StudentPaymentModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StudentPaymentModelImplCopyWith<_$StudentPaymentModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
