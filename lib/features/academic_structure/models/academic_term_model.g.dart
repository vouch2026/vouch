// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'academic_term_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AcademicTermModel _$AcademicTermModelFromJson(Map<String, dynamic> json) =>
    _AcademicTermModel(
      id: json['id'] as String,
      academicYear: json['academic_year'] as String,
      semester: json['semester'] as String,
      isActive: json['is_active'] as bool? ?? false,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$AcademicTermModelToJson(_AcademicTermModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'academic_year': instance.academicYear,
      'semester': instance.semester,
      'is_active': instance.isActive,
      'created_at': instance.createdAt?.toIso8601String(),
    };
