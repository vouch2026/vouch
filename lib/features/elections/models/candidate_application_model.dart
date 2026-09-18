class CandidateApplicationModel {
  final String id;
  final String electionId;
  final String positionId;
  final String studentId;
  final String? studentName;
  final String? positionName;
  final String? platformStatement;
  final List<String> documentUrls;
  final String status; // PENDING, UNDER_REVIEW, APPROVED, REJECTED, RETURNED_FOR_CORRECTION
  final String? reviewNotes;
  final String? rejectionReason;
  final DateTime submittedAt;
  final String? reviewedBy;
  final DateTime? reviewedAt;

  const CandidateApplicationModel({
    required this.id,
    required this.electionId,
    required this.positionId,
    required this.studentId,
    this.studentName,
    this.positionName,
    this.platformStatement,
    this.documentUrls = const [],
    this.status = 'PENDING',
    this.reviewNotes,
    this.rejectionReason,
    required this.submittedAt,
    this.reviewedBy,
    this.reviewedAt,
  });

  factory CandidateApplicationModel.fromJson(Map<String, dynamic> json) {
    return CandidateApplicationModel(
      id: json['id'] as String,
      electionId: json['election_id'] as String,
      positionId: json['position_id'] as String,
      studentId: json['student_id'] as String,
      studentName: json['student_name'] as String?,
      positionName: json['position_name'] as String?,
      platformStatement: json['platform_statement'] as String?,
      documentUrls: json['document_urls'] != null
          ? List<String>.from(json['document_urls'] as List)
          : const [],
      status: json['status'] as String? ?? 'PENDING',
      reviewNotes: json['review_notes'] as String?,
      rejectionReason: json['rejection_reason'] as String?,
      submittedAt: json['submitted_at'] != null
          ? DateTime.parse(json['submitted_at'] as String)
          : DateTime.now(),
      reviewedBy: json['reviewed_by'] as String?,
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'election_id': electionId,
      'position_id': positionId,
      'student_id': studentId,
      'student_name': studentName,
      'position_name': positionName,
      'platform_statement': platformStatement,
      'document_urls': documentUrls,
      'status': status,
      'review_notes': reviewNotes,
      'rejection_reason': rejectionReason,
      'submitted_at': submittedAt.toIso8601String(),
      'reviewed_by': reviewedBy,
      'reviewed_at': reviewedAt?.toIso8601String(),
    };
  }
}
