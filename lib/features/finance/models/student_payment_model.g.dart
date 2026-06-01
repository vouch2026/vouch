// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_payment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StudentPaymentModelImpl _$$StudentPaymentModelImplFromJson(
  Map<String, dynamic> json,
) => _$StudentPaymentModelImpl(
  id: json['id'] as String?,
  studentId: json['student_id'] as String,
  feeId: json['fee_id'] as String,
  referenceNumber: json['reference_number'] as String,
  proofPhotoUrl: json['proof_photo_url'] as String?,
  paymentReceiverId: json['payment_receiver_id'] as String?,
  rejectionNote: json['rejection_note'] as String?,
  status: json['status'] as String? ?? 'Pending',
  amountPaid: (json['amount_paid'] as num).toDouble(),
  paidAt: json['paid_at'] == null
      ? null
      : DateTime.parse(json['paid_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  receivedByUserId: json['received_by_user_id'] as String?,
  studentName: json['studentName'] as String?,
  studentIdNumber: json['studentIdNumber'] as String?,
  feeName: json['feeName'] as String?,
);

Map<String, dynamic> _$$StudentPaymentModelImplToJson(
  _$StudentPaymentModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'student_id': instance.studentId,
  'fee_id': instance.feeId,
  'reference_number': instance.referenceNumber,
  'proof_photo_url': instance.proofPhotoUrl,
  'payment_receiver_id': instance.paymentReceiverId,
  'rejection_note': instance.rejectionNote,
  'status': instance.status,
  'amount_paid': instance.amountPaid,
  'paid_at': instance.paidAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
  'received_by_user_id': instance.receivedByUserId,
};
