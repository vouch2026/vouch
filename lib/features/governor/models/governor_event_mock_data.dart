class GovernorEventMockData {
  GovernorEventMockData._();

  static final List<Map<String, dynamic>> todayEvents = [
    {
      'id': 10,
      'name': 'Organization General Assembly',
      'date': 'Today',
      'timeIn': '08:00 AM - 08:30 AM',
      'timeOut': '11:30 AM - 12:00 PM',
      'image': 'assets/images/event-siglakas.jpg',
      'isObligatory': true,
      'location': 'Main Campus Gymnasium',
    },
  ];

  static final List<Map<String, dynamic>> upcomingEvents = [
    {
      'id': 1,
      'name': 'Mind & Wellness Seminar',
      'date': 'November 06, 2026',
      'timeIn': '08:00 AM - 08:15 AM',
      'timeOut': '04:00 PM - 04:15 PM',
      'image': 'assets/images/mind-wellnes.jpg',
      'isObligatory': false,
      'location': 'AVR 1',
    },
    {
      'id': 2,
      'name': 'Service & Outreach Program',
      'date': 'November 10, 2026',
      'timeIn': '08:00 AM - 08:15 AM',
      'timeOut': '04:00 PM - 04:15 PM',
      'image': 'assets/images/service-outreach.jpg',
      'isObligatory': false,
      'location': 'Brgy. Dahican Hall',
    },
    {
      'id': 3,
      'name': 'Siglakas Day 1',
      'date': 'April 06-12, 2026',
      'timeIn': '08:00 AM - 08:15 AM',
      'timeOut': '08:00 PM - 08:15 PM',
      'image': 'assets/images/event-siglakas.jpg',
      'isObligatory': true,
      'location': 'Sports Complex',
    },
  ];

  static final List<Map<String, dynamic>> pastEvents = [
    {
      'id': 4,
      'name': 'General Convocation',
      'date': 'April 06, 2026',
      'timeIn': '08:50 AM',
      'timeOut': '07:50 PM',
      'attended': true,
      'image': 'assets/images/event-siglakas.jpg',
    },
    {
      'id': 5,
      'name': 'Buwan Ng Wika',
      'date': 'August 30, 2025',
      'timeIn': '08:50 AM',
      'timeOut': '07:50 PM',
      'attended': true,
      'image': 'assets/images/event-siglakas.jpg',
    },
    {
      'id': 6,
      'name': 'Panaghigalaay',
      'date': 'September 15, 2025',
      'timeIn': null,
      'timeOut': null,
      'attended': false,
      'image': 'assets/images/event-siglakas.jpg',
    },
  ];

  static final List<Map<String, dynamic>> ratedEvents = [
    {
      'eventId': 5,
      'name': 'Buwan Ng Wika',
      'date': 'August 30, 2025',
      'rating': 4.5,
      'reviews': 125,
      'ratingBreakdown': {'5': 75, '4': 15, '3': 5, '2': 3, '1': 2},
      'comments': [
        {
          'name': 'A. Student',
          'comment': 'Very organized and enjoyable event.',
          'date': 'Apr 13, 2026',
        },
        {
          'name': 'M. Garcia',
          'comment': 'Program flow was smooth from start to finish.',
          'date': 'Apr 13, 2026',
        },
      ],
    },
    {
      'eventId': 4,
      'name': 'General Convocation',
      'date': 'April 06, 2026',
      'rating': 4.7,
      'reviews': 125,
      'ratingBreakdown': {'5': 80, '4': 15, '3': 5, '2': 0, '1': 0},
      'comments': [
        {
          'name': 'R. Dela Cruz',
          'comment': 'Speakers were informative and engaging.',
          'date': 'Apr 14, 2026',
        },
        {
          'name': 'J. Santos',
          'comment': 'Sound system and venue setup were excellent.',
          'date': 'Apr 14, 2026',
        },
      ],
    },
  ];
}
