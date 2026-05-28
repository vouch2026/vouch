import '../models/activity_card_models.dart';

class ActivityCardMockData {
  ActivityCardMockData._();

  static final List<ActivityCard> studentActivityCards = [
    ActivityCard(
      id: 'ac-1',
      studentId: 'student-123',
      organizationId: 'aces-001',
      organizationName: 'ACES',
      organizationType: 'Faculty-Based Organization',
      academicYear: 'AY 2025–2026',
      semester: '1st Semester',
      status: ActivityCardStatus.partiallySigned,
      completionPercentage: 0.75,
      events: [
        ActivityCardEvent(
          id: 'ace-1',
          eventId: 'e-1',
          title: 'ACES General Assembly',
          category: 'Mandatory',
          date: DateTime(2025, 9, 15),
          attendanceStatus: AttendanceStatus.completed,
          verifiedBy: 'Secretary Maria',
          completedAt: DateTime(2025, 9, 15, 14, 30),
        ),
        ActivityCardEvent(
          id: 'ace-2',
          eventId: 'e-2',
          title: 'Leadership Training',
          category: 'Mandatory',
          date: DateTime(2025, 10, 5),
          attendanceStatus: AttendanceStatus.completed,
          verifiedBy: 'Secretary Maria',
          completedAt: DateTime(2025, 10, 5, 16, 00),
        ),
        ActivityCardEvent(
          id: 'ace-3',
          eventId: 'e-3',
          title: 'Community Outreach',
          category: 'Mandatory',
          date: DateTime(2025, 11, 20),
          attendanceStatus: AttendanceStatus.pending,
        ),
      ],
      signatures: [
        ActivityCardSignature(
          id: 'acs-1',
          roleName: 'Secretary',
          signedByUserId: 'sec-001',
          signedByUserName: 'Maria Santos',
          status: SignatureStatus.signed,
          signedAt: DateTime(2025, 11, 25),
          order: 1,
        ),
        ActivityCardSignature(
          id: 'acs-2',
          roleName: 'Treasurer',
          signedByUserId: 'tre-001',
          signedByUserName: 'Juan Dela Cruz',
          status: SignatureStatus.signed,
          signedAt: DateTime(2025, 11, 26),
          order: 2,
        ),
        ActivityCardSignature(
          id: 'acs-3',
          roleName: 'Governor',
          status: SignatureStatus.pending,
          order: 3,
        ),
        ActivityCardSignature(
          id: 'acs-4',
          roleName: 'Adviser',
          status: SignatureStatus.locked,
          order: 4,
        ),
      ],
    ),
    ActivityCard(
      id: 'ac-2',
      studentId: 'student-123',
      organizationId: 'usc-001',
      organizationName: 'USC',
      organizationType: 'University-Wide Organization',
      academicYear: 'AY 2025–2026',
      semester: '1st Semester',
      status: ActivityCardStatus.pending,
      completionPercentage: 0.40,
      events: [
        ActivityCardEvent(
          id: 'ace-usc-1',
          eventId: 'e-usc-1',
          title: 'Acquaintance Party',
          category: 'Mandatory',
          date: DateTime(2025, 8, 20),
          attendanceStatus: AttendanceStatus.completed,
          verifiedBy: 'Secretary USC',
          completedAt: DateTime(2025, 8, 20, 20, 00),
        ),
        ActivityCardEvent(
          id: 'ace-usc-2',
          eventId: 'e-usc-2',
          title: 'Mid-term Forum',
          category: 'Mandatory',
          date: DateTime(2025, 10, 12),
          attendanceStatus: AttendanceStatus.absent,
        ),
      ],
      signatures: [
        ActivityCardSignature(
          id: 'acs-usc-1',
          roleName: 'Secretary',
          status: SignatureStatus.locked,
          order: 1,
        ),
        ActivityCardSignature(
          id: 'acs-usc-2',
          roleName: 'Treasurer',
          status: SignatureStatus.locked,
          order: 2,
        ),
        ActivityCardSignature(
          id: 'acs-usc-3',
          roleName: 'Governor',
          status: SignatureStatus.locked,
          order: 3,
        ),
        ActivityCardSignature(
          id: 'acs-usc-4',
          roleName: 'Adviser',
          status: SignatureStatus.locked,
          order: 4,
        ),
      ],
    ),
  ];
}
