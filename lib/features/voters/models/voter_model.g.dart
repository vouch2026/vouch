// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voter_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VoterModel _$VoterModelFromJson(Map<String, dynamic> json) => _VoterModel(
  id: json['id'] as String,
  userId: json['userId'] as String,
  electionId: json['electionId'] as String,
  studentNumber: json['studentNumber'] as String,
  fullName: json['fullName'] as String,
  campusName: json['campusName'] as String?,
  facultyName: json['facultyName'] as String?,
  programName: json['programName'] as String?,
  status: json['status'] as String? ?? 'eligible',
  votedAt: json['votedAt'] == null
      ? null
      : DateTime.parse(json['votedAt'] as String),
);

Map<String, dynamic> _$VoterModelToJson(_VoterModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'electionId': instance.electionId,
      'studentNumber': instance.studentNumber,
      'fullName': instance.fullName,
      'campusName': instance.campusName,
      'facultyName': instance.facultyName,
      'programName': instance.programName,
      'status': instance.status,
      'votedAt': instance.votedAt?.toIso8601String(),
    };
