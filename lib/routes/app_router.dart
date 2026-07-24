import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'route_names.dart';
import 'route_paths.dart';
import '../features/auth/views/login_page.dart';
import '../features/auth/views/register_page.dart';
import '../features/auth/views/email_verification_page.dart';
import '../features/auth/views/forgot_password_page.dart';
import '../features/auth/views/change_email_page.dart';
import '../features/auth/views/change_password_page.dart';
import '../features/auth/views/splash_page.dart';
import '../features/dashboard/views/dashboard_page.dart';
import '../features/dashboard/views/calendar_page.dart';
import '../features/dashboard/views/workspace_dashboard_page.dart';
import '../features/tasks/views/tasks_page.dart';
import '../features/schedule/views/schedule_page.dart';
import '../features/activity_cards/views/activity_card_redirector.dart';
import '../features/activity_cards/views/activity_card_details_page.dart';
import '../features/organizations/views/organizations_page.dart';
import '../features/organizations/views/organization_details_page.dart';
import '../features/elections/views/comselecs_manager_page.dart';
import '../features/campuses/views/campuses_page.dart';
import '../features/campuses/views/campus_details_page.dart';
import '../features/faculties/views/faculties_page.dart';
import '../features/faculties/views/faculty_details_page.dart';
import '../features/programs/views/programs_page.dart';
import '../features/programs/views/program_details_page.dart';
import '../features/users/views/users_page.dart';
import '../features/users/views/officers_page.dart';
import '../features/users/views/user_profile_page.dart';
import '../features/profile/views/my_qr_code_page.dart';
import '../features/profile/views/manage_account_page.dart';
import '../features/users/views/account_deletion_requests_page.dart';
import '../features/profile/views/about_us_page.dart';
import '../features/profile/views/help_support_page.dart';
import '../features/elections/views/comselec_dashboard_page.dart';
import '../features/elections/views/elections_page.dart';
import '../features/candidates/views/candidates_page.dart';
import '../features/voters/views/voters_page.dart';
import '../features/elections/views/election_results_page.dart';
import '../features/elections/views/election_analytics_page.dart';
import '../features/elections/views/comselec_officials_page.dart';
import '../features/academic_structure/views/academic_structure_page.dart';
import '../features/dashboard/views/governor_module_placeholder.dart';
import '../features/governor/views/governor_events_page.dart';
import '../features/governor/views/governor_create_event_page.dart';
import '../features/governor/views/governor_announcements_page.dart';
import '../features/governor/views/governor_create_announcement_page.dart';
import '../features/announcements/models/announcement_model.dart';
import '../features/governor/views/governor_finance_page.dart';
import '../features/governor/views/governor_members_page.dart';
import '../features/governor/views/governor_officers_page.dart';
import '../features/governor/views/governor_collections_page.dart';
import '../features/governor/views/governor_fee_report_page.dart';
import '../features/finance/models/fee_model.dart';
import '../features/governor/views/governor_settings_page.dart';
import '../features/governor/views/governor_gallery_page.dart';
import '../features/governor/views/activity_cards/governor_activity_cards_page.dart';
import '../features/governor/views/activity_cards/governor_activity_card_review_page.dart';
import '../features/excuse_requests/views/workspace_excuse_requests_page.dart';
import '../features/excuse_requests/views/my_excuse_requests_page.dart';
import '../features/excuse_requests/views/workspace_excuse_request_review_page.dart';
import '../features/sanctions/views/sanction_redirector.dart';
import '../features/sanctions/views/sanction_profile_page.dart';
import '../features/sanctions/views/workspace_create_sanction_rule_page.dart';
import '../features/sanctions/views/workspace_edit_sanction_rule_page.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/organizations/providers/workspace_provider.dart';
import '../core/utils/role_mapper.dart';

