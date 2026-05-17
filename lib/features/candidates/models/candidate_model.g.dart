// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'candidate_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CandidateModelImpl _$$CandidateModelImplFromJson(Map<String, dynamic> json) =>
    _$CandidateModelImpl(
      id: json['id'] as String,
      electionId: json['electionId'] as String,
      userId: json['userId'] as String,
      fullName: json['fullName'] as String,
      position: json['position'] as String,
      partyList: json['partyList'] as String?,
      platform: json['platform'] as String?,
      status: json['status'] as String? ?? 'pending',
      votes: (json['votes'] as num?)?.toInt() ?? 0,
      avatarUrl: json['avatarUrl'] as String?,
      organizationName: json['organizationName'] as String?,
    );

Map<String, dynamic> _$$CandidateModelImplToJson(
  _$CandidateModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'electionId': instance.electionId,
  'userId': instance.userId,
  'fullName': instance.fullName,
  'position': instance.position,
  'partyList': instance.partyList,
  'platform': instance.platform,
  'status': instance.status,
  'votes': instance.votes,
  'avatarUrl': instance.avatarUrl,
  'organizationName': instance.organizationName,
};
