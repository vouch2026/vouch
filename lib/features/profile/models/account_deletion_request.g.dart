// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_deletion_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AccountDeletionRequest _$AccountDeletionRequestFromJson(
  Map<String, dynamic> json,
) => _AccountDeletionRequest(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  email: json['email'] as String,
  studentIdNumber: json['student_id_number'] as String,
  fullName: json['full_name'] as String,
  acknowledgedClearance: json['acknowledged_clearance'] as bool,
  acknowledgedDataLoss: json['acknowledged_data_loss'] as bool,
  status: json['status'] as String? ?? 'pending',
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$AccountDeletionRequestToJson(
  _AccountDeletionRequest instance,
) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'email': instance.email,
  'student_id_number': instance.studentIdNumber,
  'full_name': instance.fullName,
  'acknowledged_clearance': instance.acknowledgedClearance,
  'acknowledged_data_loss': instance.acknowledgedDataLoss,
  'status': instance.status,
  'created_at': instance.createdAt?.toIso8601String(),
};
