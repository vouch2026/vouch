// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'election_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ElectionModelImpl _$$ElectionModelImplFromJson(Map<String, dynamic> json) =>
    _$ElectionModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      organizationId: json['organizationId'] as String,
      type: json['type'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      status: json['status'] as String? ?? 'draft',
      createdBy: json['createdBy'] as String,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      candidateCount: (json['candidateCount'] as num?)?.toInt(),
      votesCast: (json['votesCast'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$ElectionModelImplToJson(_$ElectionModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'organizationId': instance.organizationId,
      'type': instance.type,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime.toIso8601String(),
      'status': instance.status,
      'createdBy': instance.createdBy,
      'createdAt': instance.createdAt?.toIso8601String(),
      'candidateCount': instance.candidateCount,
      'votesCast': instance.votesCast,
    };
