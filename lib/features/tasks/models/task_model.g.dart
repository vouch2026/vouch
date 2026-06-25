// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TaskModel _$TaskModelFromJson(Map<String, dynamic> json) => _TaskModel(
  id: json['id'] as String?,
  userId: json['user_id'] as String?,
  title: json['title'] as String,
  description: json['description'] as String? ?? '',
  isCompleted: json['is_completed'] as bool? ?? false,
  dueDate: json['due_date'] == null
      ? null
      : DateTime.parse(json['due_date'] as String),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  syncStatus: json['syncStatus'] as String? ?? 'synced',
);

Map<String, dynamic> _$TaskModelToJson(_TaskModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'title': instance.title,
      'description': instance.description,
      'is_completed': instance.isCompleted,
      'due_date': instance.dueDate?.toIso8601String(),
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'syncStatus': instance.syncStatus,
    };
