import 'package:freezed_annotation/freezed_annotation.dart';

part 'candidate_model.freezed.dart';
part 'candidate_model.g.dart';

@freezed
abstract class CandidateModel with _$CandidateModel {
  const factory CandidateModel({
    required String id,
    required String electionId,
    required String userId,
    required String fullName,
    required String position,
    String? partyList,
    String? platform,
    @Default('pending') String status, // pending, approved, rejected, withdrawn, disqualified
    @Default(0) int votes,
    String? avatarUrl,
    String? organizationName,
  }) = _CandidateModel;

  factory CandidateModel.fromJson(Map<String, dynamic> json) => _$CandidateModelFromJson(json);
}
