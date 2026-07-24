import 'package:freezed_annotation/freezed_annotation.dart';

part 'program_model.freezed.dart';
part 'program_model.g.dart';

@freezed
abstract class ProgramModel with _$ProgramModel {
  const factory ProgramModel({
    required String id,
    required String name,
    required String code,
    @JsonKey(name: 'faculty_id') required String facultyId,
    @JsonKey(name: 'program_head_id') String? programHeadId,
    String? programHeadName,
    @JsonKey(name: 'logo_url') String? logoUrl,
    @JsonKey(name: 'banner_url') String? bannerUrl,
    @Default('active') String status,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _ProgramModel;

  factory ProgramModel.fromJson(Map<String, dynamic> json) => _$ProgramModelFromJson(json);
}
