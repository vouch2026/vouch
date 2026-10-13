import 'package:vouch_v2/core/widgets/loaders/flickr_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/academic_stats_provider.dart';

/// Real-data KPI cards for the Academic Structure page.
///
/// Every number comes from [academicStatsProvider] — no placeholder trends
/// or synthetic sparklines.
class AcademicKpiSection extends ConsumerWidget {
  const AcademicKpiSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(academicStatsProvider);

    return statsAsync.when(
      data: (stats) => LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount = 5;
          if (constraints.maxWidth < 600) {
            crossAxisCount = 1;
          } else if (constraints.maxWidth < 900) {
            crossAxisCount = 2;
          } else if (constraints.maxWidth < 1200) {
            crossAxisCount = 3;
          }

          final totalStudents = stats['totalStudents'] as int? ?? 0;
          final campusesCount = stats['campusesCount'] as int? ?? 0;
          final activeCampuses = stats['activeCampuses'] as int? ?? 0;
          final inactiveCampuses = stats['inactiveCampuses'] as int? ?? 0;
          final facultiesCount = stats['facultiesCount'] as int? ?? 0;
          final deansCount = stats['deansCount'] as int? ?? 0;
          final facultiesWithoutDean =
              stats['facultiesWithoutDean'] as int? ?? 0;
          final programsCount = stats['programsCount'] as int? ?? 0;
          final headsCount = stats['headsCount'] as int? ?? 0;
          final programsWithoutHead =
              stats['programsWithoutHead'] as int? ?? 0;

          return GridView.count(
            crossAxisCount: crossAxisCount,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            childAspectRatio: crossAxisCount == 1 ? 3.2 : 1.35,
            children: [
              _AcademicKpiCard(
                title: 'Schools',
                value: '${stats['schoolsCount'] ?? 0}',
                primaryStat:
                    'Active: ${stats['activeSchools'] ?? 0}',
                secondaryStat: 'Top of the hierarchy',
                icon: Icons.account_balance_outlined,
                iconColor: const Color(0xFF0F766E),
              ),
              _AcademicKpiCard(
                title: 'Campuses',
                value: '$campusesCount',
                primaryStat: 'Active: $activeCampuses',
                secondaryStat: inactiveCampuses > 0
                    ? 'Inactive: $inactiveCampuses'
                    : 'All campuses active',
                isWarning: inactiveCampuses > 0,
                icon: Icons.business_rounded,
                iconColor: AppColors.primary,
              ),
              _AcademicKpiCard(
                title: 'Faculties',
                value: '$facultiesCount',
                primaryStat: 'With dean: $deansCount',
                secondaryStat: facultiesWithoutDean > 0
                    ? 'Missing dean: $facultiesWithoutDean'
                    : 'All faculties led',
                isWarning: facultiesWithoutDean > 0,
                icon: Icons.account_balance_rounded,
                iconColor: AppColors.accent,
              ),
              _AcademicKpiCard(
                title: 'Programs',
                value: '$programsCount',
                primaryStat: 'With head: $headsCount',
                secondaryStat: programsWithoutHead > 0
                    ? 'Missing head: $programsWithoutHead'
                    : 'All programs led',
                isWarning: programsWithoutHead > 0,
                icon: Icons.school_rounded,
                iconColor: Colors.indigo,
              ),
              _AcademicKpiCard(
                title: 'Total Students',
                value: totalStudents >= 1000
                    ? '${(totalStudents / 1000).toStringAsFixed(1)}k'
                    : '$totalStudents',
                primaryStat:
                    'Organizations: ${stats['totalOrgs'] ?? 0}',
                secondaryStat: campusesCount > 0
                    ? 'Avg ${(totalStudents / campusesCount).round()} per campus'
                    : 'No campuses yet',
                icon: Icons.people_outline_rounded,
                iconColor: Colors.teal,
              ),
            ],
          );
        },
      ),
      loading: () => const Center(child: FlickrLoader()),
      error: (e, s) => Center(child: Text('Error loading stats: $e')),
    );
  }
}

class _AcademicKpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String primaryStat;
  final String secondaryStat;
  final bool isWarning;
  final IconData icon;
  final Color iconColor;

  const _AcademicKpiCard({
    required this.title,
    required this.value,
    required this.primaryStat,
    required this.secondaryStat,
    this.isWarning = false,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.textGrey,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTextStyles.displaySmall.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            primaryStat,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textDark,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            children: [
              Icon(
                isWarning
                    ? Icons.warning_amber_rounded
                    : Icons.check_circle_outline_rounded,
                size: 14,
                color: isWarning ? Colors.orange : Colors.green,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  secondaryStat,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isWarning ? Colors.orange.shade800 : Colors.green.shade700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
