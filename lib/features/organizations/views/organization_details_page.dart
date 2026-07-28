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
import '../providers/workspace_provider.dart';
import '../../../core/utils/role_mapper.dart';
import '../../auth/providers/auth_provider.dart';
import '../widgets/details/org_details_header.dart';
import '../widgets/details/org_details_analytics_cards.dart';
import '../widgets/details/org_details_tabs_view.dart';
import '../../../core/widgets/states/offline_state_view.dart';

class OrganizationDetailsPage extends ConsumerWidget {
  final String id;

  const OrganizationDetailsPage({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final organizationAsync = ref.watch(organizationProvider(id));
    final userProfile = ref.watch(userProfileProvider).value;
    final activeRole = ref.watch(workspaceProvider).activeRole;
    final isSuperAdmin = userProfile?.role == 'super_admin';

    return DashboardLayout(
      title: 'Organization Details',
      onBack: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(RoutePaths.organizations);
        }
      },
      child: organizationAsync.when(
        data: (org) {
          if (org == null) return const Center(child: Text('Organization not found'));

          // Authorization check: Deans and Program Heads can only access organizations under their scope
          bool isAuthorized = isSuperAdmin;
          if (!isAuthorized && activeRole != null && userProfile != null) {
            final roleKey = RoleMapper.mapDbRoleToAppFormat(activeRole.roleName);
            if (roleKey == 'dean') {
              isAuthorized = org.type == 'faculty-based' && org.facultyId == userProfile.facultyId;
            } else if (roleKey == 'program_head') {
              isAuthorized = org.type == 'program-based' && org.programId == userProfile.programId;
            }
          }

          if (!isAuthorized) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_outline, size: 48, color: AppColors.error),
                    SizedBox(height: AppSpacing.md),
                    Text(
                      'Access Denied',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'You do not have permission to view this organization\'s details.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }
          
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Breadcrumbs
                Builder(
                  builder: (context) {
                    final size = MediaQuery.of(context).size;
                    final isMobile = size.width < 768;
                    final topPadding = isMobile ? 16.0 : 24.0;

                    return Padding(
                      padding: EdgeInsets.fromLTRB(AppSpacing.lg, topPadding, AppSpacing.lg, 0),
                      child: Row(
                        children: [
                          Icon(Icons.business_center_outlined, size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go(RoutePaths.organizations);
                              }
                            },
                            child: Text(
                              'Organizations',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.chevron_right_rounded, size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 8),
                          Text(
                            org.code,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                ),
                const SizedBox(height: AppSpacing.md),
                
                // 1. Premium Hero Header
                OrgDetailsHeader(org: org),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 2. High-level Analytics Metrics
                      OrgDetailsAnalyticsCards(orgId: id),
                      const SizedBox(height: AppSpacing.xl),
                      
                      // 3. Main Content Area (Tabs only)
                      OrgDetailsTabsView(org: org),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: FlickrLoader()),
        error: (error, stack) {
          if (OfflineStateView.isOfflineError(error)) {
            return OfflineStateView(
              onRetry: () => ref.invalidate(organizationProvider(id)),
            );
          }
          return Center(child: Text('Error: $error'));
        },
      ),
    );
  }
}
