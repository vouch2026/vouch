import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'route_names.dart';
import 'route_paths.dart';
import '../features/auth/views/login_page.dart';
import '../features/auth/views/register_page.dart';
import '../features/auth/views/email_verification_page.dart';
import '../features/dashboard/views/dashboard_page.dart';
import '../features/organizations/views/organizations_page.dart';
import '../features/organizations/views/organization_details_page.dart';
import '../features/campuses/views/campuses_page.dart';
import '../features/campuses/views/campus_details_page.dart';
import '../features/faculties/views/faculties_page.dart';
import '../features/faculties/views/faculty_details_page.dart';
import '../features/programs/views/programs_page.dart';
import '../features/programs/views/program_details_page.dart';
import '../features/users/views/students_page.dart';
import '../features/users/views/instructors_page.dart';
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
import '../features/auth/providers/auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: RoutePaths.login,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final auth = authState.value;
      final loggingIn = state.matchedLocation == RoutePaths.login ||
          state.matchedLocation == RoutePaths.register ||
          state.matchedLocation == RoutePaths.forgotPassword ||
          state.matchedLocation == RoutePaths.emailVerification;

      if (auth?.session == null) {
        return loggingIn ? null : RoutePaths.login;
      }

      if (loggingIn) {
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
        path: RoutePaths.students,
        name: RouteNames.students,
        builder: (context, state) => const StudentsPage(),
      ),
      GoRoute(
        path: RoutePaths.instructors,
        name: RouteNames.instructors,
        builder: (context, state) => const InstructorsPage(),
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
    ],
  );
});
