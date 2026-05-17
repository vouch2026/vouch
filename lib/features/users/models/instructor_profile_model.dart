import 'package:freezed_annotation/freezed_annotation.dart';
import 'org_membership_model.dart';

part 'instructor_profile_model.freezed.dart';
part 'instructor_profile_model.g.dart';

@freezed
class InstructorProfileModel with _$InstructorProfileModel {
  const factory InstructorProfileModel({
    required String userId,
    required String instructorId,
    String? campusId,
    String? campusName,
    String? facultyId,
    String? facultyName,
    @Default('instructor') String position,
    String? assignedProgramId,
    String? assignedProgramName,
    @Default('active') String status,
    @Default([]) List<OrgMembershipModel> memberships,
    DateTime? createdAt,
  }) = _InstructorProfileModel;

  factory InstructorProfileModel.fromJson(Map<String, dynamic> json) => _$InstructorProfileModelFromJson(json);
}
