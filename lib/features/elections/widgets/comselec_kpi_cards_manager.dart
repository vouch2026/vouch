import 'package:vouch_v2/core/widgets/loaders/flickr_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/comselec_provider.dart';

class ComselecKpiCardsManager extends ConsumerWidget {
  const ComselecKpiCardsManager({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comselecsAsync = ref.watch(comselecsProvider);

    return comselecsAsync.when(
      data: (comselecs) {
        final totalBranches = comselecs.length;
        final activeBranches = comselecs.where((c) => c.status == 'active').length;
        final inactiveBranches = totalBranches - activeBranches;
        final totalVoters = comselecs.fold<int>(0, (sum, c) => sum + c.memberCount);
        final avgVoters = totalBranches > 0 ? (totalVoters / totalBranches).toStringAsFixed(1) : '0';

        return LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 1200 ? 4 : (constraints.maxWidth > 800 ? 2 : 1);
            
            return GridView.count(
              crossAxisCount: crossAxisCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              childAspectRatio: 2.5,
              children: [
                _KpiCard(
                  title: 'COMSELEC Branches',
                  value: '$totalBranches',
                  subtitle: '$activeBranches Active / $inactiveBranches Inactive',
                  icon: Icons.account_balance_rounded,
                  color: Colors.blue,
                ),
                _KpiCard(
                  title: 'Total Voters',
                  value: '$totalVoters',
                  subtitle: 'Registered Student Voters',
                  icon: Icons.people_alt_rounded,
                  color: Colors.green,
                ),
                _KpiCard(
                  title: 'Avg. Voters / Branch',
                  value: avgVoters,
                  subtitle: 'Voters per Campus',
                  icon: Icons.analytics_rounded,
                  color: Colors.orange,
                ),
                _KpiCard(
                  title: 'Active Elections',
                  value: '0',
                  subtitle: 'Across all branches',
                  icon: Icons.how_to_vote_rounded,
                  color: Colors.red,
                ),
              ],
            );
          },
        );
      },
      loading: () => const Center(child: FlickrLoader()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: AppTextStyles.bodySmall.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 2),
                  Text(value, style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.bodySmall.copyWith(fontSize: 10)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
