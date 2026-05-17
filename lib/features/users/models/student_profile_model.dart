import 'package:freezed_annotation/freezed_annotation.dart';
import 'org_membership_model.dart';

part 'student_profile_model.freezed.dart';
part 'student_profile_model.g.dart';

@freezed
class StudentProfileModel with _$StudentProfileModel {
  const factory StudentProfileModel({
    required String userId,
    required String studentNumber,
    String? campusId,
    String? campusName,
    String? facultyId,
    String? facultyName,
    String? programId,
    String? programName,
    required int yearLevel,
    String? academicYear,
    @Default('pending') String status,
    @Default([]) List<OrgMembershipModel> memberships,
    DateTime? createdAt,
  }) = _StudentProfileModel;

  factory StudentProfileModel.fromJson(Map<String, dynamic> json) => _$StudentProfileModelFromJson(json);
}
