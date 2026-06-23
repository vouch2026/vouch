import 'package:freezed_annotation/freezed_annotation.dart';

part 'schedule_model.freezed.dart';
part 'schedule_model.g.dart';

@freezed
abstract class ScheduleModel with _$ScheduleModel {
  const factory ScheduleModel({
    String? id,
    @JsonKey(name: 'user_id') String? userId,
    @JsonKey(name: 'subject_code') required String subjectCode,
    @JsonKey(name: 'subject_name') required String subjectName,
    @Default('') String teacher,
    @JsonKey(name: 'start_time') required String startTime,
    @JsonKey(name: 'end_time') required String endTime,
    required List<String> days,
    @Default('') String room,
    @JsonKey(name: 'academic_term_id') required String academicTermId,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    
    // Local-only sync fields: 'synced', 'to_create', 'to_update', 'to_delete'
    @Default('synced') String syncStatus,
  }) = _ScheduleModel;

  factory ScheduleModel.fromJson(Map<String, dynamic> json) => _$ScheduleModelFromJson(json);
}
