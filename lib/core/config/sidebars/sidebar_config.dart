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
    case 'comselec_chairman':
      return 'comselec_chairman';
    case 'comselec_co_chairman':
      return 'comselec_co_chairman';
    case 'campus_commissioner':
      return 'campus_commissioner';
    case 'faculty_commissioner':
      return 'faculty_commissioner';
    case 'program_commissioner':
      return 'program_commissioner';
    case 'comselec_commissioner':
      return 'comselec_commissioner';
    case 'voter':
      return 'voter';
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
    case 'representative':
      return 'representative';
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
      title: 'GOVERNANCE',
      items: [
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
        SidebarItemConfig(label: 'Collections', icon: Icons.account_balance_wallet_outlined, path: RoutePaths.workspaceCollections),
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
      title: 'OPERATIONS',
      items: [
        SidebarItemConfig(label: 'Announcements', icon: Icons.campaign_outlined, path: RoutePaths.workspaceAnnouncements),
        SidebarItemConfig(label: 'Events', icon: Icons.calendar_month_outlined, path: RoutePaths.workspaceEvents),
      ],
    ),
    const SidebarSectionConfig(
      title: 'GOVERNANCE',
      items: [
        SidebarItemConfig(label: 'Organization Settings', icon: Icons.settings_outlined, path: RoutePaths.workspaceSettings),
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
        SidebarItemConfig(label: 'Collections', icon: Icons.account_balance_wallet_outlined, path: RoutePaths.workspaceCollections),
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
      title: 'GOVERNANCE',
      items: [
        SidebarItemConfig(label: 'Organization Settings', icon: Icons.settings_outlined, path: RoutePaths.workspaceSettings),
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
    const SidebarSectionConfig(
      title: 'GOVERNANCE',
      items: [
        SidebarItemConfig(label: 'Organization Settings', icon: Icons.settings_outlined, path: RoutePaths.workspaceSettings),
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
      title: 'GOVERNANCE',
      items: [
        SidebarItemConfig(label: 'Organization Settings', icon: Icons.settings_outlined, path: RoutePaths.workspaceSettings),
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
      title: 'GOVERNANCE',
      items: [
        SidebarItemConfig(label: 'Organization Settings', icon: Icons.settings_outlined, path: RoutePaths.workspaceSettings),
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
        SidebarItemConfig(label: 'Organization Settings', icon: Icons.settings_outlined, path: RoutePaths.workspaceSettings),
      ],
    ),
    const SidebarSectionConfig(
      title: 'OPERATIONS',
      items: [
        SidebarItemConfig(label: 'Events', icon: Icons.calendar_month_outlined, path: RoutePaths.workspaceEvents),
        SidebarItemConfig(label: 'Announcements', icon: Icons.campaign_outlined, path: RoutePaths.workspaceAnnouncements),
      ],
    ),
  ],

  'representative': [
    const SidebarSectionConfig(
      title: 'PERSONAL HUB',
      items: [
        SidebarItemConfig(label: 'Home', icon: Icons.home_outlined, path: RoutePaths.dashboard),
        SidebarItemConfig(label: 'Tasks', icon: Icons.assignment_turned_in_outlined, path: RoutePaths.tasks),
        SidebarItemConfig(label: 'Calendar', icon: Icons.calendar_today_outlined, path: RoutePaths.calendar),
        SidebarItemConfig(label: 'Schedule', icon: Icons.schedule_outlined, path: RoutePaths.schedule),
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
        SidebarItemConfig(label: 'Excuse Requests', icon: Icons.note_alt_outlined, path: RoutePaths.myExcuseRequests),
      ],
    ),
    const SidebarSectionConfig(
      title: 'STUDENT AFFAIRS',
      items: [
        SidebarItemConfig(label: 'Sanctions', icon: Icons.gavel_rounded, path: RoutePaths.workspaceSanctions),
        SidebarItemConfig(label: 'Activity Clearances', icon: Icons.assignment_outlined, path: RoutePaths.activityCards),
      ],
    ),
    const SidebarSectionConfig(
      title: 'GOVERNANCE',
      items: [
        SidebarItemConfig(label: 'Organization Settings', icon: Icons.settings_outlined, path: RoutePaths.workspaceSettings),
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
        SidebarItemConfig(label: 'Activity Clearances', icon: Icons.assignment_outlined, path: RoutePaths.workspaceActivityCards),
      ],
    ),
    const SidebarSectionConfig(
      title: 'GOVERNANCE',
      items: [
        SidebarItemConfig(label: 'Organization Settings', icon: Icons.settings_outlined, path: RoutePaths.workspaceSettings),
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
      title: 'GOVERNANCE',
      items: [
        SidebarItemConfig(label: 'Organization Settings', icon: Icons.settings_outlined, path: RoutePaths.workspaceSettings),
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
  ],

  'program_head': [
    const SidebarSectionConfig(
      title: 'PERSONAL HUB',
      items: [
        SidebarItemConfig(label: 'Home', icon: Icons.home_outlined, path: RoutePaths.dashboard),
        SidebarItemConfig(label: 'Tasks', icon: Icons.assignment_turned_in_outlined, path: RoutePaths.tasks),
        SidebarItemConfig(label: 'Calendar', icon: Icons.calendar_today_outlined, path: RoutePaths.calendar),
        SidebarItemConfig(label: 'Schedule', icon: Icons.schedule_outlined, path: RoutePaths.schedule),
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
  ],

  'comselec_chairman': [
    const SidebarSectionConfig(
      title: 'PERSONAL HUB',
      items: [
        SidebarItemConfig(label: 'Home', icon: Icons.home_outlined, path: RoutePaths.dashboard),
        SidebarItemConfig(label: 'Tasks', icon: Icons.assignment_turned_in_outlined, path: RoutePaths.tasks),
        SidebarItemConfig(label: 'Calendar', icon: Icons.calendar_today_outlined, path: RoutePaths.calendar),
        SidebarItemConfig(label: 'Schedule', icon: Icons.schedule_outlined, path: RoutePaths.schedule),
      ],
    ),
    const SidebarSectionConfig(
      title: 'WORKSPACE',
      items: [
        SidebarItemConfig(label: 'COMSELEC Dashboard', icon: Icons.dashboard_rounded, path: RoutePaths.comselecDashboard),
      ],
    ),
    const SidebarSectionConfig(
      title: 'ELECTION MANAGEMENT',
      items: [
        SidebarItemConfig(label: 'Elections', icon: Icons.how_to_vote_rounded, path: RoutePaths.comselecElections),
        SidebarItemConfig(label: 'Election Positions', icon: Icons.badge_outlined, path: RoutePaths.comselecPositions),
        SidebarItemConfig(label: 'Candidates', icon: Icons.people_outline_rounded, path: RoutePaths.comselecCandidates),
        SidebarItemConfig(label: 'Voter Eligibility', icon: Icons.verified_user_outlined, path: RoutePaths.comselecVoters),
        SidebarItemConfig(label: 'Voting Monitoring', icon: Icons.monitor_heart_outlined, path: RoutePaths.comselecMonitoring),
        SidebarItemConfig(label: 'Election Results', icon: Icons.assessment_outlined, path: RoutePaths.comselecResults),
      ],
    ),
    const SidebarSectionConfig(
      title: 'COMMISSION MANAGEMENT',
      items: [
        SidebarItemConfig(label: 'Commissioners', icon: Icons.group_work_outlined, path: RoutePaths.comselecOfficials),
        SidebarItemConfig(label: 'Role Permissions', icon: Icons.security_outlined, path: RoutePaths.settings),
      ],
    ),
    const SidebarSectionConfig(
      title: 'OPERATIONS',
      items: [
        SidebarItemConfig(label: 'Offline Voting Sessions', icon: Icons.edgesensor_high_outlined, path: RoutePaths.comselecOfflineVoting),
        SidebarItemConfig(label: 'Announcements', icon: Icons.campaign_outlined, path: RoutePaths.announcements),
        SidebarItemConfig(label: 'Election Guidelines', icon: Icons.description_outlined, path: RoutePaths.comselecGuidelines),
        SidebarItemConfig(label: 'Incident Log', icon: Icons.report_problem_outlined, path: RoutePaths.comselecIncidents),
        SidebarItemConfig(label: 'Audit Logs', icon: Icons.receipt_long_outlined, path: RoutePaths.workspaceAuditLogs),
      ],
    ),
  ],

  'comselec_co_chairman': [
    const SidebarSectionConfig(
      title: 'PERSONAL HUB',
      items: [
        SidebarItemConfig(label: 'Home', icon: Icons.home_outlined, path: RoutePaths.dashboard),
        SidebarItemConfig(label: 'Tasks', icon: Icons.assignment_turned_in_outlined, path: RoutePaths.tasks),
        SidebarItemConfig(label: 'Calendar', icon: Icons.calendar_today_outlined, path: RoutePaths.calendar),
        SidebarItemConfig(label: 'Schedule', icon: Icons.schedule_outlined, path: RoutePaths.schedule),
      ],
    ),
    const SidebarSectionConfig(
      title: 'WORKSPACE',
      items: [
        SidebarItemConfig(label: 'COMSELEC Dashboard', icon: Icons.dashboard_rounded, path: RoutePaths.comselecDashboard),
      ],
    ),
    const SidebarSectionConfig(
      title: 'ELECTION MANAGEMENT',
      items: [
        SidebarItemConfig(label: 'Elections', icon: Icons.how_to_vote_rounded, path: RoutePaths.comselecElections),
        SidebarItemConfig(label: 'Election Positions', icon: Icons.badge_outlined, path: RoutePaths.comselecPositions),
        SidebarItemConfig(label: 'Candidates', icon: Icons.people_outline_rounded, path: RoutePaths.comselecCandidates),
        SidebarItemConfig(label: 'Voter Eligibility', icon: Icons.verified_user_outlined, path: RoutePaths.comselecVoters),
        SidebarItemConfig(label: 'Voting Monitoring', icon: Icons.monitor_heart_outlined, path: RoutePaths.comselecMonitoring),
        SidebarItemConfig(label: 'Election Results', icon: Icons.assessment_outlined, path: RoutePaths.comselecResults),
      ],
    ),
    const SidebarSectionConfig(
      title: 'COMMISSION MANAGEMENT',
      items: [
        SidebarItemConfig(label: 'Commissioners', icon: Icons.group_work_outlined, path: RoutePaths.comselecOfficials),
      ],
    ),
    const SidebarSectionConfig(
      title: 'OPERATIONS',
      items: [
        SidebarItemConfig(label: 'Offline Voting Sessions', icon: Icons.edgesensor_high_outlined, path: RoutePaths.comselecOfflineVoting),
        SidebarItemConfig(label: 'Announcements', icon: Icons.campaign_outlined, path: RoutePaths.announcements),
        SidebarItemConfig(label: 'Election Guidelines', icon: Icons.description_outlined, path: RoutePaths.comselecGuidelines),
      ],
    ),
  ],

  'faculty_commissioner': [
    const SidebarSectionConfig(
      title: 'PERSONAL HUB',
      items: [
        SidebarItemConfig(label: 'Home', icon: Icons.home_outlined, path: RoutePaths.dashboard),
        SidebarItemConfig(label: 'Tasks', icon: Icons.assignment_turned_in_outlined, path: RoutePaths.tasks),
        SidebarItemConfig(label: 'Calendar', icon: Icons.calendar_today_outlined, path: RoutePaths.calendar),
        SidebarItemConfig(label: 'Schedule', icon: Icons.schedule_outlined, path: RoutePaths.schedule),
      ],
    ),
    const SidebarSectionConfig(
      title: 'WORKSPACE',
      items: [
        SidebarItemConfig(label: 'Dashboard', icon: Icons.grid_view_rounded, path: RoutePaths.comselecDashboard),
      ],
    ),
    const SidebarSectionConfig(
      title: 'FACULTY ELECTIONS',
      items: [
        SidebarItemConfig(label: 'Faculty Elections', icon: Icons.how_to_vote_rounded, path: RoutePaths.comselecElections),
        SidebarItemConfig(label: 'Faculty Positions', icon: Icons.badge_outlined, path: RoutePaths.comselecPositions),
        SidebarItemConfig(label: 'Candidates', icon: Icons.people_outline_rounded, path: RoutePaths.comselecCandidates),
        SidebarItemConfig(label: 'Voter Eligibility', icon: Icons.verified_user_outlined, path: RoutePaths.comselecVoters),
      ],
    ),
    const SidebarSectionConfig(
      title: 'OPERATIONS',
      items: [
        SidebarItemConfig(label: 'Offline Voting Sessions', icon: Icons.edgesensor_high_outlined, path: RoutePaths.comselecOfflineVoting),
        SidebarItemConfig(label: 'Voting Monitoring', icon: Icons.monitor_heart_outlined, path: RoutePaths.comselecMonitoring),
        SidebarItemConfig(label: 'Announcements', icon: Icons.campaign_outlined, path: RoutePaths.announcements),
        SidebarItemConfig(label: 'Election Guidelines', icon: Icons.description_outlined, path: RoutePaths.comselecGuidelines),
      ],
    ),
  ],

  'program_commissioner': [
    const SidebarSectionConfig(
      title: 'PERSONAL HUB',
      items: [
        SidebarItemConfig(label: 'Home', icon: Icons.home_outlined, path: RoutePaths.dashboard),
        SidebarItemConfig(label: 'Tasks', icon: Icons.assignment_turned_in_outlined, path: RoutePaths.tasks),
        SidebarItemConfig(label: 'Calendar', icon: Icons.calendar_today_outlined, path: RoutePaths.calendar),
        SidebarItemConfig(label: 'Schedule', icon: Icons.schedule_outlined, path: RoutePaths.schedule),
      ],
    ),
    const SidebarSectionConfig(
      title: 'WORKSPACE',
      items: [
        SidebarItemConfig(label: 'Dashboard', icon: Icons.grid_view_rounded, path: RoutePaths.comselecDashboard),
      ],
    ),
    const SidebarSectionConfig(
      title: 'PROGRAM ELECTIONS',
      items: [
        SidebarItemConfig(label: 'Program Elections', icon: Icons.how_to_vote_rounded, path: RoutePaths.comselecElections),
        SidebarItemConfig(label: 'Program Positions', icon: Icons.badge_outlined, path: RoutePaths.comselecPositions),
        SidebarItemConfig(label: 'Candidates', icon: Icons.people_outline_rounded, path: RoutePaths.comselecCandidates),
        SidebarItemConfig(label: 'Eligible Voters', icon: Icons.verified_user_outlined, path: RoutePaths.comselecVoters),
      ],
    ),
    const SidebarSectionConfig(
      title: 'OPERATIONS',
      items: [
        SidebarItemConfig(label: 'Offline Voting Sessions', icon: Icons.edgesensor_high_outlined, path: RoutePaths.comselecOfflineVoting),
        SidebarItemConfig(label: 'Voting Monitoring', icon: Icons.monitor_heart_outlined, path: RoutePaths.comselecMonitoring),
        SidebarItemConfig(label: 'Announcements', icon: Icons.campaign_outlined, path: RoutePaths.announcements),
        SidebarItemConfig(label: 'Election Guidelines', icon: Icons.description_outlined, path: RoutePaths.comselecGuidelines),
      ],
    ),
  ],

  'voter': [
    const SidebarSectionConfig(
      title: 'PERSONAL HUB',
      items: [
        SidebarItemConfig(label: 'Home', icon: Icons.home_outlined, path: RoutePaths.dashboard),
        SidebarItemConfig(label: 'Tasks', icon: Icons.assignment_turned_in_outlined, path: RoutePaths.tasks),
        SidebarItemConfig(label: 'Calendar', icon: Icons.calendar_today_outlined, path: RoutePaths.calendar),
        SidebarItemConfig(label: 'Schedule', icon: Icons.schedule_outlined, path: RoutePaths.schedule),
      ],
    ),
    const SidebarSectionConfig(
      title: 'COMSELEC',
      items: [
        SidebarItemConfig(label: 'Dashboard', icon: Icons.grid_view_rounded, path: RoutePaths.comselecDashboard),
        SidebarItemConfig(label: 'Active Elections', icon: Icons.how_to_vote_rounded, path: RoutePaths.comselecElections),
        SidebarItemConfig(label: 'My Eligibility', icon: Icons.verified_user_outlined, path: RoutePaths.comselecMyEligibility),
        SidebarItemConfig(label: 'Candidates', icon: Icons.groups_outlined, path: RoutePaths.comselecCandidates),
        SidebarItemConfig(label: 'Voting', icon: Icons.how_to_vote_sharp, path: RoutePaths.comselecVoting),
        SidebarItemConfig(label: 'My Voting Status', icon: Icons.fact_check_outlined, path: RoutePaths.comselecMyStatus),
      ],
    ),
    const SidebarSectionConfig(
      title: 'INFORMATION',
      items: [
        SidebarItemConfig(label: 'Announcements', icon: Icons.campaign_outlined, path: RoutePaths.announcements),
        SidebarItemConfig(label: 'Election Guidelines', icon: Icons.description_outlined, path: RoutePaths.comselecGuidelines),
        SidebarItemConfig(label: 'Election Schedule', icon: Icons.event_note_outlined, path: RoutePaths.schedule),
      ],
    ),
  ],
};
