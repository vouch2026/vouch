// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'instructor_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InstructorProfileModelImpl _$$InstructorProfileModelImplFromJson(
  Map<String, dynamic> json,
) => _$InstructorProfileModelImpl(
  userId: json['userId'] as String,
  instructorId: json['instructorId'] as String,
  campusId: json['campusId'] as String?,
  campusName: json['campusName'] as String?,
  facultyId: json['facultyId'] as String?,
  facultyName: json['facultyName'] as String?,
  position: json['position'] as String? ?? 'instructor',
  assignedProgramId: json['assignedProgramId'] as String?,
  assignedProgramName: json['assignedProgramName'] as String?,
  status: json['status'] as String? ?? 'active',
  memberships:
      (json['memberships'] as List<dynamic>?)
          ?.map((e) => OrgMembershipModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$InstructorProfileModelImplToJson(
  _$InstructorProfileModelImpl instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'instructorId': instance.instructorId,
  'campusId': instance.campusId,
  'campusName': instance.campusName,
  'facultyId': instance.facultyId,
  'facultyName': instance.facultyName,
  'position': instance.position,
  'assignedProgramId': instance.assignedProgramId,
  'assignedProgramName': instance.assignedProgramName,
  'status': instance.status,
  'memberships': instance.memberships,
  'createdAt': instance.createdAt?.toIso8601String(),
};
