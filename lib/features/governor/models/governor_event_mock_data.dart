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
}
