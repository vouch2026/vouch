// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'excuse_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ExcuseRequestModel _$ExcuseRequestModelFromJson(Map<String, dynamic> json) =>
    _ExcuseRequestModel(
      id: json['id'] as String,
      studentId: json['student_id'] as String,
      eventId: json['event_id'] as String,
      reason: json['reason'] as String,
      supportingDocumentUrl: json['supporting_document_url'] as String,
      status: json['status'] as String? ?? 'Pending',
      rejectionReason: json['rejection_reason'] as String?,
      scopeType: json['scope_type'] as String,
      scopeId: json['scope_id'] as String,
      academicTermId: json['academic_term_id'] as String,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      reviewedByUserId: json['reviewed_by_user_id'] as String?,
      reviewedAt: json['reviewed_at'] == null
          ? null
          : DateTime.parse(json['reviewed_at'] as String),
      studentName: json['student_name'] as String?,
      studentIdNumber: json['student_id_number'] as String?,
      eventName: json['event_name'] as String?,
      reviewedByName: json['reviewed_by_name'] as String?,
    );

Map<String, dynamic> _$ExcuseRequestModelToJson(_ExcuseRequestModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'student_id': instance.studentId,
      'event_id': instance.eventId,
      'reason': instance.reason,
      'supporting_document_url': instance.supportingDocumentUrl,
      'status': instance.status,
      'rejection_reason': instance.rejectionReason,
      'scope_type': instance.scopeType,
      'scope_id': instance.scopeId,
      'academic_term_id': instance.academicTermId,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'reviewed_by_user_id': instance.reviewedByUserId,
      'reviewed_at': instance.reviewedAt?.toIso8601String(),
      'student_name': instance.studentName,
      'student_id_number': instance.studentIdNumber,
      'event_name': instance.eventName,
      'reviewed_by_name': instance.reviewedByName,
    };
