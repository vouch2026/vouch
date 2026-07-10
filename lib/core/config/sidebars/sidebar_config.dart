import 'package:flutter/material.dart';
import '../../../routes/route_paths.dart';
import '../../utils/role_mapper.dart';

class SidebarItemConfig {
  final String label;
  final IconData icon;
  final String path;

  const SidebarItemConfig({
    required this.label,
    required this.icon,
    required this.path,
  });
}

class SidebarSectionConfig {
  final String title;
  final List<SidebarItemConfig> items;

  const SidebarSectionConfig({
    required this.title,
    required this.items,
  });
}

String getSidebarRoleKey(String roleName) {
  final normalized = RoleMapper.mapDbRoleToAppFormat(roleName);
  switch (normalized) {
    case 'governor':
    case 'president':
      return 'governor_president';
    case 'vice_governor':
    case 'vice_president':
      return 'vice_governor_vice_president';
    case 'secretary':
    case 'assistant_secretary':
    case 'faculty_secretary':
    case 'program_secretary':
      return 'secretary';
    case 'treasurer':
    case 'faculty_treasurer':
    case 'program_treasurer':
      return 'treasurer';
    case 'auditor':
      return 'auditor';
    case 'pio':
      return 'pio';
    case 'business_manager':
      return 'business_manager';
    case 'senator':
      return 'senator';
    case 'staff':
      return 'staff';
    case 'adviser':
      return 'adviser';
    case 'dean':
      return 'dean';
    case 'program_head':
      return 'program_head';
    case 'member':
    case 'student':
    default:
      return 'member';
  }
}

