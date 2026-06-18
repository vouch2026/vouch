class ComplianceMemberModel {
  final String studentId;
  final String schoolId;
  final String name;
  final String program;
  final int? year;
  final int attendedEvents;
  final int totalMandatoryEvents;
  final double sanctionScore;

  ComplianceMemberModel({
    required this.studentId,
    required this.schoolId,
    required this.name,
    required this.program,
    this.year,
    required this.attendedEvents,
    required this.totalMandatoryEvents,
    required this.sanctionScore,
  });
}
