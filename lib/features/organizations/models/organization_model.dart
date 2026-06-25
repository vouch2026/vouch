import 'package:freezed_annotation/freezed_annotation.dart';

part 'organization_model.g.dart';
part 'organization_model.freezed.dart';

@freezed
abstract class OrganizationModel with _$OrganizationModel {
  const factory OrganizationModel({
    required String id,
    required String name,
    required String code,
    String? description,
    @JsonKey(name: 'logo_url') String? logoUrl,
    @JsonKey(name: 'banner_url') String? bannerUrl,
    @Default('active') String status,
    @Default('campus-based') String type,
    String? facultyProgram,
    String? adviserName,
    @JsonKey(name: 'campus_id') String? campusId,
    @JsonKey(name: 'faculty_id') String? facultyId,
    @JsonKey(name: 'program_id') String? programId,
    @Default(0) int memberCount,
    @JsonKey(name: 'requires_adviser_signature') @Default(false) bool requiresAdviserSignature,
    @JsonKey(name: 'requires_faculty_dean_signature') @Default(false) bool requiresFacultyDeanSignature,
    @JsonKey(name: 'allow_member_card_printing') @Default(true) bool allowMemberCardPrinting,
    @JsonKey(name: 'is_clearance_active') @Default(false) bool isClearanceActive,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _OrganizationModel;

  factory OrganizationModel.fromJson(Map<String, dynamic> json) => _$OrganizationModelFromJson(json);
}
