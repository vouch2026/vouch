import 'package:freezed_annotation/freezed_annotation.dart';

part 'fee_model.freezed.dart';
part 'fee_model.g.dart';

@freezed
abstract class FeeModel with _$FeeModel {
  const factory FeeModel({
    String? id,
    required String name,
    String? description,
    required double amount,
    @JsonKey(name: 'scope_type') required String scopeType,
    @JsonKey(name: 'scope_id') required String scopeId,
    @JsonKey(name: 'is_mandatory') @Default(true) bool isMandatory,
    @JsonKey(name: 'due_date') required DateTime dueDate,
    @JsonKey(name: 'academic_term_id') required String academicTermId,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @JsonKey(name: 'created_by_user_id') String? createdByUserId,
  }) = _FeeModel;

  factory FeeModel.fromJson(Map<String, dynamic> json) => _$FeeModelFromJson(json);
}
