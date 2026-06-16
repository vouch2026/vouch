import 'package:vouch_v2/core/widgets/loaders/flickr_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../providers/organization_stats_provider.dart';

class KpiCards extends ConsumerWidget {
  const KpiCards({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(organizationStatsProvider);

    return statsAsync.when(
      data: (stats) => LayoutBuilder(
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
                title: 'Organizations',
                value: '${stats.totalOrganizations}',
                subtitle: '${stats.activeOrganizations} Active / ${stats.inactiveOrganizations} Inactive',
                icon: Icons.business_rounded,
                color: Colors.blue,
                trend: stats.trendPercentage,
              ),
              _KpiCard(
                title: 'Memberships',
                value: '${stats.totalMembers}',
                subtitle: '${stats.activeOfficers} Active Officers',
                icon: Icons.people_alt_rounded,
                color: Colors.green,
                trend: 2.4,
              ),
              _KpiCard(
                title: 'Governance',
                value: '${stats.orgsWithElections}',
                subtitle: 'Organizations with Elections',
                icon: Icons.how_to_vote_rounded,
                color: Colors.orange,
              ),
              _KpiCard(
                title: 'Compliance',
                value: '${stats.complianceRate}%',
                subtitle: '${stats.orgsWithSanctions} Active Sanctions',
                icon: Icons.gavel_rounded,
                color: Colors.red,
                trend: -1.2,
              ),
            ],
          );
        },
      ),
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
  final double? trend;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.trend,
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
                  Row(
                    children: [
                      Text(value, style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
                      if (trend != null) ...[
                        const SizedBox(width: AppSpacing.xs),
                        _TrendIndicator(trend: trend!),
                      ],
                    ],
                  ),
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

class _TrendIndicator extends StatelessWidget {
  final double trend;

  const _TrendIndicator({required this.trend});

  @override
  Widget build(BuildContext context) {
    final isPositive = trend > 0;
    final color = isPositive ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
            color: color,
            size: 12,
          ),
          const SizedBox(width: 2),
          Text(
            '${trend.abs()}%',
            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
