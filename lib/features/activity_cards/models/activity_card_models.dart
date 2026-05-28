import 'package:flutter/foundation.dart';

enum ActivityCardStatus {
  pending,
  inReview,
  partiallySigned,
  cleared,
  rejected,
  expired
}

enum AttendanceStatus {
  completed,
  pending,
  absent,
  excused,
  rejected
}

enum SignatureStatus {
  signed,
  pending,
  rejected,
  locked
}

class ActivityCard {
  final String id;
  final String studentId;
  final String organizationId;
  final String organizationName;
  final String? organizationLogo;
  final String organizationType;
  final String academicYear;
  final String semester;
  final ActivityCardStatus status;
  final double completionPercentage;
  final List<ActivityCardEvent> events;
  final List<ActivityCardSignature> signatures;

  const ActivityCard({
    required this.id,
    required this.studentId,
    required this.organizationId,
    required this.organizationName,
    this.organizationLogo,
    required this.organizationType,
    required this.academicYear,
    required this.semester,
    required this.status,
    required this.completionPercentage,
    required this.events,
    required this.signatures,
  });
}

class ActivityCardEvent {
  final String id;
  final String eventId;
  final String title;
  final String category;
  final DateTime date;
  final AttendanceStatus attendanceStatus;
  final String? verifiedBy;
  final DateTime? completedAt;

  const ActivityCardEvent({
    required this.id,
    required this.eventId,
    required this.title,
    required this.category,
    required this.date,
    required this.attendanceStatus,
    this.verifiedBy,
    this.completedAt,
  });
}

class ActivityCardSignature {
  final String id;
  final String roleName; // e.g., Secretary, Treasurer, Governor, Adviser
  final String? signedByUserId;
  final String? signedByUserName;
  final SignatureStatus status;
  final DateTime? signedAt;
  final String? rejectionReason;
  final int order; // To define the workflow pipeline sequence

  const ActivityCardSignature({
    required this.id,
    required this.roleName,
    this.signedByUserId,
    this.signedByUserName,
    required this.status,
    this.signedAt,
    this.rejectionReason,
    required this.order,
  });
}
