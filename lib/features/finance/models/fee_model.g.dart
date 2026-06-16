// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fee_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FeeModel _$FeeModelFromJson(Map<String, dynamic> json) => _FeeModel(
  id: json['id'] as String?,
  name: json['name'] as String,
  description: json['description'] as String?,
  amount: (json['amount'] as num).toDouble(),
  scopeType: json['scope_type'] as String,
  scopeId: json['scope_id'] as String,
  isMandatory: json['is_mandatory'] as bool? ?? true,
  dueDate: DateTime.parse(json['due_date'] as String),
  academicTermId: json['academic_term_id'] as String,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  createdByUserId: json['created_by_user_id'] as String?,
);

Map<String, dynamic> _$FeeModelToJson(_FeeModel instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'amount': instance.amount,
  'scope_type': instance.scopeType,
  'scope_id': instance.scopeId,
  'is_mandatory': instance.isMandatory,
  'due_date': instance.dueDate.toIso8601String(),
  'academic_term_id': instance.academicTermId,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
  'created_by_user_id': instance.createdByUserId,
};
