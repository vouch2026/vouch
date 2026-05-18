import 'package:freezed_annotation/freezed_annotation.dart';

part 'academic_structure_item.freezed.dart';

@freezed
class AcademicStructureItem with _$AcademicStructureItem {
  const factory AcademicStructureItem({
    required String campusName,
    required String facultyName,
    required String programName,
    required String programId,
    required String facultyId,
    required String campusId,
    String? programHeadName,
    @Default(0) int studentCount,
    @Default(0) int orgCount,
    @Default('Active') String status,
  }) = _AcademicStructureItem;
}
