// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_receiver_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PaymentReceiverModel _$PaymentReceiverModelFromJson(
  Map<String, dynamic> json,
) => _PaymentReceiverModel(
  id: json['id'] as String?,
  bankType: json['bank_type'] as String,
  accountName: json['account_name'] as String,
  accountNumber: json['account_number'] as String,
  createdByUserId: json['created_by_user_id'] as String?,
  scopeType: json['scope_type'] as String?,
  scopeId: json['scope_id'] as String?,
);

Map<String, dynamic> _$PaymentReceiverModelToJson(
  _PaymentReceiverModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'bank_type': instance.bankType,
  'account_name': instance.accountName,
  'account_number': instance.accountNumber,
  'created_by_user_id': instance.createdByUserId,
  'scope_type': instance.scopeType,
  'scope_id': instance.scopeId,
};