final Map<String, List<SidebarSectionConfig>> roleSidebars = {
  'adviser': [
    const SidebarSectionConfig(
      title: 'PERSONAL HUB',
      items: [
        SidebarItemConfig(label: 'Home', icon: Icons.home_outlined, path: RoutePaths.dashboard),
        SidebarItemConfig(label: 'Tasks', icon: Icons.assignment_turned_in_outlined, path: RoutePaths.tasks),
        SidebarItemConfig(label: 'Calendar', icon: Icons.calendar_today_outlined, path: RoutePaths.calendar),
        SidebarItemConfig(label: 'Schedule', icon: Icons.schedule_outlined, path: RoutePaths.schedule),
        SidebarItemConfig(label: 'Notifications', icon: Icons.notifications_none_rounded, path: RoutePaths.notifications),
      ],
    ),
    const SidebarSectionConfig(
      title: 'WORKSPACE: DETAILS',
      items: [
        SidebarItemConfig(label: 'Dashboard', icon: Icons.grid_view_rounded, path: RoutePaths.workspaceDashboard),
      ],
    ),
    const SidebarSectionConfig(
      title: 'PEOPLE',
      items: [
        SidebarItemConfig(label: 'Members', icon: Icons.people_outline_rounded, path: RoutePaths.workspaceMembers),
        SidebarItemConfig(label: 'Officers', icon: Icons.badge_outlined, path: RoutePaths.workspaceOfficers),
      ],
    ),
    const SidebarSectionConfig(
      title: 'OPERATIONS',
      items: [
        SidebarItemConfig(label: 'Events', icon: Icons.calendar_month_outlined, path: RoutePaths.workspaceEvents),
        SidebarItemConfig(label: 'Announcements', icon: Icons.campaign_outlined, path: RoutePaths.workspaceAnnouncements),
      ],
    ),
    const SidebarSectionConfig(
      title: 'STUDENT AFFAIRS',
      items: [
        SidebarItemConfig(label: 'Excuse Requests', icon: Icons.note_alt_outlined, path: RoutePaths.workspaceExcuseRequests),
        SidebarItemConfig(label: 'Sanctions', icon: Icons.gavel_rounded, path: RoutePaths.workspaceSanctions),
        SidebarItemConfig(label: 'Activity Clearances', icon: Icons.assignment_outlined, path: RoutePaths.workspaceActivityCards),
      ],
    ),
    const SidebarSectionConfig(
      title: 'FINANCE',
      items: [
        SidebarItemConfig(label: 'Fees', icon: Icons.payments_outlined, path: RoutePaths.workspaceFees),
        SidebarItemConfig(label: 'Collections', icon: Icons.account_balance_wallet_outlined, path: RoutePaths.workspaceCollections),
        SidebarItemConfig(label: 'Financial Reports', icon: Icons.assessment_outlined, path: RoutePaths.workspaceFinanceReports),
      ],
    ),
    const SidebarSectionConfig(
      title: 'INSIGHTS',
      items: [
        SidebarItemConfig(label: 'Reports', icon: Icons.bar_chart_rounded, path: RoutePaths.workspaceReports),
      ],
    ),
    const SidebarSectionConfig(
      title: 'GOVERNANCE',
      items: [
        SidebarItemConfig(label: 'Officer Appointments', icon: Icons.assignment_ind_outlined, path: RoutePaths.workspaceOfficerAppointments),
        SidebarItemConfig(label: 'Organization Settings', icon: Icons.settings_outlined, path: RoutePaths.workspaceSettings),
      ],
    ),
  ],

  'auditor': [
    const SidebarSectionConfig(
      title: 'PERSONAL HUB',
      items: [
        SidebarItemConfig(label: 'Home', icon: Icons.home_outlined, path: RoutePaths.dashboard),
        SidebarItemConfig(label: 'Tasks', icon: Icons.assignment_turned_in_outlined, path: RoutePaths.tasks),
        SidebarItemConfig(label: 'Calendar', icon: Icons.calendar_today_outlined, path: RoutePaths.calendar),
        SidebarItemConfig(label: 'Schedule', icon: Icons.schedule_outlined, path: RoutePaths.schedule),
        SidebarItemConfig(label: 'Notifications', icon: Icons.notifications_none_rounded, path: RoutePaths.notifications),
      ],
    ),
    const SidebarSectionConfig(
      title: 'WORKSPACE: DETAILS',
      items: [
        SidebarItemConfig(label: 'Dashboard', icon: Icons.grid_view_rounded, path: RoutePaths.workspaceDashboard),
      ],
    ),
    const SidebarSectionConfig(
      title: 'FINANCE',
      items: [
        SidebarItemConfig(label: 'Financial Reports', icon: Icons.assessment_outlined, path: RoutePaths.workspaceFinanceReports),
        SidebarItemConfig(label: 'Collections Audit', icon: Icons.price_check_outlined, path: RoutePaths.workspaceCollectionsAudit),
      ],
    ),
    const SidebarSectionConfig(
      title: 'AUDIT',
      items: [
        SidebarItemConfig(label: 'Audit Logs', icon: Icons.receipt_long_outlined, path: RoutePaths.workspaceAuditLogs),
        SidebarItemConfig(label: 'Audit Reports', icon: Icons.find_in_page_outlined, path: RoutePaths.workspaceAuditReports),
      ],
    ),
    const SidebarSectionConfig(
      title: 'INSIGHTS',
      items: [
        SidebarItemConfig(label: 'Audit Analytics', icon: Icons.query_stats_outlined, path: RoutePaths.workspaceAuditAnalytics),
      ],
    ),
  ],

  'business_manager': [
    const SidebarSectionConfig(
      title: 'PERSONAL HUB',
      items: [
        SidebarItemConfig(label: 'Home', icon: Icons.home_outlined, path: RoutePaths.dashboard),
        SidebarItemConfig(label: 'Tasks', icon: Icons.assignment_turned_in_outlined, path: RoutePaths.tasks),
        SidebarItemConfig(label: 'Calendar', icon: Icons.calendar_today_outlined, path: RoutePaths.calendar),
        SidebarItemConfig(label: 'Schedule', icon: Icons.schedule_outlined, path: RoutePaths.schedule),
        SidebarItemConfig(label: 'Notifications', icon: Icons.notifications_none_rounded, path: RoutePaths.notifications),
      ],
    ),
    const SidebarSectionConfig(
      title: 'WORKSPACE: DETAILS',
      items: [
        SidebarItemConfig(label: 'Dashboard', icon: Icons.grid_view_rounded, path: RoutePaths.workspaceDashboard),
      ],
    ),
    const SidebarSectionConfig(
      title: 'OPERATIONS',
      items: [
        SidebarItemConfig(label: 'Events', icon: Icons.calendar_month_outlined, path: RoutePaths.workspaceEvents),
        SidebarItemConfig(label: 'Announcements', icon: Icons.campaign_outlined, path: RoutePaths.workspaceAnnouncements),
      ],
    ),
    const SidebarSectionConfig(
      title: 'BUSINESS',
      items: [
        SidebarItemConfig(label: 'Projects', icon: Icons.assignment_outlined, path: RoutePaths.workspaceProjects),
        SidebarItemConfig(label: 'Sales', icon: Icons.point_of_sale_outlined, path: RoutePaths.workspaceSales),
        SidebarItemConfig(label: 'Inventory', icon: Icons.inventory_2_outlined, path: RoutePaths.workspaceInventory),
        SidebarItemConfig(label: 'Sponsors & Partners', icon: Icons.handshake_outlined, path: RoutePaths.workspaceSponsors),
      ],
    ),
    const SidebarSectionConfig(
      title: 'FINANCE',
      items: [
        SidebarItemConfig(label: 'Financial Requests', icon: Icons.receipt_long_outlined, path: RoutePaths.workspaceFinancialRequests),
        SidebarItemConfig(label: 'Collections (View Only)', icon: Icons.account_balance_wallet_outlined, path: RoutePaths.workspaceCollections),
      ],
    ),
    const SidebarSectionConfig(
      title: 'PEOPLE',
      items: [
        SidebarItemConfig(label: 'Members', icon: Icons.people_outline_rounded, path: RoutePaths.workspaceMembers),
        SidebarItemConfig(label: 'Officers', icon: Icons.badge_outlined, path: RoutePaths.workspaceOfficers),
      ],
    ),
  ],

  'governor_president': [
    const SidebarSectionConfig(
      title: 'PERSONAL HUB',
      items: [
        SidebarItemConfig(label: 'Home', icon: Icons.home_outlined, path: RoutePaths.dashboard),
        SidebarItemConfig(label: 'Tasks', icon: Icons.assignment_turned_in_outlined, path: RoutePaths.tasks),
        SidebarItemConfig(label: 'Calendar', icon: Icons.calendar_today_outlined, path: RoutePaths.calendar),
        SidebarItemConfig(label: 'Schedule', icon: Icons.schedule_outlined, path: RoutePaths.schedule),
        SidebarItemConfig(label: 'Notifications', icon: Icons.notifications_none_rounded, path: RoutePaths.notifications),
      ],
    ),
    const SidebarSectionConfig(
      title: 'WORKSPACE: DETAILS',
      items: [
        SidebarItemConfig(label: 'Dashboard', icon: Icons.grid_view_rounded, path: RoutePaths.workspaceDashboard),
      ],
    ),
    const SidebarSectionConfig(
      title: 'PEOPLE',
      items: [
        SidebarItemConfig(label: 'Members', icon: Icons.people_outline_rounded, path: RoutePaths.workspaceMembers),
        SidebarItemConfig(label: 'Officers', icon: Icons.badge_outlined, path: RoutePaths.workspaceOfficers),
      ],
    ),
    const SidebarSectionConfig(
      title: 'OPERATIONS',
      items: [
        SidebarItemConfig(label: 'Events', icon: Icons.calendar_month_outlined, path: RoutePaths.workspaceEvents),
        SidebarItemConfig(label: 'Announcements', icon: Icons.campaign_outlined, path: RoutePaths.workspaceAnnouncements),
      ],
    ),
    const SidebarSectionConfig(
      title: 'STUDENT AFFAIRS',
      items: [
        SidebarItemConfig(label: 'Excuse Requests', icon: Icons.note_alt_outlined, path: RoutePaths.workspaceExcuseRequests),
        SidebarItemConfig(label: 'Sanctions', icon: Icons.gavel_rounded, path: RoutePaths.workspaceSanctions),
        SidebarItemConfig(label: 'Activity Clearances', icon: Icons.assignment_outlined, path: RoutePaths.workspaceActivityCards),
      ],
    ),
    const SidebarSectionConfig(
      title: 'FINANCE',
      items: [
        SidebarItemConfig(label: 'Fees', icon: Icons.payments_outlined, path: RoutePaths.workspaceFees),
        SidebarItemConfig(label: 'Collections', icon: Icons.account_balance_wallet_outlined, path: RoutePaths.workspaceCollections),
      ],
    ),
    const SidebarSectionConfig(
      title: 'INSIGHTS',
      items: [
        SidebarItemConfig(label: 'Reports', icon: Icons.bar_chart_rounded, path: RoutePaths.workspaceReports),
      ],
    ),
    const SidebarSectionConfig(
      title: 'GOVERNANCE',
      items: [
        SidebarItemConfig(label: 'Organization Settings', icon: Icons.settings_outlined, path: RoutePaths.workspaceSettings),
      ],
    ),
  ],

  'member': [
    const SidebarSectionConfig(
      title: 'PERSONAL HUB',
      items: [
        SidebarItemConfig(label: 'Home', icon: Icons.home_outlined, path: RoutePaths.dashboard),
        SidebarItemConfig(label: 'Tasks', icon: Icons.assignment_turned_in_outlined, path: RoutePaths.tasks),
        SidebarItemConfig(label: 'Calendar', icon: Icons.calendar_today_outlined, path: RoutePaths.calendar),
        SidebarItemConfig(label: 'Schedule', icon: Icons.schedule_outlined, path: RoutePaths.schedule),
        SidebarItemConfig(label: 'Notifications', icon: Icons.notifications_none_rounded, path: RoutePaths.notifications),
      ],
    ),
    const SidebarSectionConfig(
      title: 'WORKSPACE: DETAILS',
      items: [
        SidebarItemConfig(label: 'Dashboard', icon: Icons.grid_view_rounded, path: RoutePaths.workspaceDashboard),
      ],
    ),
    const SidebarSectionConfig(
      title: 'OPERATIONS',
      items: [
        SidebarItemConfig(label: 'Events', icon: Icons.calendar_month_outlined, path: RoutePaths.workspaceEvents),
        SidebarItemConfig(label: 'Announcements', icon: Icons.campaign_outlined, path: RoutePaths.workspaceAnnouncements),
      ],
    ),
    const SidebarSectionConfig(
      title: 'STUDENT AFFAIRS',
      items: [
        SidebarItemConfig(label: 'Excuse Requests', icon: Icons.note_alt_outlined, path: RoutePaths.myExcuseRequests),
        SidebarItemConfig(label: 'Sanctions', icon: Icons.gavel_rounded, path: RoutePaths.workspaceSanctions),
        SidebarItemConfig(label: 'Activity Clearances', icon: Icons.assignment_outlined, path: RoutePaths.activityCards),
      ],
    ),
    const SidebarSectionConfig(
      title: 'FINANCE',
      items: [
        SidebarItemConfig(label: 'Fees', icon: Icons.payments_outlined, path: RoutePaths.workspaceFees),
      ],
    ),
  ],

  'pio': [
    const SidebarSectionConfig(
      title: 'PERSONAL HUB',
      items: [
        SidebarItemConfig(label: 'Home', icon: Icons.home_outlined, path: RoutePaths.dashboard),
        SidebarItemConfig(label: 'Tasks', icon: Icons.assignment_turned_in_outlined, path: RoutePaths.tasks),
        SidebarItemConfig(label: 'Calendar', icon: Icons.calendar_today_outlined, path: RoutePaths.calendar),
        SidebarItemConfig(label: 'Schedule', icon: Icons.schedule_outlined, path: RoutePaths.schedule),
        SidebarItemConfig(label: 'Notifications', icon: Icons.notifications_none_rounded, path: RoutePaths.notifications),
      ],
    ),
    const SidebarSectionConfig(
      title: 'WORKSPACE: DETAILS',
      items: [
        SidebarItemConfig(label: 'Dashboard', icon: Icons.grid_view_rounded, path: RoutePaths.workspaceDashboard),
      ],
    ),
    const SidebarSectionConfig(
      title: 'OPERATIONS',
      items: [
        SidebarItemConfig(label: 'Announcements', icon: Icons.campaign_outlined, path: RoutePaths.workspaceAnnouncements),
        SidebarItemConfig(label: 'Events', icon: Icons.calendar_month_outlined, path: RoutePaths.workspaceEvents),
      ],
    ),
    const SidebarSectionConfig(
      title: 'MEDIA',
      items: [
        SidebarItemConfig(label: 'Publications', icon: Icons.article_outlined, path: RoutePaths.workspacePublications),
        SidebarItemConfig(label: 'Gallery', icon: Icons.photo_library_outlined, path: RoutePaths.workspaceGallery),
      ],
    ),
    const SidebarSectionConfig(
      title: 'INSIGHTS',
      items: [
        SidebarItemConfig(label: 'Engagement Reports', icon: Icons.auto_graph_outlined, path: RoutePaths.workspaceEngagementReports),
      ],
    ),
  ],

  'secretary': [
    const SidebarSectionConfig(
      title: 'PERSONAL HUB',
      items: [
        SidebarItemConfig(label: 'Home', icon: Icons.home_outlined, path: RoutePaths.dashboard),
        SidebarItemConfig(label: 'Tasks', icon: Icons.assignment_turned_in_outlined, path: RoutePaths.tasks),
        SidebarItemConfig(label: 'Calendar', icon: Icons.calendar_today_outlined, path: RoutePaths.calendar),
        SidebarItemConfig(label: 'Schedule', icon: Icons.schedule_outlined, path: RoutePaths.schedule),
        SidebarItemConfig(label: 'Notifications', icon: Icons.notifications_none_rounded, path: RoutePaths.notifications),
      ],
    ),
    const SidebarSectionConfig(
      title: 'WORKSPACE: DETAILS',
      items: [
        SidebarItemConfig(label: 'Dashboard', icon: Icons.grid_view_rounded, path: RoutePaths.workspaceDashboard),
      ],
    ),
    const SidebarSectionConfig(
      title: 'PEOPLE',
      items: [
        SidebarItemConfig(label: 'Members', icon: Icons.people_outline_rounded, path: RoutePaths.workspaceMembers),
      ],
    ),
    const SidebarSectionConfig(
      title: 'OPERATIONS',
      items: [
        SidebarItemConfig(label: 'Events', icon: Icons.calendar_month_outlined, path: RoutePaths.workspaceEvents),
        SidebarItemConfig(label: 'Announcements', icon: Icons.campaign_outlined, path: RoutePaths.workspaceAnnouncements),
      ],
    ),
    const SidebarSectionConfig(
      title: 'STUDENT AFFAIRS',
      items: [
        SidebarItemConfig(label: 'Excuse Requests', icon: Icons.note_alt_outlined, path: RoutePaths.workspaceExcuseRequests),
        SidebarItemConfig(label: 'Sanctions', icon: Icons.gavel_rounded, path: RoutePaths.workspaceSanctions),
        SidebarItemConfig(label: 'Activity Clearances', icon: Icons.assignment_outlined, path: RoutePaths.workspaceActivityCards),
      ],
    ),
    const SidebarSectionConfig(
      title: 'RECORDS',
      items: [
        SidebarItemConfig(label: 'Documents', icon: Icons.folder_open_rounded, path: RoutePaths.workspaceDocuments),
        SidebarItemConfig(label: 'Meeting Minutes', icon: Icons.description_outlined, path: RoutePaths.workspaceMeetingMinutes),
      ],
    ),
    const SidebarSectionConfig(
      title: 'INSIGHTS',
      items: [
        SidebarItemConfig(label: 'Attendance Reports', icon: Icons.how_to_reg_rounded, path: RoutePaths.workspaceAttendanceReports),
      ],
    ),
  ],

  'senator': [
    const SidebarSectionConfig(
      title: 'PERSONAL HUB',
      items: [
        SidebarItemConfig(label: 'Home', icon: Icons.home_outlined, path: RoutePaths.dashboard),
        SidebarItemConfig(label: 'Tasks', icon: Icons.assignment_turned_in_outlined, path: RoutePaths.tasks),
        SidebarItemConfig(label: 'Calendar', icon: Icons.calendar_today_outlined, path: RoutePaths.calendar),
        SidebarItemConfig(label: 'Schedule', icon: Icons.schedule_outlined, path: RoutePaths.schedule),
        SidebarItemConfig(label: 'Notifications', icon: Icons.notifications_none_rounded, path: RoutePaths.notifications),
      ],
    ),
    const SidebarSectionConfig(
      title: 'WORKSPACE: DETAILS',
      items: [
        SidebarItemConfig(label: 'Dashboard', icon: Icons.grid_view_rounded, path: RoutePaths.workspaceDashboard),
      ],
    ),
    const SidebarSectionConfig(
      title: 'GOVERNANCE',
      items: [
        SidebarItemConfig(label: 'Proposals', icon: Icons.lightbulb_outline, path: RoutePaths.workspaceProposals),
        SidebarItemConfig(label: 'Voting', icon: Icons.how_to_vote_rounded, path: RoutePaths.workspaceVoting),
        SidebarItemConfig(label: 'Resolutions', icon: Icons.verified_outlined, path: RoutePaths.workspaceResolutions),
      ],
    ),
    const SidebarSectionConfig(
      title: 'OPERATIONS',
      items: [
        SidebarItemConfig(label: 'Announcements', icon: Icons.campaign_outlined, path: RoutePaths.workspaceAnnouncements),
      ],
    ),
    const SidebarSectionConfig(
      title: 'INSIGHTS',
      items: [
        SidebarItemConfig(label: 'Governance Reports', icon: Icons.poll_outlined, path: RoutePaths.workspaceGovernanceReports),
      ],
    ),
  ],

  'staff': [
    const SidebarSectionConfig(
      title: 'PERSONAL HUB',
      items: [
        SidebarItemConfig(label: 'Home', icon: Icons.home_outlined, path: RoutePaths.dashboard),
        SidebarItemConfig(label: 'Tasks', icon: Icons.assignment_turned_in_outlined, path: RoutePaths.tasks),
        SidebarItemConfig(label: 'Calendar', icon: Icons.calendar_today_outlined, path: RoutePaths.calendar),
        SidebarItemConfig(label: 'Schedule', icon: Icons.schedule_outlined, path: RoutePaths.schedule),
        SidebarItemConfig(label: 'Notifications', icon: Icons.notifications_none_rounded, path: RoutePaths.notifications),
      ],
    ),
    const SidebarSectionConfig(
      title: 'WORKSPACE: DETAILS',
      items: [
        SidebarItemConfig(label: 'Dashboard', icon: Icons.grid_view_rounded, path: RoutePaths.workspaceDashboard),
      ],
    ),
    const SidebarSectionConfig(
      title: 'FINANCE',
      items: [
        SidebarItemConfig(label: 'Fees', icon: Icons.payments_outlined, path: RoutePaths.workspaceFees),
      ],
    ),
    const SidebarSectionConfig(
      title: 'OPERATIONS',
      items: [
        SidebarItemConfig(label: 'Events', icon: Icons.calendar_month_outlined, path: RoutePaths.workspaceEvents),
        SidebarItemConfig(label: 'Announcements', icon: Icons.campaign_outlined, path: RoutePaths.workspaceAnnouncements),
      ],
    ),
    const SidebarSectionConfig(
      title: 'PEOPLE',
      items: [
        SidebarItemConfig(label: 'Members', icon: Icons.people_outline_rounded, path: RoutePaths.workspaceMembers),
      ],
    ),
    const SidebarSectionConfig(
      title: 'STUDENT AFFAIRS',
      items: [
        SidebarItemConfig(label: 'Activity Clearances', icon: Icons.assignment_outlined, path: RoutePaths.workspaceActivityCards),
      ],
    ),
  ],

  'treasurer': [
    const SidebarSectionConfig(
      title: 'PERSONAL HUB',
      items: [
        SidebarItemConfig(label: 'Home', icon: Icons.home_outlined, path: RoutePaths.dashboard),
        SidebarItemConfig(label: 'Tasks', icon: Icons.assignment_turned_in_outlined, path: RoutePaths.tasks),
        SidebarItemConfig(label: 'Calendar', icon: Icons.calendar_today_outlined, path: RoutePaths.calendar),
        SidebarItemConfig(label: 'Schedule', icon: Icons.schedule_outlined, path: RoutePaths.schedule),
        SidebarItemConfig(label: 'Notifications', icon: Icons.notifications_none_rounded, path: RoutePaths.notifications),
      ],
    ),
    const SidebarSectionConfig(
      title: 'WORKSPACE: DETAILS',
      items: [
        SidebarItemConfig(label: 'Dashboard', icon: Icons.grid_view_rounded, path: RoutePaths.workspaceDashboard),
      ],
    ),
    const SidebarSectionConfig(
      title: 'FINANCE',
      items: [
        SidebarItemConfig(label: 'Fees', icon: Icons.payments_outlined, path: RoutePaths.workspaceFees),
        SidebarItemConfig(label: 'Collections', icon: Icons.account_balance_wallet_outlined, path: RoutePaths.workspaceCollections),
        SidebarItemConfig(label: 'Financial Reports', icon: Icons.assessment_outlined, path: RoutePaths.workspaceFinanceReports),
      ],
    ),
    const SidebarSectionConfig(
      title: 'STUDENT AFFAIRS',
      items: [
        SidebarItemConfig(label: 'Activity Clearances', icon: Icons.assignment_outlined, path: RoutePaths.workspaceActivityCards),
      ],
    ),
    const SidebarSectionConfig(
      title: 'INSIGHTS',
      items: [
        SidebarItemConfig(label: 'Collection Analytics', icon: Icons.insert_chart_outlined, path: RoutePaths.workspaceCollectionAnalytics),
      ],
    ),
  ],

  'vice_governor_vice_president': [
    const SidebarSectionConfig(
      title: 'PERSONAL HUB',
      items: [
        SidebarItemConfig(label: 'Home', icon: Icons.home_outlined, path: RoutePaths.dashboard),
        SidebarItemConfig(label: 'Tasks', icon: Icons.assignment_turned_in_outlined, path: RoutePaths.tasks),
        SidebarItemConfig(label: 'Calendar', icon: Icons.calendar_today_outlined, path: RoutePaths.calendar),
        SidebarItemConfig(label: 'Schedule', icon: Icons.schedule_outlined, path: RoutePaths.schedule),
        SidebarItemConfig(label: 'Notifications', icon: Icons.notifications_none_rounded, path: RoutePaths.notifications),
      ],
    ),
    const SidebarSectionConfig(
      title: 'WORKSPACE: DETAILS',
      items: [
        SidebarItemConfig(label: 'Dashboard', icon: Icons.grid_view_rounded, path: RoutePaths.workspaceDashboard),
      ],
    ),
    const SidebarSectionConfig(
      title: 'PEOPLE',
      items: [
        SidebarItemConfig(label: 'Members', icon: Icons.people_outline_rounded, path: RoutePaths.workspaceMembers),
        SidebarItemConfig(label: 'Officers', icon: Icons.badge_outlined, path: RoutePaths.workspaceOfficers),
      ],
    ),
    const SidebarSectionConfig(
      title: 'OPERATIONS',
      items: [
        SidebarItemConfig(label: 'Events', icon: Icons.calendar_month_outlined, path: RoutePaths.workspaceEvents),
        SidebarItemConfig(label: 'Announcements', icon: Icons.campaign_outlined, path: RoutePaths.workspaceAnnouncements),
      ],
    ),
    const SidebarSectionConfig(
      title: 'STUDENT AFFAIRS',
      items: [
        SidebarItemConfig(label: 'Excuse Requests', icon: Icons.note_alt_outlined, path: RoutePaths.workspaceExcuseRequests),
        SidebarItemConfig(label: 'Sanctions', icon: Icons.gavel_rounded, path: RoutePaths.workspaceSanctions),
        SidebarItemConfig(label: 'Activity Clearances', icon: Icons.assignment_outlined, path: RoutePaths.workspaceActivityCards),
      ],
    ),
    const SidebarSectionConfig(
      title: 'FINANCE',
      items: [
        SidebarItemConfig(label: 'Fees', icon: Icons.payments_outlined, path: RoutePaths.workspaceFees),
        SidebarItemConfig(label: 'Collections', icon: Icons.account_balance_wallet_outlined, path: RoutePaths.workspaceCollections),
      ],
    ),
    const SidebarSectionConfig(
      title: 'INSIGHTS',
      items: [
        SidebarItemConfig(label: 'Reports', icon: Icons.bar_chart_rounded, path: RoutePaths.workspaceReports),
      ],
    ),
  ],

  'dean': [
    const SidebarSectionConfig(
      title: 'PERSONAL HUB',
      items: [
        SidebarItemConfig(label: 'Home', icon: Icons.home_outlined, path: RoutePaths.dashboard),
        SidebarItemConfig(label: 'Tasks', icon: Icons.assignment_turned_in_outlined, path: RoutePaths.tasks),
        SidebarItemConfig(label: 'Calendar', icon: Icons.calendar_today_outlined, path: RoutePaths.calendar),
        SidebarItemConfig(label: 'Schedule', icon: Icons.schedule_outlined, path: RoutePaths.schedule),
        SidebarItemConfig(label: 'Notifications', icon: Icons.notifications_none_rounded, path: RoutePaths.notifications),
      ],
    ),
    const SidebarSectionConfig(
      title: 'WORKSPACE: DETAILS',
      items: [
        SidebarItemConfig(label: 'Dashboard', icon: Icons.grid_view_rounded, path: RoutePaths.workspaceDashboard),
      ],
    ),
    const SidebarSectionConfig(
      title: 'ACADEMIC STRUCTURE',
      items: [
        SidebarItemConfig(label: 'Organizations', icon: Icons.corporate_fare_rounded, path: RoutePaths.organizations),
        SidebarItemConfig(label: 'Students', icon: Icons.people_outline_rounded, path: RoutePaths.users),
      ],
    ),
    const SidebarSectionConfig(
      title: 'OPERATIONS',
      items: [
        SidebarItemConfig(label: 'Events', icon: Icons.calendar_month_outlined, path: RoutePaths.workspaceEvents),
      ],
    ),
    const SidebarSectionConfig(
      title: 'STUDENT AFFAIRS',
      items: [
        SidebarItemConfig(label: 'Activity Clearances', icon: Icons.assignment_outlined, path: RoutePaths.workspaceActivityCards),
      ],
    ),
    const SidebarSectionConfig(
      title: 'INSIGHTS',
      items: [
        SidebarItemConfig(label: 'Reports', icon: Icons.bar_chart_rounded, path: RoutePaths.workspaceReports),
      ],
    ),
  ],

  'program_head': [
    const SidebarSectionConfig(
      title: 'PERSONAL HUB',
      items: [
        SidebarItemConfig(label: 'Home', icon: Icons.home_outlined, path: RoutePaths.dashboard),
        SidebarItemConfig(label: 'Tasks', icon: Icons.assignment_turned_in_outlined, path: RoutePaths.tasks),
        SidebarItemConfig(label: 'Calendar', icon: Icons.calendar_today_outlined, path: RoutePaths.calendar),
        SidebarItemConfig(label: 'Schedule', icon: Icons.schedule_outlined, path: RoutePaths.schedule),
        SidebarItemConfig(label: 'Notifications', icon: Icons.notifications_none_rounded, path: RoutePaths.notifications),
      ],
    ),
    const SidebarSectionConfig(
      title: 'WORKSPACE: DETAILS',
      items: [
        SidebarItemConfig(label: 'Dashboard', icon: Icons.grid_view_rounded, path: RoutePaths.workspaceDashboard),
      ],
    ),
    const SidebarSectionConfig(
      title: 'ACADEMIC STRUCTURE',
      items: [
        SidebarItemConfig(label: 'Students', icon: Icons.people_outline_rounded, path: RoutePaths.users),
        SidebarItemConfig(label: 'Organizations', icon: Icons.corporate_fare_rounded, path: RoutePaths.organizations),
      ],
    ),
    const SidebarSectionConfig(
      title: 'OPERATIONS',
      items: [
        SidebarItemConfig(label: 'Events', icon: Icons.calendar_month_outlined, path: RoutePaths.workspaceEvents),
      ],
    ),
    const SidebarSectionConfig(
      title: 'STUDENT AFFAIRS',
      items: [
        SidebarItemConfig(label: 'Activity Clearances', icon: Icons.assignment_outlined, path: RoutePaths.workspaceActivityCards),
      ],
    ),
    const SidebarSectionConfig(
      title: 'INSIGHTS',
      items: [
        SidebarItemConfig(label: 'Reports', icon: Icons.bar_chart_rounded, path: RoutePaths.workspaceReports),
      ],
    ),
  ],
};
