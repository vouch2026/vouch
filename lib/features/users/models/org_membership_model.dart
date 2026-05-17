import 'package:freezed_annotation/freezed_annotation.dart';

part 'org_membership_model.freezed.dart';
part 'org_membership_model.g.dart';

@freezed
class OrgMembershipModel with _$OrgMembershipModel {
  const factory OrgMembershipModel({
    required String organizationId,
    required String organizationName,
    required String role,
    DateTime? joinedAt,
    @Default(true) bool isCurrent,
    String? positionTitle,
  }) = _OrgMembershipModel;

  factory OrgMembershipModel.fromJson(Map<String, dynamic> json) => _$OrgMembershipModelFromJson(json);
}
