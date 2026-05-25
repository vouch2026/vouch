import 'package:freezed_annotation/freezed_annotation.dart';

part 'academic_term_model.freezed.dart';
part 'academic_term_model.g.dart';

@freezed
class AcademicTermModel with _$AcademicTermModel {
  const factory AcademicTermModel({
    required String id,
    @JsonKey(name: 'academic_year') required String academicYear,
    required String semester,
    @JsonKey(name: 'is_active') @Default(false) bool isActive,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _AcademicTermModel;

  factory AcademicTermModel.fromJson(Map<String, dynamic> json) => _$AcademicTermModelFromJson(json);
}
