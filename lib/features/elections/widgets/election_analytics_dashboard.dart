import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class ElectionAnalyticsDashboard extends StatelessWidget {
  const ElectionAnalyticsDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Election Analytics', style: AppTextStyles.titleLarge),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _ChartCard(
                title: 'Voter Turnout Trends',
                child: _LineChart(),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              flex: 1,
              child: _ChartCard(
                title: 'Election Type Distribution',
                child: _DonutChart(),
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

class _LineChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const periods = ['W1', 'W2', 'W3', 'W4', 'W5'];
                if (value.toInt() < periods.length) {
                  return Text(periods[value.toInt()], style: AppTextStyles.bodySmall);
                }
                return const Text('');
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: [
              const FlSpot(0, 45),
              const FlSpot(1, 52),
              const FlSpot(2, 48),
              const FlSpot(3, 65),
              const FlSpot(4, 78),
            ],
            isCurved: true,
            color: theme.colorScheme.primary,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: theme.colorScheme.primary.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }
}

class _DonutChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: [
          PieChartSectionData(color: Colors.blue, value: 40, title: 'Org', radius: 50, titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
          PieChartSectionData(color: Colors.green, value: 25, title: 'SSC', radius: 50, titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
          PieChartSectionData(color: Colors.orange, value: 20, title: 'Dept', radius: 50, titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
          PieChartSectionData(color: Colors.red, value: 15, title: 'COM', radius: 50, titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }
}
