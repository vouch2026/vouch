class AppPermissions {
  AppPermissions._();

  // Operations
  static const String viewEvents = 'view_events';
  static const String createEvent = 'create_event';
  static const String editEvent = 'edit_event';
  static const String deleteEvent = 'delete_event';
  static const String scanEventAttendance = 'scan_event_attendance';
  static const String manageActivityCards = 'manage_activity_cards';
  static const String viewActivityCards = 'view_activity_cards';
  static const String viewAnnouncements = 'view_announcements';
  static const String createAnnouncement = 'create_announcement';
  static const String editAnnouncement = 'edit_announcement';
  static const String deleteAnnouncement = 'delete_announcement';
  static const String viewDocuments = 'view_documents';
  
  // People
  static const String viewMembers = 'view_members';
  static const String viewOfficers = 'view_officers';
  static const String assignRoles = 'assign_roles';
  static const String revokeRoles = 'revoke_roles';
  
  // Finance
  static const String viewFees = 'view_fees';
  static const String createFee = 'create_fee';
  static const String editFee = 'edit_fee';
  static const String deleteFee = 'delete_fee';
  static const String managePaymentReceivers = 'manage_payment_receivers';
  static const String verifyPayment = 'verify_payment';
  static const String rejectPayment = 'reject_payment';
  static const String manageCollections = 'manage_collections';
  
  // Insights & Analytics
  static const String viewAnalytics = 'view_analytics';
  static const String viewProgramAnalytics = 'view_program_analytics';
  static const String viewFacultyAnalytics = 'view_faculty_analytics';
  static const String viewElectionAnalytics = 'view_election_analytics';
  
  // Settings & Management
  static const String manageOrganization = 'manage_organization';
  static const String manageElections = 'manage_elections';
  static const String manageAcademicTerms = 'manage_academic_terms';
  static const String manageFaculties = 'manage_faculties';
  static const String managePrograms = 'manage_programs';

  // Sanctions
  static const String viewSanctions = 'view_sanctions';
  static const String createSanctionRules = 'create_sanction_rules';
  static const String editSanctionRules = 'edit_sanction_rules';
  static const String deleteSanctionRules = 'delete_sanction_rules';
  static const String receiveSanctionItems = 'receive_sanction_items';
}
