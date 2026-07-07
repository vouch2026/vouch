import 'package:freezed_annotation/freezed_annotation.dart';

part 'faculty_model.freezed.dart';
part 'faculty_model.g.dart';

@freezed
abstract class FacultyModel with _$FacultyModel {
  const factory FacultyModel({
    required String id,
    required String name,
    required String code,
    @JsonKey(name: 'campus_id') required String campusId,
    @JsonKey(name: 'dean_id') String? deanId,
    String? deanName,
    @JsonKey(name: 'logo_url') String? logoUrl,
    @Default('active') String status,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _FacultyModel;

  factory FacultyModel.fromJson(Map<String, dynamic> json) => _$FacultyModelFromJson(json);
}
