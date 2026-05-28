import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../organizations/providers/workspace_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../widgets/welcome_header.dart';

class GovernorDashboardView extends ConsumerWidget {
  const GovernorDashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.watch(workspaceProvider);
    final org = workspace.selectedOrganization;
    final activeRole = workspace.activeRole;

    if (org == null) {
      return const Center(
        child: Text('No organization selected.'),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1024;
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOrgHeader(context, org, activeRole?.roleName ?? 'Member'),
              const SizedBox(height: AppSpacing.xl),
              
              if (isDesktop) 
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildKpiSection(org, activeRole?.roleName),
                          const SizedBox(height: AppSpacing.lg),
                          _buildUpcomingEvents(org),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPendingApprovals(org),
                          const SizedBox(height: AppSpacing.lg),
                          _buildRecentActivity(org),
                        ],
                      ),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    _buildKpiSection(org, activeRole?.roleName),
                    const SizedBox(height: AppSpacing.lg),
                    _buildPendingApprovals(org),
                    const SizedBox(height: AppSpacing.lg),
                    _buildUpcomingEvents(org),
                    const SizedBox(height: AppSpacing.lg),
                    _buildRecentActivity(org),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrgHeader(BuildContext context, dynamic org, String roleName) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Banner Placeholder
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Container(
              height: 120,
              width: double.infinity,
              color: AppColors.primary,
              child: org.bannerUrl != null 
                ? Image.network(
                    org.bannerUrl!, 
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Opacity(
                      opacity: 0.1,
                      child: Icon(Icons.hub_rounded, size: 100, color: Colors.white),
                    ),
                  )
                : const Opacity(
                    opacity: 0.1,
                    child: Icon(Icons.hub_rounded, size: 100, color: Colors.white),
                  ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 80, AppSpacing.xl, AppSpacing.xl),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primary,
                    backgroundImage: org.logoUrl != null ? NetworkImage(org.logoUrl!) : null,
                    child: org.logoUrl == null ? const Icon(Icons.business, color: Colors.white, size: 40) : null,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        org.name,
                        style: AppTextStyles.displaySmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              roleName.toUpperCase(),
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '• ${org.type.replaceAll('-', ' ').toUpperCase()}',
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiSection(dynamic org, String? roleName) {
    final bool isOfficer = roleName != null && roleName != 'Student';

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.5,
      children: [
        if (isOfficer) ...[
          _buildKpiCard('Total Members', '124', Icons.people_outline_rounded, Colors.blue),
          _buildKpiCard('Active Officers', '12', Icons.admin_panel_settings_outlined, Colors.orange),
          _buildKpiCard('Attendance Rate', '88%', Icons.how_to_reg_outlined, Colors.green),
          _buildKpiCard('Collections', '₱12,500', Icons.payments_outlined, Colors.teal),
          _buildKpiCard('Upcoming Events', '3', Icons.event_outlined, Colors.purple),
          _buildKpiCard('Pending Requests', '7', Icons.pending_actions_rounded, Colors.red),
        ] else ...[
          _buildKpiCard('My Attendance', '92%', Icons.how_to_reg_outlined, Colors.green),
          _buildKpiCard('Pending Fees', '₱0', Icons.payments_outlined, Colors.teal),
          _buildKpiCard('Events Attended', '15', Icons.event_available_rounded, Colors.blue),
        ],
      ],
    );
  }


  Widget _buildKpiCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Icon(Icons.trending_up_rounded, color: Colors.green, size: 16),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTextStyles.headlineMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingEvents(dynamic org) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Upcoming Events', style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold)),
              TextButton(onPressed: () {}, child: const Text('View All')),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _buildEventTile('Tech Summit 2026', 'May 28, 2026 • 8:00 AM', 'Social Hall', 'Mandatory'),
          const Divider(),
          _buildEventTile('Coding Competition', 'June 05, 2026 • 1:00 PM', 'Computer Lab 1', 'Optional'),
          const Divider(),
          _buildEventTile('Monthly Assembly', 'June 12, 2026 • 3:00 PM', 'Social Hall', 'Mandatory'),
        ],
      ),
    );
  }

  Widget _buildEventTile(String title, String date, String loc, String type) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.calendar_month_outlined, color: AppColors.primary),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('$date • $loc'),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: type == 'Mandatory' ? Colors.red.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          type,
          style: TextStyle(
            color: type == 'Mandatory' ? Colors.red : Colors.green,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPendingApprovals(dynamic org) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pending Approvals', style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.md),
          _buildApprovalItem('Juan Dela Cruz', 'Membership Request', '2 hours ago'),
          _buildApprovalItem('Maria Clara', 'Payment Verification (₱100)', '5 hours ago'),
          _buildApprovalItem('Pedro Penduko', 'Attendance Validation', '1 day ago'),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              child: const Text('View All Requests'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovalItem(String name, String type, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          CircleAvatar(radius: 18, child: Text(name[0])),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(type, style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
              ],
            ),
          ),
          Text(time, style: const TextStyle(color: AppColors.textGrey, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(dynamic org) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent Activities', style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.md),
          _buildActivityItem('Officer Assigned', 'Maria Clara was assigned as Treasurer.', '3 hours ago'),
          _buildActivityItem('Event Created', 'Annual Tech Summit 2026 was published.', 'Yesterday'),
          _buildActivityItem('Announcement', 'Welcome message sent to 5 new members.', '2 days ago'),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String desc, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.circle, size: 8, color: AppColors.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(desc, style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
                Text(time, style: const TextStyle(color: Colors.grey, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
