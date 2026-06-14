import 'package:vouch_v2/core/widgets/loaders/flickr_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/academic_stats_provider.dart';

class AcademicKpiSection extends ConsumerWidget {
  const AcademicKpiSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(academicStatsProvider);

    return statsAsync.when(
      data: (stats) => LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount = 4;
          if (constraints.maxWidth < 600) {
            crossAxisCount = 1;
          } else if (constraints.maxWidth < 900) {
            crossAxisCount = 2;
          } else if (constraints.maxWidth < 1200) {
            crossAxisCount = 3;
          }

          return GridView.count(
            crossAxisCount: crossAxisCount,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            childAspectRatio: crossAxisCount == 1 ? 2.0 : 1.2,
            children: [
              _AcademicKpiCard(
                title: 'Campuses',
                value: stats['campusesCount'].toString(),
                subtitle: 'Active: ${stats['activeCampuses']}',
                trend: '+0%',
                isPositive: true,
                icon: Icons.business_rounded,
                iconColor: AppColors.primary,
                chartData: const [1, 1, 1, 1, 1, 1, 1],
              ),
              _AcademicKpiCard(
                title: 'Faculties',
                value: stats['facultiesCount'].toString(),
                subtitle: 'Deans: ${stats['deansCount']}',
                trend: '+0%',
                isPositive: true,
                icon: Icons.account_balance_rounded,
                iconColor: AppColors.accent,
                chartData: const [7, 7, 7, 7, 7, 7, 7],
              ),
              _AcademicKpiCard(
                title: 'Programs',
                value: stats['programsCount'].toString(),
                subtitle: 'Heads: ${stats['headsCount']}',
                trend: '+0%',
                isPositive: true,
                icon: Icons.school_rounded,
                iconColor: Colors.indigo,
                chartData: const [20, 21, 22, 22, 23, 24, 24],
              ),
              _AcademicKpiCard(
                title: 'Total Students',
                value: stats['totalStudents'] >= 1000 
                    ? '${(stats['totalStudents'] / 1000).toStringAsFixed(1)}k' 
                    : stats['totalStudents'].toString(),
                subtitle: 'Organizations: ${stats['totalOrgs']}',
                trend: '+0%',
                isPositive: true,
                icon: Icons.people_outline_rounded,
                iconColor: Colors.teal,
                chartData: const [10, 11, 10.5, 12, 11.8, 12.5, 12.5],
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
  final String subtitle;
  final String trend;
  final bool isPositive;
  final IconData icon;
  final Color iconColor;
  final List<double> chartData;

  const _AcademicKpiCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.trend,
    required this.isPositive,
    required this.icon,
    required this.iconColor,
    required this.chartData,
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              Row(
                children: [
                  Icon(
                    isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                    color: isPositive ? Colors.green : Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    trend,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isPositive ? Colors.green.shade700 : Colors.red.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: AppTextStyles.titleSmall.copyWith(
              color: AppColors.textGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: AppTextStyles.displaySmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                    height: 1.0,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text(
                    subtitle,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textGrey.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            height: 30,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: chartData.length.toDouble() - 1,
                minY: chartData.reduce((a, b) => a < b ? a : b) * 0.9,
                maxY: chartData.reduce((a, b) => a > b ? a : b) * 1.1,
                lineBarsData: [
                  LineChartBarData(
                    spots: chartData
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value))
                        .toList(),
                    isCurved: true,
                    color: iconColor,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: iconColor.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
