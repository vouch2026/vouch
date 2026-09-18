class CommissionAssignmentModel {
  final String id;
  final String? electionId;
  final String userId;
  final String? userName;
  final String? userEmail;
  final String role; // chairman, co_chairman, campus_commissioner, faculty_commissioner, program_commissioner
  final String? campusId;
  final String? campusName;
  final String? facultyId;
  final String? facultyName;
  final String? programId;
  final String? programName;
  final List<String> permissions;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final String status;

  const CommissionAssignmentModel({
    required this.id,
    this.electionId,
    required this.userId,
    this.userName,
    this.userEmail,
    required this.role,
    this.campusId,
    this.campusName,
    this.facultyId,
    this.facultyName,
    this.programId,
    this.programName,
    this.permissions = const [],
    this.startsAt,
    this.endsAt,
    this.status = 'active',
  });

  factory CommissionAssignmentModel.fromJson(Map<String, dynamic> json) {
    return CommissionAssignmentModel(
      id: json['id'] as String,
      electionId: json['election_id'] as String?,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String?,
      userEmail: json['user_email'] as String?,
      role: json['role'] as String,
      campusId: json['campus_id'] as String?,
      campusName: json['campus_name'] as String?,
      facultyId: json['faculty_id'] as String?,
      facultyName: json['faculty_name'] as String?,
      programId: json['program_id'] as String?,
      programName: json['program_name'] as String?,
      permissions: json['permissions'] != null
          ? List<String>.from(json['permissions'] as List)
          : const [],
      startsAt: json['starts_at'] != null
          ? DateTime.parse(json['starts_at'] as String)
          : null,
      endsAt: json['ends_at'] != null
          ? DateTime.parse(json['ends_at'] as String)
          : null,
      status: json['status'] as String? ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'election_id': electionId,
      'user_id': userId,
      'user_name': userName,
      'user_email': userEmail,
      'role': role,
      'campus_id': campusId,
      'campus_name': campusName,
      'faculty_id': facultyId,
      'faculty_name': facultyName,
      'program_id': programId,
      'program_name': programName,
      'permissions': permissions,
      'starts_at': startsAt?.toIso8601String(),
      'ends_at': endsAt?.toIso8601String(),
      'status': status,
    };
  }
}
