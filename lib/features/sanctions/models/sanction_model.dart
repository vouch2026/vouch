import 'package:freezed_annotation/freezed_annotation.dart';

part 'sanction_model.freezed.dart';
part 'sanction_model.g.dart';

@freezed
abstract class SanctionModel with _$SanctionModel {
  const factory SanctionModel({
    required String id,
    @JsonKey(name: 'student_id') required String studentId,
    @JsonKey(name: 'scope_type') required String scopeType,
    @JsonKey(name: 'scope_id') required String scopeId,
    @JsonKey(name: 'academic_term_id') required String academicTermId,
    @JsonKey(name: 'total_absences') required int totalAbsences,
    @JsonKey(name: 'required_item') required String requiredItem,
    @Default('Pending Item') String status,
    @JsonKey(name: 'received_by_user_id') String? receivedByUserId,
    @JsonKey(name: 'received_at') DateTime? receivedAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    
    // Join fields
    @JsonKey(name: 'student_name') String? studentName,
    @JsonKey(name: 'received_by_name') String? receivedByName,
  }) = _SanctionModel;

  factory SanctionModel.fromJson(Map<String, dynamic> json) => _$SanctionModelFromJson(json);
}
