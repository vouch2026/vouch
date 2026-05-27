import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../../auth/providers/auth_provider.dart';
import '../../organizations/providers/workspace_provider.dart';
import '../widgets/welcome_header.dart';
import '../widgets/kpi_cards.dart';
import '../widgets/analytics_overview.dart';
import '../widgets/dashboard_sidebar_widgets.dart';
import '../widgets/quick_actions.dart';
import 'governor_dashboard_view.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.watch(workspaceProvider);
    final userProfileAsync = ref.watch(userProfileProvider);
    final selectedOrg = workspace.selectedOrganization;

    return userProfileAsync.when(
      data: (profile) {
        final isSuperAdmin = profile?.role == 'super_admin';
        final showGovernorView = selectedOrg != null && !isSuperAdmin;

        return DashboardLayout(
          key: ValueKey(isSuperAdmin ? 'admin' : (selectedOrg?.id ?? 'global')),
          title: showGovernorView ? 'Workspace Command Center' : 'Main Dashboard',
          child: workspace.isLoading 
              ? const Center(child: CircularProgressIndicator())
              : showGovernorView 
                  ? const GovernorDashboardView()
                  : LayoutBuilder(
                    builder: (context, constraints) {
                      final isDesktop = constraints.maxWidth >= 1024;

                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: isDesktop
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Main Content Area (Left)
                                  Expanded(
                                    flex: 5,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: const [
                                        WelcomeHeader(),
                                        SizedBox(height: AppSpacing.lg),
                                        QuickActionsSection(),
                                        SizedBox(height: AppSpacing.lg),
                                        KpiCardsSection(),
                                        SizedBox(height: AppSpacing.lg),
                                        AnalyticsOverviewSection(),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.lg),
                                  // Sidebar Area (Right)
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: const [
                                        PendingApprovalsPanel(),
                                        SizedBox(height: AppSpacing.lg),
                                        RecentActivityFeed(),
                                        SizedBox(height: AppSpacing.lg),
                                        SystemHealthPanel(),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  WelcomeHeader(),
                                  SizedBox(height: AppSpacing.lg),
                                  QuickActionsSection(),
                                  SizedBox(height: AppSpacing.lg),
                                  KpiCardsSection(),
                                  SizedBox(height: AppSpacing.lg),
                                  AnalyticsOverviewSection(),
                                  SizedBox(height: AppSpacing.lg),
                                  PendingApprovalsPanel(),
                                  SizedBox(height: AppSpacing.lg),
                                  RecentActivityFeed(),
                                  SizedBox(height: AppSpacing.lg),
                                  SystemHealthPanel(),
                                ],
                              ),
                      );
                    },
                  ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }
}