/// A notifier that notifies the [GoRouter] when the authentication state 
/// or workspace state changes.
class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen(authStateProvider, (_, __) => notifyListeners());
    _ref.listen(workspaceProvider, (_, __) => notifyListeners());
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);
  
  return GoRouter(
    initialLocation: RoutePaths.splash,
    debugLogDiagnostics: true,
    refreshListenable: notifier,
    redirect: (context, state) {
      final authAsync = ref.read(authStateProvider);
      
      // Wait for auth to initialize
      if (authAsync.isLoading) return null;

      final auth = authAsync.value;

      // Allow the splash screen to play its full animation on startup
      if (state.matchedLocation == RoutePaths.splash) {
        return null;
      }

      final loggingIn = state.matchedLocation == RoutePaths.login ||
          state.matchedLocation == RoutePaths.register ||
          state.matchedLocation == RoutePaths.forgotPassword ||
          state.matchedLocation == RoutePaths.emailVerification;

      if (auth?.session == null) {
        return loggingIn ? null : RoutePaths.login;
      }

      // Check if email is confirmed
      final user = auth?.session?.user;
      if (user != null && user.emailConfirmedAt == null) {
        if (state.matchedLocation != RoutePaths.emailVerification) {
          return '${RoutePaths.emailVerification}?email=${user.email}';
        }
        return null;
      }

      if (loggingIn) {
        if (state.matchedLocation == RoutePaths.forgotPassword) {
          return null;
        }
        return RoutePaths.dashboard;
      }

      // Get user profile and workspace state
      final userProfileAsync = ref.read(userProfileProvider);
      final userProfile = userProfileAsync.value;
      final workspace = ref.read(workspaceProvider);

      final isSuperAdmin = userProfile?.role == 'super_admin';
      final location = state.matchedLocation;

      // Helper to check prefix or exact match with params
      bool matchesAny(String loc, List<String> paths) {
        return paths.any((path) {
          if (path.contains('/:')) {
            final regexStr = '^${path.replaceAll(RegExp(r'/:[a-zA-Z0-9_]+'), '/[^/]+')}\$';
            return RegExp(regexStr).hasMatch(loc);
          }
          return loc == path;
        });
      }

      // 1. Super Admin/System Admin protection
      final superAdminRoutes = [
        RoutePaths.comselecsManager,
        RoutePaths.academicStructure,
        RoutePaths.campuses,
        RoutePaths.campusDetails,
        RoutePaths.faculties,
        RoutePaths.facultyDetails,
        RoutePaths.programs,
        RoutePaths.programDetails,
        RoutePaths.accountDeletionRequests,
      ];

      if (matchesAny(location, superAdminRoutes) && !isSuperAdmin) {
        return RoutePaths.dashboard;
      }

      // 2. User/Student list & Organizations protection (accessible by Super Admin, Dean, and Program Head)
      final activeRoleName = workspace.activeRole?.roleName;
      final normalizedActiveRole = activeRoleName != null ? RoleMapper.mapDbRoleToAppFormat(activeRoleName) : '';
      final isDean = normalizedActiveRole == 'dean';
      final isProgramHead = normalizedActiveRole == 'program_head';
      final adminAndAcademicRoutes = [
        RoutePaths.users,
        RoutePaths.officers,
        RoutePaths.userDetails,
        RoutePaths.organizations,
        RoutePaths.organizationDetails,
      ];

      if (matchesAny(location, adminAndAcademicRoutes)) {
        if (!isSuperAdmin && !isDean && !isProgramHead) {
          return RoutePaths.dashboard;
        }
      }

      // 3. Comselec protection
      // Paths starting with /comselec can only be accessed by Super Admin OR when comselec workspace is selected
      if (location.startsWith('/comselec')) {
        final isComselecWorkspace = workspace.selectedOrganization?.type == 'comselec';
        if (!isSuperAdmin && !isComselecWorkspace) {
          return RoutePaths.dashboard;
        }
      }

      // 4. Workspace routes protection
      if (location.startsWith('/workspace')) {
        // Wait for workspace to initialize from persistence
        if (!workspace.isInitialized) return null;

        if (workspace.selectedOrganization == null) {
          return RoutePaths.dashboard;
        }

        final roleName = workspace.activeRole?.roleName;
        final normalizedRole = roleName != null ? RoleMapper.mapDbRoleToAppFormat(roleName) : 'member';
        final isMemberOrStudent = normalizedRole == 'student' || normalizedRole == 'member';

        // Redirect member/student role from officer workspace excuse requests page to student's myExcuseRequests page
        if (location == RoutePaths.workspaceExcuseRequests && isMemberOrStudent) {
          return RoutePaths.myExcuseRequests;
        }

        // If the user is a Member or Student, block them from all other officer-only workspace screens
        if (isMemberOrStudent) {
          final allowedMemberWorkspaceRoutes = [
            RoutePaths.workspaceDashboard,
            RoutePaths.workspaceEvents,
            RoutePaths.workspaceAnnouncements,
            RoutePaths.myExcuseRequests,
            RoutePaths.workspaceSanctions,
            RoutePaths.workspaceFees,
            RoutePaths.workspaceSettings,
          ];

          if (!matchesAny(location, allowedMemberWorkspaceRoutes)) {
            return RoutePaths.workspaceDashboard;
          }
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: RoutePaths.login,
        name: RouteNames.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: RoutePaths.register,
        name: RouteNames.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: RoutePaths.forgotPassword,
        name: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: RoutePaths.changeEmail,
        name: RouteNames.changeEmail,
        builder: (context, state) => const ChangeEmailPage(),
      ),
      GoRoute(
        path: RoutePaths.changePassword,
        name: RouteNames.changePassword,
        builder: (context, state) => const ChangePasswordPage(),
      ),
      GoRoute(
        path: RoutePaths.emailVerification,
        name: RouteNames.emailVerification,
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return EmailVerificationPage(email: email);
        },
      ),
      GoRoute(
        path: RoutePaths.dashboard,
        name: RouteNames.dashboard,
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: RoutePaths.calendar,
        name: RouteNames.calendar,
        builder: (context, state) => const CalendarPage(),
      ),
      GoRoute(
        path: RoutePaths.events,
        name: RouteNames.events,
        builder: (context, state) => const GovernorModulePlaceholder(title: 'My Events'),
      ),
      GoRoute(
        path: RoutePaths.fees,
        name: RouteNames.fees,
        builder: (context, state) => const GovernorModulePlaceholder(title: 'My Fees'),
      ),
      GoRoute(
        path: RoutePaths.notifications,
        name: RouteNames.notifications,
        builder: (context, state) => const GovernorModulePlaceholder(title: 'Notifications'),
      ),
      GoRoute(
        path: RoutePaths.activityCards,
        name: RouteNames.activityCards,
        builder: (context, state) => const ActivityCardRedirector(),
      ),
      GoRoute(
        path: RoutePaths.activityCardDetails,
        name: RouteNames.activityCardDetails,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ActivityCardDetailsPage(id: id);
        },
      ),
      GoRoute(
        path: RoutePaths.profile,
        name: RouteNames.profile,
        builder: (context, state) => const ManageAccountPage(),
      ),
      GoRoute(
        path: RoutePaths.myQrCode,
        name: RouteNames.myQrCode,
        builder: (context, state) => const MyQrCodePage(),
      ),
      GoRoute(
        path: RoutePaths.aboutUs,
        name: RouteNames.aboutUs,
        builder: (context, state) => const AboutUsPage(),
      ),
      GoRoute(
        path: RoutePaths.help,
        name: RouteNames.help,
        builder: (context, state) => const HelpSupportPage(),
      ),
      GoRoute(
        path: RoutePaths.settings,
        name: RouteNames.settings,
        builder: (context, state) => const GovernorModulePlaceholder(title: 'Settings'),
      ),
      GoRoute(
        path: RoutePaths.academicStructure,
        name: RouteNames.academicStructure,
        builder: (context, state) => const AcademicStructurePage(),
      ),
      GoRoute(
        path: RoutePaths.organizations,
        name: RouteNames.organizations,
        builder: (context, state) => const OrganizationsPage(),
      ),
      GoRoute(
        path: RoutePaths.comselecsManager,
        name: RouteNames.comselecsManager,
        builder: (context, state) => const ComselecsManagerPage(),
      ),
      GoRoute(
        path: RoutePaths.organizationDetails,
        name: RouteNames.organizationDetails,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return OrganizationDetailsPage(id: id);
        },
      ),
      GoRoute(
        path: RoutePaths.campuses,
        name: RouteNames.campuses,
        builder: (context, state) => const CampusesPage(),
      ),
      GoRoute(
        path: RoutePaths.campusDetails,
        name: RouteNames.campusDetails,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return CampusDetailsPage(id: id);
        },
      ),
      GoRoute(
        path: RoutePaths.faculties,
        name: RouteNames.faculties,
        builder: (context, state) => const FacultiesPage(),
      ),
      GoRoute(
        path: RoutePaths.facultyDetails,
        name: RouteNames.facultyDetails,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return FacultyDetailsPage(id: id);
        },
      ),
      GoRoute(
        path: RoutePaths.programs,
        name: RouteNames.programs,
        builder: (context, state) => const ProgramsPage(),
      ),
      GoRoute(
        path: RoutePaths.programDetails,
        name: RouteNames.programDetails,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ProgramDetailsPage(id: id);
        },
      ),
      GoRoute(
        path: RoutePaths.users,
        name: RouteNames.users,
        builder: (context, state) => const UsersPage(),
      ),
      GoRoute(
        path: RoutePaths.accountDeletionRequests,
        name: RouteNames.accountDeletionRequests,
        builder: (context, state) => const AccountDeletionRequestsPage(),
      ),
      GoRoute(
        path: RoutePaths.officers,
        name: RouteNames.officers,
        builder: (context, state) => const OfficersPage(),
      ),
      GoRoute(
        path: RoutePaths.userDetails,
        name: RouteNames.userDetails,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return UserProfilePage(id: id);
        },
      ),
      GoRoute(
        path: RoutePaths.comselecDashboard,
        name: RouteNames.comselecDashboard,
        builder: (context, state) => const ComselecDashboardPage(),
      ),
      GoRoute(
        path: RoutePaths.comselecElections,
        name: RouteNames.comselecElections,
        builder: (context, state) => const ElectionsPage(),
      ),
      GoRoute(
        path: RoutePaths.comselecCandidates,
        name: RouteNames.comselecCandidates,
        builder: (context, state) => const CandidatesPage(),
      ),
      GoRoute(
        path: RoutePaths.comselecVoters,
        name: RouteNames.comselecVoters,
        builder: (context, state) => const VotersPage(),
      ),
      GoRoute(
        path: RoutePaths.comselecResults,
        name: RouteNames.comselecResults,
        builder: (context, state) => const ElectionResultsPage(),
      ),
      GoRoute(
        path: RoutePaths.comselecAnalytics,
        name: RouteNames.comselecAnalytics,
        builder: (context, state) => const ElectionAnalyticsPage(),
      ),
      GoRoute(
        path: RoutePaths.comselecOfficials,
        name: RouteNames.comselecOfficials,
        builder: (context, state) => const ComselecOfficialsPage(),
      ),

      // Workspace Routes
      GoRoute(
        path: RoutePaths.workspaceDashboard,
        name: RouteNames.workspaceDashboard,
        builder: (context, state) => const WorkspaceDashboardPage(),
      ),
      GoRoute(
        path: RoutePaths.workspaceMembers,
        name: RouteNames.workspaceMembers,
        builder: (context, state) => const GovernorMembersPage(),
      ),
      GoRoute(
        path: RoutePaths.workspaceOfficers,
        name: RouteNames.workspaceOfficers,
        builder: (context, state) => const GovernorOfficersPage(),
      ),
      GoRoute(
        path: RoutePaths.workspaceEvents,
        name: RouteNames.workspaceEvents,
        builder: (context, state) => const GovernorEventsPage(),
      ),
      GoRoute(
        path: RoutePaths.workspaceCreateEvent,
        name: 'workspaceCreateEvent',
        builder: (context, state) => const GovernorCreateEventPage(),
      ),
      GoRoute(
        path: RoutePaths.workspaceAttendance,
        name: RouteNames.workspaceAttendance,
        builder: (context, state) => const GovernorModulePlaceholder(title: 'Organization Attendance'),
      ),
      GoRoute(
        path: RoutePaths.workspaceAnnouncements,
        name: RouteNames.workspaceAnnouncements,
        builder: (context, state) => const GovernorAnnouncementsPage(),
      ),
      GoRoute(
        path: RoutePaths.workspaceCreateAnnouncement,
        name: RouteNames.workspaceCreateAnnouncement,
        builder: (context, state) {
          final announcement = state.extra as AnnouncementModel?;
          return GovernorCreateAnnouncementPage(initialData: announcement);
        },
      ),
      GoRoute(
        path: RoutePaths.workspaceDocuments,
        name: RouteNames.workspaceDocuments,
        builder: (context, state) => const GovernorModulePlaceholder(title: 'Organization Documents'),
      ),
      GoRoute(
        path: RoutePaths.workspaceFees,
        name: RouteNames.workspaceFees,
        builder: (context, state) => const GovernorFinancePage(),
      ),
      GoRoute(
        path: RoutePaths.workspaceCollections,
        name: RouteNames.workspaceCollections,
        builder: (context, state) => const GovernorCollectionsPage(),
      ),
      GoRoute(
        path: RoutePaths.workspaceCollectionsReport,
        name: RouteNames.workspaceCollectionsReport,
        builder: (context, state) {
          final fee = state.extra as FeeModel;
          return GovernorFeeReportPage(fee: fee);
        },
      ),
      GoRoute(
        path: RoutePaths.workspaceFinanceReports,
        name: RouteNames.workspaceFinanceReports,
        builder: (context, state) => const GovernorModulePlaceholder(title: 'Organization Financial Reports'),
      ),
      GoRoute(
        path: RoutePaths.workspaceElections,
        name: RouteNames.workspaceElections,
        builder: (context, state) => const GovernorModulePlaceholder(title: 'Organization Elections'),
      ),
      GoRoute(
        path: RoutePaths.workspaceCompliance,
        name: RouteNames.workspaceCompliance,
        builder: (context, state) => const GovernorModulePlaceholder(title: 'Organization Compliance'),
      ),
      GoRoute(
        path: RoutePaths.workspaceSanctions,
        name: RouteNames.workspaceSanctions,
        builder: (context, state) => const SanctionRedirector(),
      ),
      GoRoute(
        path: RoutePaths.workspaceSanctionProfile,
        name: RouteNames.workspaceSanctionProfile,
        builder: (context, state) {
          final studentId = state.pathParameters['studentId']!;
          return SanctionProfilePage(studentId: studentId);
        },
      ),
      GoRoute(
        path: RoutePaths.workspaceCreateSanctionRule,
        name: RouteNames.workspaceCreateSanctionRule,
        builder: (context, state) => const WorkspaceCreateSanctionRulePage(),
      ),
      GoRoute(
        path: RoutePaths.workspaceEditSanctionRule,
        name: RouteNames.workspaceEditSanctionRule,
        builder: (context, state) {
          final rule = state.extra as Map<String, dynamic>;
          return WorkspaceEditSanctionRulePage(rule: rule);
        },
      ),
      GoRoute(
        path: RoutePaths.workspaceParticipation,
        name: RouteNames.workspaceParticipation,
        builder: (context, state) => const GovernorModulePlaceholder(title: 'Participation Analytics'),
      ),
      GoRoute(
        path: RoutePaths.workspaceAttendanceAnalytics,
        name: RouteNames.workspaceAttendanceAnalytics,
        builder: (context, state) => const GovernorModulePlaceholder(title: 'Attendance Analytics'),
      ),
      GoRoute(
        path: RoutePaths.workspaceFinancialAnalytics,
        name: RouteNames.workspaceFinancialAnalytics,
        builder: (context, state) => const GovernorModulePlaceholder(title: 'Financial Analytics'),
      ),
      GoRoute(
        path: RoutePaths.workspaceActivityCards,
        name: RouteNames.workspaceActivityCards,
        builder: (context, state) => const GovernorActivityCardsPage(),
      ),
      GoRoute(
        path: RoutePaths.workspaceActivityCardDetails,
        name: RouteNames.workspaceActivityCardDetails,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return GovernorActivityCardReviewPage(id: id);
        },
      ),
      GoRoute(
        path: RoutePaths.workspaceSettings,
        name: RouteNames.workspaceSettings,
        builder: (context, state) => const GovernorSettingsPage(),
      ),
      GoRoute(
        path: RoutePaths.tasks,
        name: RouteNames.tasks,
        builder: (context, state) => const TasksPage(),
      ),
      GoRoute(
        path: RoutePaths.schedule,
        name: RouteNames.schedule,
        builder: (context, state) => const SchedulePage(),
      ),
      GoRoute(
        path: RoutePaths.workspaceExcuseRequests,
        name: RouteNames.workspaceExcuseRequests,
        builder: (context, state) => const WorkspaceExcuseRequestsPage(),
      ),
      GoRoute(
        path: RoutePaths.workspaceExcuseRequestReview,
        name: RouteNames.workspaceExcuseRequestReview,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return WorkspaceExcuseRequestReviewPage(id: id);
        },
      ),
      GoRoute(
        path: RoutePaths.myExcuseRequests,
        name: RouteNames.myExcuseRequests,
        builder: (context, state) => const MyExcuseRequestsPage(),
      ),
      GoRoute(
        path: RoutePaths.workspaceOfficerAppointments,
        name: RouteNames.workspaceOfficerAppointments,
        builder: (context, state) => const GovernorModulePlaceholder(title: 'Officer Appointments'),
      ),
      GoRoute(
        path: RoutePaths.workspaceCollectionsAudit,
        name: RouteNames.workspaceCollectionsAudit,
        builder: (context, state) => const GovernorModulePlaceholder(title: 'Collections Audit'),
      ),
      GoRoute(
        path: RoutePaths.workspaceAuditLogs,
        name: RouteNames.workspaceAuditLogs,
        builder: (context, state) => const GovernorModulePlaceholder(title: 'Audit Logs'),
      ),
      GoRoute(
        path: RoutePaths.workspaceAuditReports,
        name: RouteNames.workspaceAuditReports,
        builder: (context, state) => const GovernorModulePlaceholder(title: 'Audit Reports'),
      ),
      GoRoute(
        path: RoutePaths.workspaceAuditAnalytics,
        name: RouteNames.workspaceAuditAnalytics,
        builder: (context, state) => const GovernorModulePlaceholder(title: 'Audit Analytics'),
      ),
      GoRoute(
        path: RoutePaths.workspacePublications,
        name: RouteNames.workspacePublications,
        builder: (context, state) => const GovernorModulePlaceholder(title: 'Publications'),
      ),
      GoRoute(
        path: RoutePaths.workspaceGallery,
        name: RouteNames.workspaceGallery,
        builder: (context, state) => const GovernorGalleryPage(),
      ),
      GoRoute(
        path: RoutePaths.workspaceEngagementReports,
        name: RouteNames.workspaceEngagementReports,
        builder: (context, state) => const GovernorModulePlaceholder(title: 'Engagement Reports'),
      ),
      GoRoute(
        path: RoutePaths.workspaceMeetingMinutes,
        name: RouteNames.workspaceMeetingMinutes,
        builder: (context, state) => const GovernorModulePlaceholder(title: 'Meeting Minutes'),
      ),
      GoRoute(
        path: RoutePaths.workspaceAttendanceReports,
        name: RouteNames.workspaceAttendanceReports,
        builder: (context, state) => const GovernorModulePlaceholder(title: 'Attendance Reports'),
      ),
      GoRoute(
        path: RoutePaths.workspaceProposals,
        name: RouteNames.workspaceProposals,
        builder: (context, state) => const GovernorModulePlaceholder(title: 'Proposals'),
      ),
      GoRoute(
        path: RoutePaths.workspaceVoting,
        name: RouteNames.workspaceVoting,
        builder: (context, state) => const GovernorModulePlaceholder(title: 'Voting'),
      ),
      GoRoute(
        path: RoutePaths.workspaceResolutions,
        name: RouteNames.workspaceResolutions,
        builder: (context, state) => const GovernorModulePlaceholder(title: 'Resolutions'),
      ),
      GoRoute(
        path: RoutePaths.workspaceGovernanceReports,
        name: RouteNames.workspaceGovernanceReports,
        builder: (context, state) => const GovernorModulePlaceholder(title: 'Governance Reports'),
      ),
      GoRoute(
        path: RoutePaths.workspaceCollectionAnalytics,
        name: RouteNames.workspaceCollectionAnalytics,
        builder: (context, state) => const GovernorModulePlaceholder(title: 'Collection Analytics'),
      ),
      GoRoute(
        path: RoutePaths.workspaceReports,
        name: RouteNames.workspaceReports,
        builder: (context, state) => const GovernorModulePlaceholder(title: 'Reports'),
      ),
      GoRoute(
        path: RoutePaths.workspaceProjects,
        name: RouteNames.workspaceProjects,
        builder: (context, state) => const GovernorModulePlaceholder(title: 'Projects'),
      ),
      GoRoute(
        path: RoutePaths.workspaceSales,
        name: RouteNames.workspaceSales,
        builder: (context, state) => const GovernorModulePlaceholder(title: 'Sales'),
      ),
      GoRoute(
        path: RoutePaths.workspaceInventory,
        name: RouteNames.workspaceInventory,
        builder: (context, state) => const GovernorModulePlaceholder(title: 'Inventory'),
      ),
      GoRoute(
        path: RoutePaths.workspaceSponsors,
        name: RouteNames.workspaceSponsors,
        builder: (context, state) => const GovernorModulePlaceholder(title: 'Sponsors & Partners'),
      ),
      GoRoute(
        path: RoutePaths.workspaceFinancialRequests,
        name: RouteNames.workspaceFinancialRequests,
        builder: (context, state) => const GovernorModulePlaceholder(title: 'Financial Requests'),
      ),
    ],
  );
});
