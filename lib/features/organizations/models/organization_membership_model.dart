import 'package:freezed_annotation/freezed_annotation.dart';
import '../../auth/models/user_model.dart';
import '../../academic_structure/models/academic_term_model.dart';

part 'organization_membership_model.freezed.dart';
part 'organization_membership_model.g.dart';

@freezed
abstract class OrganizationMembershipModel with _$OrganizationMembershipModel {
  const factory OrganizationMembershipModel({
    required String id,
    @JsonKey(name: 'organization_id') required String organizationId,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'role_id') String? roleId,
    @JsonKey(name: 'academic_term_id') String? academicTermId,
    @Default('active') String status,
    @JsonKey(name: 'assigned_at') DateTime? assignedAt,
    @JsonKey(name: 'expired_at') DateTime? expiredAt,
    @JsonKey(name: 'joined_at') DateTime? joinedAt,
    @JsonKey(name: 'auto_sign_clearance') @Default(false) bool autoSignClearance,
    
    // Join fields for UI
    UserModel? user,
    AcademicTermModel? term,
    @JsonKey(name: 'role_name') String? roleName,
    @JsonKey(name: 'hierarchy_level') int? hierarchyLevel,
    @Default([]) List<String> permissions,
  }) = _OrganizationMembershipModel;

  factory OrganizationMembershipModel.fromJson(Map<String, dynamic> json) => _$OrganizationMembershipModelFromJson(json);
}
