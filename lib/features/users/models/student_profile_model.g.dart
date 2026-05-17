// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StudentProfileModelImpl _$$StudentProfileModelImplFromJson(
  Map<String, dynamic> json,
) => _$StudentProfileModelImpl(
  userId: json['userId'] as String,
  studentNumber: json['studentNumber'] as String,
  campusId: json['campusId'] as String?,
  campusName: json['campusName'] as String?,
  facultyId: json['facultyId'] as String?,
  facultyName: json['facultyName'] as String?,
  programId: json['programId'] as String?,
  programName: json['programName'] as String?,
  yearLevel: (json['yearLevel'] as num).toInt(),
  academicYear: json['academicYear'] as String?,
  status: json['status'] as String? ?? 'pending',
  memberships:
      (json['memberships'] as List<dynamic>?)
          ?.map((e) => OrgMembershipModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$StudentProfileModelImplToJson(
  _$StudentProfileModelImpl instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'studentNumber': instance.studentNumber,
  'campusId': instance.campusId,
  'campusName': instance.campusName,
  'facultyId': instance.facultyId,
  'facultyName': instance.facultyName,
  'programId': instance.programId,
  'programName': instance.programName,
  'yearLevel': instance.yearLevel,
  'academicYear': instance.academicYear,
  'status': instance.status,
  'memberships': instance.memberships,
  'createdAt': instance.createdAt?.toIso8601String(),
};
