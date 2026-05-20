import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../routes/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../features/auth/providers/auth_provider.dart';

class AppSidebar extends ConsumerWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider).value;
    final isSuperAdmin = userProfile?.role == 'super_admin';

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
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildSidebarHeader(),
                    _SidebarItem(
                      icon: Icons.dashboard_outlined,
                      label: 'Dashboard',
                      path: RoutePaths.dashboard,
                    ),
                    const _SidebarHeader(label: 'CAMPUS MANAGEMENT'),
                    _SidebarItem(
                      icon: Icons.account_tree_outlined,
                      label: 'Academic Structure',
                      path: RoutePaths.academicStructure,
                    ),
                    _SidebarItem(
                      icon: Icons.corporate_fare_outlined,
                      label: 'Organizations',
                      path: RoutePaths.organizations,
                    ),
                    _SidebarItem(
                      icon: Icons.event_outlined,
                      label: 'Events',
                      path: RoutePaths.events,
                    ),
                    const _SidebarHeader(label: 'USER MANAGEMENT'),
                    _SidebarItem(
                      icon: Icons.people_outline_rounded,
                      label: 'Users',
                      path: RoutePaths.users,
                    ),
                    _SidebarItem(
                      icon: Icons.admin_panel_settings_outlined,
                      label: 'Officers',
                      path: RoutePaths.officers,
                    ),
                    const _SidebarHeader(label: 'COMSELEC'),
                    _SidebarItem(
                      icon: Icons.how_to_vote_rounded,
                      label: 'Elections',
                      path: RoutePaths.comselecDashboard,
                    ),
                    _SidebarItem(
                      icon: Icons.groups_rounded,
                      label: 'Candidates',
                      path: RoutePaths.comselecCandidates,
                    ),
                    _SidebarItem(
                      icon: Icons.person_search_rounded,
                      label: 'Voters',
                      path: RoutePaths.comselecVoters,
                    ),
                    _SidebarItem(
                      icon: Icons.analytics_rounded,
                      label: 'Results',
                      path: RoutePaths.comselecResults,
                    ),
                    _SidebarItem(
                      icon: Icons.query_stats_rounded,
                      label: 'Analytics',
                      path: RoutePaths.comselecAnalytics,
                    ),
                    _SidebarItem(
                      icon: Icons.badge_outlined,
                      label: 'Officials',
                      path: RoutePaths.comselecOfficials,
                    ),
                    if (!isSuperAdmin) ...[
                      _SidebarItem(
                        icon: Icons.how_to_reg_outlined,
                        label: 'Attendance',
                        path: RoutePaths.attendance,
                      ),
                      _SidebarItem(
                        icon: Icons.how_to_vote_outlined,
                        label: 'Elections',
                        path: RoutePaths.elections,
                      ),
                      _SidebarItem(
                        icon: Icons.payments_outlined,
                        label: 'Finance',
                        path: RoutePaths.finance,
                      ),
                    ],
                  ],
                ),
              ),
              const Divider(height: 1),
              _SidebarItem(
                icon: Icons.settings_outlined,
                label: 'Settings',
                path: RoutePaths.settings,
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
                      'Version 1.0.0+1',
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
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xxl, AppSpacing.lg, AppSpacing.xl),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/logos/vouch.png',
            width: 40,
            height: 40,
          ),
          const SizedBox(width: AppSpacing.sm),
          RichText(
            text: TextSpan(
              style: GoogleFonts.poppins(
                fontSize: 32,
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
          fontSize: 11,
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
    final bool isSelected = GoRouterState.of(context).matchedLocation == path;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        selected: isSelected,
        selectedTileColor: AppColors.primary.withValues(alpha: 0.05),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.1)
                : AppColors.accent.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 18,
            color: isSelected ? AppColors.primary : Colors.grey.shade700,
          ),
        ),
        title: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
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
