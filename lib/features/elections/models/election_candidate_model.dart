class ElectionCandidateModel {
  final String id;
  final String electionId;
  final String positionId;
  final String? positionName;
  final String? applicationId;
  final String studentId;
  final String displayName;
  final int ballotOrder;
  final String? photoUrl;
  final String status;
  final String? platformStatement;
  final DateTime? createdAt;

  const ElectionCandidateModel({
    required this.id,
    required this.electionId,
    required this.positionId,
    this.positionName,
    this.applicationId,
    required this.studentId,
    required this.displayName,
    this.ballotOrder = 0,
    this.photoUrl,
    this.status = 'ACTIVE',
    this.platformStatement,
    this.createdAt,
  });

  factory ElectionCandidateModel.fromJson(Map<String, dynamic> json) {
    return ElectionCandidateModel(
      id: json['id'] as String,
      electionId: json['election_id'] as String,
      positionId: json['position_id'] as String,
      positionName: json['position_name'] as String?,
      applicationId: json['application_id'] as String?,
      studentId: json['student_id'] as String,
      displayName: json['display_name'] as String? ?? 'Candidate',
      ballotOrder: json['ballot_order'] as int? ?? 0,
      photoUrl: json['photo_url'] as String?,
      status: json['status'] as String? ?? 'ACTIVE',
      platformStatement: json['platform_statement'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'election_id': electionId,
      'position_id': positionId,
      'position_name': positionName,
      'application_id': applicationId,
      'student_id': studentId,
      'display_name': displayName,
      'ballot_order': ballotOrder,
      'photo_url': photoUrl,
      'status': status,
      'platform_statement': platformStatement,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
