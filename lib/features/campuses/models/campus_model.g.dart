// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'campus_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CampusModel _$CampusModelFromJson(Map<String, dynamic> json) => _CampusModel(
  id: json['id'] as String,
  name: json['name'] as String,
  location: json['location'] as String,
  description: json['description'] as String?,
  logoUrl: json['logo_url'] as String?,
  status: json['status'] as String? ?? 'active',
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$CampusModelToJson(_CampusModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'location': instance.location,
      'description': instance.description,
      'logo_url': instance.logoUrl,
      'status': instance.status,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
