import 'package:freezed_annotation/freezed_annotation.dart';

part 'attendance_model.freezed.dart';
part 'attendance_model.g.dart';

@freezed
class AttendanceModel with _$AttendanceModel {
  const factory AttendanceModel({
    String? id,
    @JsonKey(name: 'student_id') required String studentId,
    @JsonKey(name: 'event_id') required String eventId,
    @JsonKey(name: 'actual_time_in') DateTime? actualTimeIn,
    @JsonKey(name: 'actual_time_out') DateTime? actualTimeOut,
    @Default('Pending') String status,
    @JsonKey(name: 'scanned_by_user_id') String? scannedByUserId,
    @JsonKey(name: 'override_reason') String? overrideReason,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _AttendanceModel;

  factory AttendanceModel.fromJson(Map<String, dynamic> json) => _$AttendanceModelFromJson(json);
}
