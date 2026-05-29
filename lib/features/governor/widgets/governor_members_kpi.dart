import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../organizations/providers/workspace_provider.dart';
import '../../organizations/providers/organization_provider.dart';

class GovernorMembersKpi extends ConsumerWidget {
  const GovernorMembersKpi({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.watch(workspaceProvider);
    final selectedOrg = workspace.selectedOrganization;

    if (selectedOrg == null) return const SizedBox.shrink();

    final membersAsync = ref.watch(organizationMembersProvider(selectedOrg.id));

    return membersAsync.when(
      data: (members) {
        final totalMembers = members.length;
        final activeMembers = members.where((m) => m.status.toLowerCase() == 'active').length;
        final pendingMembers = members.where((m) => m.status.toLowerCase() == 'pending').length;
        
        // Calculate new members this month
        final now = DateTime.now();
        final startOfMonth = DateTime(now.year, now.month, 1);
        final newMembersThisMonth = members.where((m) {
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
                _buildKpiCard(
                  context,
                  title: 'Total Members',
                  value: totalMembers.toString(),
                  icon: Icons.people_alt_rounded,
                  color: Colors.blue,
                  trend: 'All registered students',
                ),
                _buildKpiCard(
                  context,
                  title: 'Active Members',
                  value: activeMembers.toString(),
                  icon: Icons.check_circle_rounded,
                  color: Colors.green,
                  trend: totalMembers > 0 
                    ? '${((activeMembers / totalMembers) * 100).toInt()}% of total'
                    : '0% of total',
                ),
                _buildKpiCard(
                  context,
                  title: 'Pending Approval',
                  value: pendingMembers.toString(),
                  icon: Icons.pending_actions_rounded,
                  color: Colors.orange,
                  trend: 'Requires review',
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
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox.shrink(),
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
        side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
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
