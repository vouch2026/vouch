// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'campus_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CampusModelImpl _$$CampusModelImplFromJson(Map<String, dynamic> json) =>
    _$CampusModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      location: json['location'] as String,
      description: json['description'] as String?,
      logoUrl: json['logoUrl'] as String?,
      status: json['status'] as String? ?? 'active',
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$CampusModelImplToJson(_$CampusModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'location': instance.location,
      'description': instance.description,
      'logoUrl': instance.logoUrl,
      'status': instance.status,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
