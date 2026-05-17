import 'package:freezed_annotation/freezed_annotation.dart';

part 'program_model.freezed.dart';
part 'program_model.g.dart';

@freezed
class ProgramModel with _$ProgramModel {
  const factory ProgramModel({
    required String id,
    required String name,
    required String code,
    required String facultyId,
    String? programHeadId,
    String? programHeadName,
    @Default('active') String status,
    DateTime? createdAt,
  }) = _ProgramModel;

  factory ProgramModel.fromJson(Map<String, dynamic> json) => _$ProgramModelFromJson(json);
}
