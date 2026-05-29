import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_receiver_model.freezed.dart';
part 'payment_receiver_model.g.dart';

@freezed
class PaymentReceiverModel with _$PaymentReceiverModel {
  const factory PaymentReceiverModel({
    String? id,
    @JsonKey(name: 'bank_type') required String bankType,
    @JsonKey(name: 'account_name') required String accountName,
    @JsonKey(name: 'account_number') required String accountNumber,
    @JsonKey(name: 'created_by_user_id') String? createdByUserId,
  }) = _PaymentReceiverModel;

  factory PaymentReceiverModel.fromJson(Map<String, dynamic> json) => _$PaymentReceiverModelFromJson(json);
}
