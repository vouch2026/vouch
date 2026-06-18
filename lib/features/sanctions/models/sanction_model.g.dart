// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sanction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SanctionModel _$SanctionModelFromJson(Map<String, dynamic> json) =>
    _SanctionModel(
      id: json['id'] as String,
      studentId: json['student_id'] as String,
      scopeType: json['scope_type'] as String,
      scopeId: json['scope_id'] as String,
      academicTermId: json['academic_term_id'] as String,
      totalAbsences: (json['total_absences'] as num).toDouble(),
      requiredItem: json['required_item'] as String,
      status: json['status'] as String? ?? 'Pending Item',
      receivedByUserId: json['received_by_user_id'] as String?,
      receivedAt: json['received_at'] == null
          ? null
          : DateTime.parse(json['received_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      studentName: json['student_name'] as String?,
      receivedByName: json['received_by_name'] as String?,
    );

Map<String, dynamic> _$SanctionModelToJson(_SanctionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'student_id': instance.studentId,
      'scope_type': instance.scopeType,
      'scope_id': instance.scopeId,
      'academic_term_id': instance.academicTermId,
      'total_absences': instance.totalAbsences,
      'required_item': instance.requiredItem,
      'status': instance.status,
      'received_by_user_id': instance.receivedByUserId,
      'received_at': instance.receivedAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'student_name': instance.studentName,
      'received_by_name': instance.receivedByName,
    };
