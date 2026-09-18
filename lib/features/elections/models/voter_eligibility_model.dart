class VoterEligibilityModel {
  final String id;
  final String electionId;
  final String studentId;
  final String? studentName;
  final String? studentNumber;
  final String? facultyName;
  final String? programName;
  final String eligibilityStatus; // PENDING, ELIGIBLE, INELIGIBLE, MANUAL_REVIEW, SUSPENDED
  final String? ineligibilityReason;
  final String verificationSource;
  final String? verifiedBy;
  final DateTime? verifiedAt;

  const VoterEligibilityModel({
    required this.id,
    required this.electionId,
    required this.studentId,
    this.studentName,
    this.studentNumber,
    this.facultyName,
    this.programName,
    this.eligibilityStatus = 'PENDING',
    this.ineligibilityReason,
    this.verificationSource = 'SYSTEM_AUTO',
    this.verifiedBy,
    this.verifiedAt,
  });

  factory VoterEligibilityModel.fromJson(Map<String, dynamic> json) {
    return VoterEligibilityModel(
      id: json['id'] as String,
      electionId: json['election_id'] as String,
      studentId: json['student_id'] as String,
      studentName: json['student_name'] as String?,
      studentNumber: json['student_number'] as String?,
      facultyName: json['faculty_name'] as String?,
      programName: json['program_name'] as String?,
      eligibilityStatus: json['eligibility_status'] as String? ?? 'PENDING',
      ineligibilityReason: json['ineligibility_reason'] as String?,
      verificationSource: json['verification_source'] as String? ?? 'SYSTEM_AUTO',
      verifiedBy: json['verified_by'] as String?,
      verifiedAt: json['verified_at'] != null
          ? DateTime.parse(json['verified_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'election_id': electionId,
      'student_id': studentId,
      'student_name': studentName,
      'student_number': studentNumber,
      'faculty_name': facultyName,
      'program_name': programName,
      'eligibility_status': eligibilityStatus,
      'ineligibility_reason': ineligibilityReason,
      'verification_source': verificationSource,
      'verified_by': verifiedBy,
      'verified_at': verifiedAt?.toIso8601String(),
    };
  }
}
