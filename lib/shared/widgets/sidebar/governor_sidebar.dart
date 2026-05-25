import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../routes/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../features/auth/providers/auth_provider.dart';
import '../../../../features/organizations/providers/managed_organization_provider.dart';

class GovernorSidebar extends ConsumerWidget {
  const GovernorSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final managedOrgAsync = ref.watch(managedOrganizationProvider);

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
                    
                    managedOrgAsync.when(
                      data: (org) => _buildOrgContext(org),
                      loading: () => const SizedBox(height: 80, child: Center(child: CircularProgressIndicator())),
                      error: (_, __) => const SizedBox(),
                    ),

                    const _SidebarHeader(label: 'MAIN MENU'),
                    _SidebarItem(
                      icon: Icons.dashboard_outlined,
                      label: 'Overview',
                      path: RoutePaths.dashboard,
                    ),

                    const _SidebarHeader(label: 'ORGANIZATION'),
                    _SidebarItem(
                      icon: Icons.people_outline_rounded,
                      label: 'Members',
                      path: RoutePaths.governorMembers,
                    ),
                    _SidebarItem(
                      icon: Icons.admin_panel_settings_outlined,
                      label: 'Officers',
                      path: RoutePaths.governorOfficers,
                    ),
                    _SidebarItem(
                      icon: Icons.event_outlined,
                      label: 'Events',
                      path: RoutePaths.governorEvents,
                    ),
                    _SidebarItem(
                      icon: Icons.how_to_reg_outlined,
                      label: 'Attendance',
                      path: RoutePaths.governorAttendance,
                    ),
                    _SidebarItem(
                      icon: Icons.campaign_outlined,
                      label: 'Announcements',
                      path: RoutePaths.governorAnnouncements,
                    ),
                    _SidebarItem(
                      icon: Icons.description_outlined,
                      label: 'Documents',
                      path: RoutePaths.governorDocuments,
                    ),

                    const _SidebarHeader(label: 'FINANCE'),
                    _SidebarItem(
                      icon: Icons.payments_outlined,
                      label: 'Fees',
                      path: RoutePaths.governorFees,
                    ),
                    _SidebarItem(
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'Collections',
                      path: RoutePaths.governorCollections,
                    ),
                    _SidebarItem(
                      icon: Icons.bar_chart_outlined,
                      label: 'Financial Reports',
                      path: RoutePaths.governorFinanceReports,
                    ),

                    const _SidebarHeader(label: 'GOVERNANCE'),
                    _SidebarItem(
                      icon: Icons.how_to_vote_outlined,
                      label: 'Elections',
                      path: RoutePaths.governorElections,
                    ),
                    _SidebarItem(
                      icon: Icons.gavel_outlined,
                      label: 'Compliance',
                      path: RoutePaths.governorCompliance,
                    ),
                    _SidebarItem(
                      icon: Icons.report_problem_outlined,
                      label: 'Sanctions',
                      path: RoutePaths.governorSanctions,
                    ),

                    const _SidebarHeader(label: 'ANALYTICS'),
                    _SidebarItem(
                      icon: Icons.pie_chart_outline_rounded,
                      label: 'Participation',
                      path: RoutePaths.governorParticipation,
                    ),
                    _SidebarItem(
                      icon: Icons.trending_up_rounded,
                      label: 'Attendance Analytics',
                      path: RoutePaths.governorAttendanceAnalytics,
                    ),
                    _SidebarItem(
                      icon: Icons.monetization_on_outlined,
                      label: 'Financial Analytics',
                      path: RoutePaths.governorFinancialAnalytics,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              _SidebarItem(
                icon: Icons.settings_outlined,
                label: 'Organization Settings',
                path: RoutePaths.governorSettings,
              ),
              _SidebarItem(
                icon: Icons.person_outline_rounded,
                label: 'Profile',
                path: RoutePaths.settings,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg, top: AppSpacing.sm),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'VOUCH GOVERNANCE v1.0',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
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

  Widget _buildOrgContext(dynamic org) {
    if (org == null) return const SizedBox();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary,
            backgroundImage: org.logoUrl != null ? NetworkImage(org.logoUrl!) : null,
            child: org.logoUrl == null ? const Icon(Icons.business, color: Colors.white, size: 20) : null,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  org.name,
                  style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  org.type.replaceAll('-', ' ').toUpperCase(),
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.textGrey, fontSize: 9),
                ),
              ],
            ),
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
              color: const Color(0xFFC5A059).withValues(alpha: 0.1), // Gold accent
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
          Text(
            'GOVERNOR',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              letterSpacing: 1.5,
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
    final bool isSelected = GoRouterState.of(context).matchedLocation == path;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 1),
      child: ListTile(
        visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        selected: isSelected,
        selectedTileColor: AppColors.primary.withValues(alpha: 0.05),
        leading: Icon(
          icon,
          size: 20,
          color: isSelected ? AppColors.primary : Colors.grey.shade600,
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
