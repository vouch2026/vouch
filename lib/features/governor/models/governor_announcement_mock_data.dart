class GovernorAnnouncementMockData {
  GovernorAnnouncementMockData._();

  static final List<Map<String, dynamic>> announcements = [
    {
      'id': '1',
      'title': 'Welcome to the New Academic Year!',
      'content': 'We are excited to welcome all new and returning students to ACES. Let\'s make this year productive and memorable. Check out the upcoming orientation events in the Events tab.',
      'category': 'General',
      'author': 'Governor John Doe',
      'date': 'Oct 25, 2026',
      'isPinned': true,
      'readCount': 124,
    },
    {
      'id': '2',
      'title': 'Urgent: Membership Fee Deadline',
      'content': 'Please be reminded that the deadline for the Annual Membership Fee is on October 30, 2026. Avoid late charges by paying through the Finance tab before the due date.',
      'category': 'Urgent',
      'author': 'Treasurer Maria Santos',
      'date': 'Oct 24, 2026',
      'isPinned': false,
      'readCount': 342,
    },
    {
      'id': '3',
      'title': 'Siglakas 2026 T-Shirt Pre-orders',
      'content': 'Pre-orders for the official Siglakas 2026 T-shirts are now open! Visit the Finance tab to secure yours. Limited stocks only.',
      'category': 'Events',
      'author': 'Governor John Doe',
      'date': 'Oct 22, 2026',
      'isPinned': false,
      'readCount': 89,
    },
    {
      'id': '4',
      'title': 'Call for Volunteers: Community Outreach',
      'content': 'We are looking for passionate individuals to join our upcoming community outreach program in Brgy. Dahican. Sign up at the student council office.',
      'category': 'General',
      'author': 'Secretary Michael Chen',
      'date': 'Oct 20, 2026',
      'isPinned': false,
      'readCount': 56,
    },
  ];
}
