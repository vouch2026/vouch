import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class AcademicAnalyticsPanel extends StatelessWidget {
  const AcademicAnalyticsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Academic Analytics', style: AppTextStyles.titleLarge),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _ChartCard(
                title: 'Student Distribution by Campus',
                child: _BarChart(),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              flex: 1,
              child: _ChartCard(
                title: 'Organization Distribution',
                child: _PieChart(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _ChartCard({required this.title, required this.child});

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.titleMedium),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(height: 200, child: child),
          ],
        ),
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BarChart(
      BarChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const campuses = ['Main', 'Banay', 'Cateel', 'San Isidro'];
                if (value.toInt() < campuses.length) {
                  return Text(campuses[value.toInt()], style: AppTextStyles.bodySmall);
                }
                return const Text('');
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: [
          BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 8, color: theme.colorScheme.primary, width: 20, borderRadius: BorderRadius.circular(4))]),
          BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 4, color: theme.colorScheme.secondary, width: 20, borderRadius: BorderRadius.circular(4))]),
          BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 3, color: theme.colorScheme.tertiary, width: 20, borderRadius: BorderRadius.circular(4))]),
          BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 2, color: theme.colorScheme.outline, width: 20, borderRadius: BorderRadius.circular(4))]),
        ],
      ),
    );
  }
}

class _PieChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: [
          PieChartSectionData(color: Colors.blue, value: 45, title: '45%', radius: 50, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
          PieChartSectionData(color: Colors.green, value: 25, title: '25%', radius: 50, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
          PieChartSectionData(color: Colors.orange, value: 20, title: '20%', radius: 50, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
          PieChartSectionData(color: Colors.red, value: 10, title: '10%', radius: 50, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }
}
