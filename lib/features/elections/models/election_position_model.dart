class ElectionPositionModel {
  final String id;
  final String electionId;
  final String name;
  final String? description;
  final int seatCount;
  final int? maxCandidateLimit;
  final bool isRequired;
  final bool allowAbstain;
  final String votingType; // single_choice, multiple_choice, rank_choice
  final int displayOrder;
  final Map<String, dynamic>? eligibilityRules;
  final DateTime? createdAt;

  const ElectionPositionModel({
    required this.id,
    required this.electionId,
    required this.name,
    this.description,
    this.seatCount = 1,
    this.maxCandidateLimit,
    this.isRequired = true,
    this.allowAbstain = true,
    this.votingType = 'single_choice',
    this.displayOrder = 0,
    this.eligibilityRules,
    this.createdAt,
  });

  factory ElectionPositionModel.fromJson(Map<String, dynamic> json) {
    return ElectionPositionModel(
      id: json['id'] as String,
      electionId: json['election_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      seatCount: json['seat_count'] as int? ?? 1,
      maxCandidateLimit: json['max_candidate_limit'] as int?,
      isRequired: json['is_required'] as bool? ?? true,
      allowAbstain: json['allow_abstain'] as bool? ?? true,
      votingType: json['voting_type'] as String? ?? 'single_choice',
      displayOrder: json['display_order'] as int? ?? 0,
      eligibilityRules: json['eligibility_rules'] != null
          ? Map<String, dynamic>.from(json['eligibility_rules'] as Map)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'election_id': electionId,
      'name': name,
      'description': description,
      'seat_count': seatCount,
      'max_candidate_limit': maxCandidateLimit,
      'is_required': isRequired,
      'allow_abstain': allowAbstain,
      'voting_type': votingType,
      'display_order': displayOrder,
      'eligibility_rules': eligibilityRules,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
