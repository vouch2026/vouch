import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../routes/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/permissions/app_permissions.dart';
import '../../../../features/auth/providers/auth_provider.dart';
import '../../../../features/organizations/providers/workspace_provider.dart';
import '../../../../core/providers/sidebar_provider.dart';
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

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: Stack(
        children: [
          _buildBackgroundDecorations(),
          Column(
            children: [
              _buildSidebarHeader(context, ref),
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
                      icon: Icons.calendar_today_outlined,
                      label: 'Calendar',
                      path: RoutePaths.calendar,
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
                      _SidebarItem(
                        icon: Icons.grid_view_rounded,
                        label: '${activeRole?.roleName ?? 'Workspace'} Home',
                        path: RoutePaths.dashboard,
                      ),
                      
                      // People Section
                      if (activeRole?.hasAnyPermission([AppPermissions.viewMembers, AppPermissions.viewOfficers, AppPermissions.assignRoles]) ?? false) ...[
                        const _SidebarHeader(label: 'PEOPLE'),
                        if (activeRole?.hasPermission(AppPermissions.viewMembers) ?? false)
                          const _SidebarItem(
                            icon: Icons.people_outline_rounded,
                            label: 'Members',
                            path: RoutePaths.workspaceMembers,
                          ),
                        if (activeRole?.hasPermission(AppPermissions.viewOfficers) ?? false)
                          const _SidebarItem(
                            icon: Icons.badge_outlined,
                            label: 'Officers',
                            path: RoutePaths.workspaceOfficers,
                          ),
                      ],

                      // Operations Section
                      if (activeRole?.hasAnyPermission([
                        AppPermissions.viewEvents, 
                        AppPermissions.createEvent,
                        AppPermissions.manageActivityCards,
                        AppPermissions.viewActivityCards,
                        AppPermissions.viewAnnouncements,
                        AppPermissions.createAnnouncement
                      ]) ?? false) ...[
                        const _SidebarHeader(label: 'OPERATIONS'),
                        if (activeRole?.hasAnyPermission([AppPermissions.viewEvents, AppPermissions.createEvent]) ?? false)
                          const _SidebarItem(
                            icon: Icons.calendar_today_outlined,
                            label: 'Events',
                            path: RoutePaths.workspaceEvents,
                          ),
                        if (activeRole?.hasPermission(AppPermissions.scanEventAttendance) ?? false)
                          const _SidebarItem(
                            icon: Icons.how_to_reg_rounded,
                            label: 'Attendance',
                            path: RoutePaths.workspaceAttendance,
                          ),
                        if (activeRole?.hasAnyPermission([AppPermissions.manageActivityCards, AppPermissions.viewActivityCards]) ?? false)
                          const _SidebarItem(
                            icon: Icons.assignment_outlined,
                            label: 'Activity Cards',
                            path: RoutePaths.workspaceActivityCards,
                          ),
                        if (activeRole?.hasAnyPermission([AppPermissions.viewAnnouncements, AppPermissions.createAnnouncement]) ?? false)
                          const _SidebarItem(
                            icon: Icons.campaign_outlined,
                            label: 'Announcements',
                            path: RoutePaths.workspaceAnnouncements,
                          ),
                        if (activeRole?.hasPermission(AppPermissions.viewDocuments) ?? false)
                          const _SidebarItem(
                            icon: Icons.folder_open_rounded,
                            label: 'Records',
                            path: RoutePaths.workspaceDocuments,
                          ),
                      ],
                      
                      // Finance Section
                      if (activeRole?.hasAnyPermission([
                        AppPermissions.viewFees, 
                        AppPermissions.createFee, 
                        AppPermissions.manageCollections
                      ]) ?? false) ...[
                        const _SidebarHeader(label: 'FINANCE'),
                        if (activeRole?.hasAnyPermission([AppPermissions.viewFees, AppPermissions.createFee]) ?? false)
                          const _SidebarItem(
                            icon: Icons.payments_outlined,
                            label: 'Fees',
                            path: RoutePaths.workspaceFees,
                          ),
                        if (activeRole?.hasPermission(AppPermissions.manageCollections) ?? false)
                          const _SidebarItem(
                            icon: Icons.account_balance_wallet_outlined,
                            label: 'Collections',
                            path: RoutePaths.workspaceCollections,
                          ),
                      ],

                      // Insights Section
                      if (activeRole?.hasAnyPermission([AppPermissions.viewAnalytics, AppPermissions.viewProgramAnalytics, AppPermissions.viewFacultyAnalytics]) ?? false) ...[
                        const _SidebarHeader(label: 'INSIGHTS'),
                        const _SidebarItem(
                          icon: Icons.bar_chart_rounded,
                          label: 'Reports',
                          path: RoutePaths.dashboard, // Placeholder or specific report path
                        ),
                      ],

                      // Settings Section
                      if (activeRole?.hasPermission(AppPermissions.manageOrganization) ?? false) ...[
                        const _SidebarHeader(label: 'SETTINGS'),
                        const _SidebarItem(
                          icon: Icons.settings_outlined,
                          label: 'Organization Settings',
                          path: RoutePaths.workspaceSettings,
                        ),
                      ],
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

  Widget _buildSidebarHeader(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xxl, AppSpacing.lg, AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
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
          IconButton(
            icon: const Icon(Icons.menu_open_rounded, color: AppColors.primary),
            tooltip: 'Close Sidebar',
            onPressed: () {
              ref.read(sidebarVisibleProvider.notifier).state = false;
            },
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

class _SidebarItem extends ConsumerWidget {
  final IconData icon;
  final String label;
  final String path;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.path,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          // On mobile, we might want to close it after navigation? 
          // But the user said "only hide if close is pressed".
          // However, for better UX on small screens, maybe it should close?
          // Let's stick to the requirement for now.
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
