import 'package:freezed_annotation/freezed_annotation.dart';

part 'account_deletion_request.freezed.dart';
part 'account_deletion_request.g.dart';

@freezed
abstract class AccountDeletionRequest with _$AccountDeletionRequest {
  const factory AccountDeletionRequest({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String email,
    @JsonKey(name: 'student_id_number') required String studentIdNumber,
    @JsonKey(name: 'full_name') required String fullName,
    @JsonKey(name: 'acknowledged_clearance') required bool acknowledgedClearance,
    @JsonKey(name: 'acknowledged_data_loss') required bool acknowledgedDataLoss,
    @Default('pending') String status,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _AccountDeletionRequest;

  factory AccountDeletionRequest.fromJson(Map<String, dynamic> json) =>
      _$AccountDeletionRequestFromJson(json);
}
