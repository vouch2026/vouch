import 'package:freezed_annotation/freezed_annotation.dart';

part 'election_model.freezed.dart';
part 'election_model.g.dart';

@freezed
abstract class ElectionModel with _$ElectionModel {
  const factory ElectionModel({
    required String id,
    required String name,
    required String organizationId,
    required String type, // Organization, SSC, Department, COMSELEC
    required DateTime startTime,
    required DateTime endTime,
    @Default('draft') String status, // draft, upcoming, ongoing, completed, archived, cancelled
    required String createdBy,
    DateTime? createdAt,
    int? candidateCount,
    int? votesCast,
  }) = _ElectionModel;

  factory ElectionModel.fromJson(Map<String, dynamic> json) => _$ElectionModelFromJson(json);
}
