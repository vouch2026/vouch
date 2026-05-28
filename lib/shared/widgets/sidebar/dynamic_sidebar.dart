import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../routes/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../features/auth/providers/auth_provider.dart';
import '../../../../features/organizations/providers/workspace_provider.dart';
import 'organization_switcher.dart';

class DynamicSidebar extends ConsumerWidget {
  const DynamicSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.watch(workspaceProvider);
    final userProfile = ref.watch(userProfileProvider).value;
    final isSuperAdmin = userProfile?.role == 'super_admin';
    final selectedOrg = workspace.selectedOrganization;
    final activeRole = workspace.activeRole;

    return Drawer(
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Stack(
        children: [
          _buildBackgroundDecorations(),
          Column(
            children: [
              _buildSidebarHeader(),
              if (!isSuperAdmin) const OrganizationSwitcher(),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    const _SidebarHeader(label: 'PERSONAL HUB'),
                    const _SidebarItem(
                      icon: Icons.dashboard_outlined,
                      label: 'Dashboard',
                      path: RoutePaths.dashboard,
                    ),
                    const _SidebarItem(
                      icon: Icons.payments_outlined,
                      label: 'My Fees',
                      path: RoutePaths.fees,
                    ),
                    const _SidebarItem(
                      icon: Icons.event_outlined,
                      label: 'My Events',
                      path: RoutePaths.events,
                    ),
                    const _SidebarItem(
                      icon: Icons.notifications_none_rounded,
                      label: 'Notifications',
                      path: RoutePaths.notifications,
                    ),

                    if (isSuperAdmin) ...[
                      const _SectionDivider(),
                      const _SidebarHeader(label: 'SYSTEM ADMINISTRATION'),
                      const _SidebarItem(
                        icon: Icons.corporate_fare_outlined,
                        label: 'My Organizations',
                        path: RoutePaths.organizations,
                      ),
                      const _SidebarItem(
                        icon: Icons.account_tree_outlined,
                        label: 'Academic Structure',
                        path: RoutePaths.academicStructure,
                      ),
                      const _SidebarItem(
                        icon: Icons.people_outline_rounded,
                        label: 'All Users',
                        path: RoutePaths.users,
                      ),
                      const _SidebarItem(
                        icon: Icons.how_to_vote_rounded,
                        label: 'Global Elections',
                        path: RoutePaths.comselecDashboard,
                      ),
                    ] else if (selectedOrg != null) ...[
                      const _SectionDivider(),
                      _SidebarHeader(label: 'WORKSPACE: ${selectedOrg.code}'),
                      const _SidebarItem(
                        icon: Icons.grid_view_rounded,
                        label: 'Workspace Home',
                        path: RoutePaths.dashboard,
                      ),
                      const _SidebarItem(
                        icon: Icons.people_outline_rounded,
                        label: 'Members',
                        path: RoutePaths.governorMembers,
                      ),
                      const _SidebarItem(
                        icon: Icons.calendar_today_outlined,
                        label: 'Events',
                        path: RoutePaths.governorEvents,
                      ),
                      
                      if (activeRole?.roleName == 'Governor' || activeRole?.roleName == 'Treasurer')
                        const _SidebarItem(
                          icon: Icons.payments_outlined,
                          label: 'Finance',
                          path: RoutePaths.governorFees,
                        ),
                      
                      const _SidebarItem(
                        icon: Icons.campaign_outlined,
                        label: 'Announcements',
                        path: RoutePaths.governorAnnouncements,
                      ),
                      const _SidebarItem(
                        icon: Icons.settings_outlined,
                        label: 'Settings',
                        path: RoutePaths.governorSettings,
                      ),
                    ],
                  ],
                ),
              ),
              const Divider(height: 1),
              const _SidebarItem(
                icon: Icons.help_outline_rounded,
                label: 'Help & Support',
                path: RoutePaths.help,
              ),
              const _SidebarItem(
                icon: Icons.info_outline_rounded,
                label: 'About Us',
                path: RoutePaths.aboutUs,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg, top: AppSpacing.sm),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '© ${DateTime.now().year} Vouch. All rights reserved.',
                      style: AppTextStyles.labelSmall.copyWith(color: Colors.grey.shade400),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Version 2.0.0 (Beta)',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.grey.shade400,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundDecorations() {
    return Stack(
      children: [
        Positioned(
          top: -30,
          right: -30,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          left: -40,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSidebarHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xxl, AppSpacing.lg, AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/logos/vouch.png',
            width: 32,
            height: 32,
          ),
          const SizedBox(width: AppSpacing.sm),
          RichText(
            text: TextSpan(
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
              children: const [
                TextSpan(
                  text: 'Vou',
                  style: TextStyle(color: AppColors.primary),
                ),
                TextSpan(
                  text: 'ch',
                  style: TextStyle(color: AppColors.accent),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarHeader extends StatelessWidget {
  final String label;

  const _SidebarHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xs),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 10,
          color: AppColors.textGrey,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String path;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.path,
  });

  @override
  Widget build(BuildContext context) {
    bool isSelected = false;
    try {
      isSelected = GoRouterState.of(context).matchedLocation == path;
    } catch (_) {
      // Fallback or ignore if GoRouterState is not available
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        selected: isSelected,
        selectedTileColor: AppColors.primary.withValues(alpha: 0.05),
        leading: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.1)
                : AppColors.accent.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 16,
            color: isSelected ? AppColors.primary : Colors.grey.shade700,
          ),
        ),
        title: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: isSelected ? AppColors.primary : Colors.black87,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        onTap: () {
          context.go(path);
          Navigator.pop(context); // Close drawer
        },
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      child: Divider(height: 1, thickness: 0.5),
    );
  }
}
