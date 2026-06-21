import 'package:freezed_annotation/freezed_annotation.dart';

part 'excuse_request_model.freezed.dart';
part 'excuse_request_model.g.dart';

@freezed
abstract class ExcuseRequestModel with _$ExcuseRequestModel {
  const factory ExcuseRequestModel({
    required String id,
    @JsonKey(name: 'student_id') required String studentId,
    @JsonKey(name: 'event_id') required String eventId,
    required String reason,
    @JsonKey(name: 'supporting_document_url') required String supportingDocumentUrl,
    @Default('Pending') String status, // 'Pending', 'Approved', 'Rejected'
    @JsonKey(name: 'rejection_reason') String? rejectionReason,
    @JsonKey(name: 'scope_type') required String scopeType,
    @JsonKey(name: 'scope_id') required String scopeId,
    @JsonKey(name: 'academic_term_id') required String academicTermId,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @JsonKey(name: 'reviewed_by_user_id') String? reviewedByUserId,
    @JsonKey(name: 'reviewed_at') DateTime? reviewedAt,
    
    // Join fields
    @JsonKey(name: 'student_name') String? studentName,
    @JsonKey(name: 'student_id_number') String? studentIdNumber,
    @JsonKey(name: 'event_name') String? eventName,
    @JsonKey(name: 'reviewed_by_name') String? reviewedByName,
  }) = _ExcuseRequestModel;

  factory ExcuseRequestModel.fromJson(Map<String, dynamic> json) => _$ExcuseRequestModelFromJson(json);
}
