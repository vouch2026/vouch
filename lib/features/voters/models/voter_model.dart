import 'package:freezed_annotation/freezed_annotation.dart';

part 'voter_model.freezed.dart';
part 'voter_model.g.dart';

@freezed
class VoterModel with _$VoterModel {
  const factory VoterModel({
    required String id,
    required String userId,
    required String electionId,
    required String studentNumber,
    required String fullName,
    String? campusName,
    String? facultyName,
    String? programName,
    @Default('eligible') String status, // eligible, voted, not_voted, restricted
    DateTime? votedAt,
  }) = _VoterModel;

  factory VoterModel.fromJson(Map<String, dynamic> json) => _$VoterModelFromJson(json);
}
