import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'route_names.dart';
import 'route_paths.dart';
import '../features/auth/views/login_page.dart';
import '../features/auth/views/register_page.dart';
import '../features/auth/views/email_verification_page.dart';
import '../features/dashboard/views/dashboard_page.dart';
import '../features/activity_cards/views/activity_card_redirector.dart';
import '../features/activity_cards/views/activity_card_details_page.dart';
import '../features/organizations/views/organizations_page.dart';
import '../features/organizations/views/organization_details_page.dart';
import '../features/campuses/views/campuses_page.dart';
import '../features/campuses/views/campus_details_page.dart';
import '../features/faculties/views/faculties_page.dart';
import '../features/faculties/views/faculty_details_page.dart';
import '../features/programs/views/programs_page.dart';
import '../features/programs/views/program_details_page.dart';
import '../features/users/views/users_page.dart';
import '../features/users/views/officers_page.dart';
import '../features/users/views/user_profile_page.dart';
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
import '../features/governor/views/governor_finance_page.dart';
import '../features/governor/views/governor_members_page.dart';
import '../features/governor/views/governor_officers_page.dart';
import '../features/governor/views/governor_collections_page.dart';
import '../features/governor/views/governor_settings_page.dart';
import '../features/governor/views/activity_cards/governor_activity_cards_page.dart';
import '../features/governor/views/activity_cards/governor_activity_card_review_page.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/organizations/providers/workspace_provider.dart';

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
    initialLocation: RoutePaths.login,
    debugLogDiagnostics: true,
    refreshListenable: notifier,
    redirect: (context, state) {
      final auth = ref.read(authStateProvider).value;
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
        return RoutePaths.dashboard;
      }

      // Redirect if accessing workspace routes without a selected organization
      final workspace = ref.read(workspaceProvider);
      if (state.matchedLocation.startsWith('/workspace') && workspace.selectedOrganization == null) {
        return RoutePaths.dashboard;
      }

      return null;
    },
    routes: [

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
        builder: (context, state) => const GovernorModulePlaceholder(title: 'Calendar'),
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
        path: RoutePaths.myQrCode,
        name: RouteNames.myQrCode,
        builder: (context, state) => const GovernorModulePlaceholder(title: 'My QR Code'),
      ),
      GoRoute(
        path: RoutePaths.aboutUs,
        name: RouteNames.aboutUs,
        builder: (context, state) => const GovernorModulePlaceholder(title: 'About Us'),
      ),
      GoRoute(
        path: RoutePaths.help,
        name: RouteNames.help,
        builder: (context, state) => const GovernorModulePlaceholder(title: 'Help & Support'),
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
        builder: (context, state) => const GovernorModulePlaceholder(title: 'Organization Sanctions'),
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
    ],
  );
});
