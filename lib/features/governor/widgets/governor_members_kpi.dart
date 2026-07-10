import 'package:vouch_v2/core/widgets/loaders/flickr_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../organizations/providers/workspace_provider.dart';
import '../../organizations/providers/organization_provider.dart';

class GovernorMembersKpi extends ConsumerWidget {
  final bool isOfficersScreen;

  const GovernorMembersKpi({
    super.key,
    this.isOfficersScreen = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.watch(workspaceProvider);
    final selectedOrg = workspace.selectedOrganization;

    if (selectedOrg == null) return const SizedBox.shrink();

    final membersAsync = ref.watch(organizationMembersProvider(selectedOrg.id));

    return membersAsync.when(
      data: (members) {
        final now = DateTime.now();
        final startOfMonth = DateTime(now.year, now.month, 1);

        // Filter lists
        final regularMembers = members.where((m) {
          final role = m.role.toLowerCase();
          return role == 'member' || role == 'student';
        }).toList();

        final officers = members.where((m) {
          final role = m.role.toLowerCase();
          return role != 'member' && role != 'student';
        }).toList();

        // Calculate counts
        final totalMembersCount = regularMembers.length;
        final activeMembersCount = regularMembers.where((m) => m.status.toLowerCase() == 'active').length;
        final pendingMembersCount = regularMembers.where((m) => m.status.toLowerCase() == 'pending').length;
        final newMembersThisMonth = regularMembers.where((m) {
          if (m.joinedAt == null) return false;
          return m.joinedAt!.isAfter(startOfMonth);
        }).length;

        final totalOfficersCount = officers.length;
        final activeOfficersCount = officers.where((m) => m.status.toLowerCase() == 'active').length;
        final pendingOfficersCount = officers.where((m) => m.status.toLowerCase() == 'pending').length;
        final newOfficersThisMonth = officers.where((m) {
          if (m.joinedAt == null) return false;
          return m.joinedAt!.isAfter(startOfMonth);
        }).length;

        return LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1100;
            final crossAxisCount = isMobile ? 1 : (isTablet ? 2 : 4);
            final childAspectRatio = isMobile ? 3.5 : (isTablet ? 3.0 : 2.5);

            return GridView.count(
              crossAxisCount: crossAxisCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: AppSpacing.lg,
              mainAxisSpacing: AppSpacing.lg,
              childAspectRatio: childAspectRatio,
              children: [
                if (isOfficersScreen) ...[
                  _buildKpiCard(
                    context,
                    title: 'Total Officers',
                    value: totalOfficersCount.toString(),
                    icon: Icons.badge_rounded,
                    color: Colors.orange,
                    trend: 'Organization leadership',
                  ),
                  _buildKpiCard(
                    context,
                    title: 'Active Officers',
                    value: activeOfficersCount.toString(),
                    icon: Icons.check_circle_rounded,
                    color: Colors.green,
                    trend: totalOfficersCount > 0
                        ? '${((activeOfficersCount / totalOfficersCount) * 100).toInt()}% of total'
                        : '0% of total',
                  ),
                  _buildKpiCard(
                    context,
                    title: 'Pending Officers',
                    value: pendingOfficersCount.toString(),
                    icon: Icons.pending_actions_rounded,
                    color: Colors.red,
                    trend: 'Awaiting confirmation',
                  ),
                  _buildKpiCard(
                    context,
                    title: 'New This Month',
                    value: newOfficersThisMonth.toString(),
                    icon: Icons.person_add_rounded,
                    color: Colors.purple,
                    trend: 'Joined since ${now.month}/${now.year}',
                    isTrendPositive: newOfficersThisMonth > 0,
                  ),
                ] else ...[
                  _buildKpiCard(
                    context,
                    title: 'Total Members',
                    value: totalMembersCount.toString(),
                    icon: Icons.people_alt_rounded,
                    color: Colors.blue,
                    trend: 'All registered students',
                  ),
                  _buildKpiCard(
                    context,
                    title: 'Active Members',
                    value: activeMembersCount.toString(),
                    icon: Icons.check_circle_rounded,
                    color: Colors.green,
                    trend: totalMembersCount > 0
                        ? '${((activeMembersCount / totalMembersCount) * 100).toInt()}% of total'
                        : '0% of total',
                  ),
                  _buildKpiCard(
                    context,
                    title: 'Pending Members',
                    value: pendingMembersCount.toString(),
                    icon: Icons.pending_actions_rounded,
                    color: Colors.red,
                    trend: 'Awaiting confirmation',
                  ),
                  _buildKpiCard(
                    context,
                    title: 'New This Month',
                    value: newMembersThisMonth.toString(),
                    icon: Icons.person_add_rounded,
                    color: Colors.purple,
                    trend: 'Joined since ${now.month}/${now.year}',
                    isTrendPositive: newMembersThisMonth > 0,
                  ),
                ],
              ],
            );
          },
        );
      },
      loading: () => const Center(child: FlickrLoader()),
      error: (error, stackTrace) => const SizedBox.shrink(),
    );
  }

  Widget _buildKpiCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? trend,
    bool? isTrendPositive,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.labelMedium.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        value,
                        style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (trend != null) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            trend,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: isTrendPositive == true
                                  ? Colors.green
                                  : (isTrendPositive == false ? Colors.red : Colors.grey[600]),
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
