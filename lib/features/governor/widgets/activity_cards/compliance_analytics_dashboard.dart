import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class ComplianceAnalyticsDashboard extends StatelessWidget {
  const ComplianceAnalyticsDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildKpiGrid(),
          const SizedBox(height: AppSpacing.xl),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _buildComplianceChart()),
              const SizedBox(width: AppSpacing.lg),
              Expanded(flex: 2, child: _buildStatusDistribution()),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildParticipationInsights(),
        ],
      ),
    );
  }

  Widget _buildKpiGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1200 ? 4 : 2;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: AppSpacing.lg,
          mainAxisSpacing: AppSpacing.lg,
          childAspectRatio: 2.5,
          children: [
            _KpiCard(
              title: 'Overall Compliance',
              value: '84.2%',
              icon: Icons.verified_user_rounded,
              color: Colors.green,
              trend: '+2.4%',
            ),
            _KpiCard(
              title: 'Pending Signatures',
              value: '156',
              icon: Icons.pending_actions_rounded,
              color: Colors.orange,
              trend: '-12',
            ),
            _KpiCard(
              title: 'Attendance Rate',
              value: '91%',
              icon: Icons.event_available_rounded,
              color: Colors.blue,
              trend: '+5%',
            ),
            _KpiCard(
              title: 'Rejected Cards',
              value: '12',
              icon: Icons.assignment_return_rounded,
              color: Colors.red,
              trend: 'Requires Action',
            ),
          ],
        );
      },
    );
  }

  Widget _buildComplianceChart() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Clearance Completion Trend', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.xxl),
          SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        if (value.toInt() < days.length) {
                          return Text(days[value.toInt()], style: const TextStyle(fontSize: 10, color: Colors.grey));
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 20),
                      FlSpot(1, 35),
                      FlSpot(2, 28),
                      FlSpot(3, 50),
                      FlSpot(4, 65),
                      FlSpot(5, 80),
                      FlSpot(6, 84),
                    ],
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 4,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withOpacity(0.1),
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

  Widget _buildStatusDistribution() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Status Distribution', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(value: 65, color: Colors.green, title: '65%', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  PieChartSectionData(value: 20, color: AppColors.primary, title: '20%', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  PieChartSectionData(value: 10, color: Colors.orange, title: '10%', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  PieChartSectionData(value: 5, color: Colors.red, title: '5%', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _StatusLegendItem(label: 'Cleared', color: Colors.green),
          _StatusLegendItem(label: 'Partially Signed', color: AppColors.primary),
          _StatusLegendItem(label: 'Pending Requirements', color: Colors.orange),
          _StatusLegendItem(label: 'Rejected', color: Colors.red),
        ],
      ),
    );
  }

  Widget _buildParticipationInsights() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Event Participation Insights', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.lg),
          _ParticipationRow(label: 'General Assembly', rate: 0.95, color: Colors.blue),
          const Divider(height: 24),
          _ParticipationRow(label: 'Leadership Seminar', rate: 0.82, color: Colors.purple),
          const Divider(height: 24),
          _ParticipationRow(label: 'Tech Workshop', rate: 0.88, color: Colors.orange),
          const Divider(height: 24),
          _ParticipationRow(label: 'Community Service', rate: 0.76, color: Colors.green),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String trend;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.trend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
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
                Text(title, style: AppTextStyles.labelSmall.copyWith(color: Colors.grey[600])),
                Text(value, style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
                Text(trend, style: TextStyle(color: trend.startsWith('+') ? Colors.green : (trend.startsWith('-') ? Colors.red : Colors.grey), fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusLegendItem extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusLegendItem({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(label, style: AppTextStyles.labelSmall.copyWith(color: Colors.grey[700])),
        ],
      ),
    );
  }
}

class _ParticipationRow extends StatelessWidget {
  final String label;
  final double rate;
  final Color color;

  const _ParticipationRow({required this.label, required this.rate, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
            Text('${(rate * 100).toInt()}%', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: rate,
            minHeight: 6,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
