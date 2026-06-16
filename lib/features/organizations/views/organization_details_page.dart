import 'package:vouch_v2/core/widgets/loaders/flickr_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../../../routes/route_paths.dart';
import '../providers/organization_provider.dart';
import '../widgets/details/org_details_header.dart';
import '../widgets/details/org_details_analytics_cards.dart';
import '../widgets/details/org_details_sidebar.dart';
import '../widgets/details/org_details_tabs_view.dart';

class OrganizationDetailsPage extends ConsumerWidget {
  final String id;

  const OrganizationDetailsPage({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final organizationAsync = ref.watch(organizationProvider(id));

    return DashboardLayout(
      title: 'Organization Details',
      child: organizationAsync.when(
        data: (org) {
          if (org == null) return const Center(child: Text('Organization not found'));
          
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Breadcrumbs
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, 0),
                  child: Row(
                    children: [
                      Icon(Icons.business_rounded, size: 16, color: AppColors.textGrey.withOpacity(0.5)),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => context.go(RoutePaths.organizations),
                        child: Text('Organizations', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey)),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.textGrey.withOpacity(0.5)),
                      const SizedBox(width: 8),
                      Text(org.code, style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                
                // 1. Premium Hero Header
                OrgDetailsHeader(org: org),
                
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 2. High-level Analytics Metrics
                      OrgDetailsAnalyticsCards(orgId: id),
                      const SizedBox(height: AppSpacing.xl),
                      
                      // 3. Main Content Area (Tabs + Sidebar)
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth > 1100) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Left Column: Enterprise Tabs
                                Expanded(
                                  flex: 3,
                                  child: OrgDetailsTabsView(org: org),
                                ),
                                const SizedBox(width: AppSpacing.xl),
                                // Right Column: Sticky Performance Sidebar
                                const Expanded(
                                  flex: 1,
                                  child: OrgDetailsSidebar(),
                                ),
                              ],
                            );
                          }
                          
                          // Tablet/Mobile: Stacked Layout
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              OrgDetailsTabsView(org: org),
                              const SizedBox(height: AppSpacing.xl),
                              const OrgDetailsSidebar(),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: FlickrLoader()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
