import 'package:freezed_annotation/freezed_annotation.dart';

part 'organization_model.g.dart';
part 'organization_model.freezed.dart';

@freezed
class OrganizationModel with _$OrganizationModel {
  const factory OrganizationModel({
    required String id,
    required String name,
    required String code,
    String? description,
    String? logoUrl,
    String? bannerUrl,
    @Default('active') String status,
    @Default('campus-based') String type,
    String? facultyProgram,
    String? adviserName,
    String? campusId,
    String? facultyId,
    String? programId,
    @Default(0) int memberCount,
    DateTime? createdAt,
  }) = _OrganizationModel;

  factory OrganizationModel.fromJson(Map<String, dynamic> json) => _$OrganizationModelFromJson(json);
}
