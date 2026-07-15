enum ActivityCardStatus {
  draft,
  inProgress,
  secretaryReview,
  treasurerReview,
  governorReview,
  adviserReview,
  programHeadReview,
  deanReview,
  cleared,
  rejected,
  // Retaining legacy values for compile compatibility
  pending,
  inReview,
  partiallySigned,
  expired
}

enum AttendanceStatus {
  completed,
  pending,
  absent,
  excused,
  rejected,
  sanctionCleared
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
  final String? studentName;
  final String? studentProgram;
  final String organizationId;
  final String organizationName;
  final String? organizationLogo;
  final String organizationType;
  final String academicYear;
  final String semester;
  final ActivityCardStatus status;
  final bool isOfficer;
  final double completionPercentage;
  final List<ActivityCardEvent> events;
  final List<ActivityCardFee> fees;
  final List<ActivityCardSanction> sanctions;
  final List<ActivityCardSignature> signatures;
  final DateTime? clearedAt;
  final String organizationCode;

  const ActivityCard({
    required this.id,
    required this.studentId,
    this.studentName,
    this.studentProgram,
    required this.organizationId,
    required this.organizationName,
    this.organizationLogo,
    required this.organizationType,
    required this.academicYear,
    required this.semester,
    required this.status,
    this.isOfficer = false,
    required this.completionPercentage,
    required this.events,
    required this.fees,
    required this.sanctions,
    required this.signatures,
    this.clearedAt,
    required this.organizationCode,
  });
}

class ActivityCardSanction {
  final String id;
  final String description;
  final bool isFulfilled;
  final DateTime? fulfilledAt;

  const ActivityCardSanction({
    required this.id,
    required this.description,
    required this.isFulfilled,
    this.fulfilledAt,
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

class ActivityCardFee {
  final String id;
  final String feeId;
  final String title;
  final String category;
  final double amount;
  final bool isPaid;
  final DateTime? paidAt;
  final String? referenceNumber;
  final String? verifiedBy;

  const ActivityCardFee({
    required this.id,
    required this.feeId,
    required this.title,
    required this.category,
    required this.amount,
    required this.isPaid,
    this.paidAt,
    this.referenceNumber,
    this.verifiedBy,
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
