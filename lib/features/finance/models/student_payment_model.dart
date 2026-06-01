import 'package:freezed_annotation/freezed_annotation.dart';

part 'student_payment_model.freezed.dart';
part 'student_payment_model.g.dart';

@freezed
class StudentPaymentModel with _$StudentPaymentModel {
  const factory StudentPaymentModel({
    String? id,
    @JsonKey(name: 'student_id') required String studentId,
    @JsonKey(name: 'fee_id') required String feeId,
    @JsonKey(name: 'reference_number') required String referenceNumber,
    @JsonKey(name: 'proof_photo_url') String? proofPhotoUrl,
    @JsonKey(name: 'payment_receiver_id') String? paymentReceiverId,
    @JsonKey(name: 'rejection_note') String? rejectionNote,
    @Default('Pending') String status,
    @JsonKey(name: 'amount_paid') required double amountPaid,
    @JsonKey(name: 'paid_at') DateTime? paidAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @JsonKey(name: 'received_by_user_id') String? receivedByUserId,
    
    // Virtual fields for display
    @JsonKey(includeFromJson: true, includeToJson: false) String? studentName,
    @JsonKey(includeFromJson: true, includeToJson: false) String? studentIdNumber,
    @JsonKey(includeFromJson: true, includeToJson: false) String? feeName,
  }) = _StudentPaymentModel;

  factory StudentPaymentModel.fromJson(Map<String, dynamic> json) => _$StudentPaymentModelFromJson(json);
}
