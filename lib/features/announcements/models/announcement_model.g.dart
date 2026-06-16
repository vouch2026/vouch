// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'announcement_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AnnouncementModel _$AnnouncementModelFromJson(Map<String, dynamic> json) =>
    _AnnouncementModel(
      id: json['id'] as String?,
      title: json['title'] as String,
      content: json['content'] as String,
      type: json['type'] as String? ?? 'General',
      linkUrls: (json['link_urls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      imageUrl: json['image_url'] as String?,
      scopeType: json['scope_type'] as String,
      scopeId: json['scope_id'] as String,
      academicTermId: json['academic_term_id'] as String,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      createdByUserId: json['created_by_user_id'] as String?,
      authorName: json['authorName'] as String?,
    );

Map<String, dynamic> _$AnnouncementModelToJson(_AnnouncementModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'type': instance.type,
      'link_urls': instance.linkUrls,
      'image_url': instance.imageUrl,
      'scope_type': instance.scopeType,
      'scope_id': instance.scopeId,
      'academic_term_id': instance.academicTermId,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'created_by_user_id': instance.createdByUserId,
    };
