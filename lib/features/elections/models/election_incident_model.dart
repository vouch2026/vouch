class ElectionIncidentModel {
  final String id;
  final String electionId;
  final String incidentReference;
  final String category; // Candidate application dispute, Voter eligibility concern, Station issue, Duplicate tx, Discrepancy
  final String description;
  final String reportedBy;
  final String? reporterName;
  final String? assignedReviewerId;
  final String? reviewerName;
  final String status; // OPEN, UNDER_REVIEW, RESOLVED, DISMISSED
  final String? resolutionNotes;
  final DateTime reportedAt;
  final DateTime? resolvedAt;

  const ElectionIncidentModel({
    required this.id,
    required this.electionId,
    required this.incidentReference,
    required this.category,
    required this.description,
    required this.reportedBy,
    this.reporterName,
    this.assignedReviewerId,
    this.reviewerName,
    this.status = 'OPEN',
    this.resolutionNotes,
    required this.reportedAt,
    this.resolvedAt,
  });

  factory ElectionIncidentModel.fromJson(Map<String, dynamic> json) {
    return ElectionIncidentModel(
      id: json['id'] as String,
      electionId: json['election_id'] as String,
      incidentReference: json['incident_reference'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      reportedBy: json['reported_by'] as String,
      reporterName: json['reporter_name'] as String?,
      assignedReviewerId: json['assigned_reviewer_id'] as String?,
      reviewerName: json['reviewer_name'] as String?,
      status: json['status'] as String? ?? 'OPEN',
      resolutionNotes: json['resolution_notes'] as String?,
      reportedAt: json['reported_at'] != null
          ? DateTime.parse(json['reported_at'] as String)
          : DateTime.now(),
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'election_id': electionId,
      'incident_reference': incidentReference,
      'category': category,
      'description': description,
      'reported_by': reportedBy,
      'reporter_name': reporterName,
      'assigned_reviewer_id': assignedReviewerId,
      'reviewer_name': reviewerName,
      'status': status,
      'resolution_notes': resolutionNotes,
      'reported_at': reportedAt.toIso8601String(),
      'resolved_at': resolvedAt?.toIso8601String(),
    };
  }
}
