import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../activity_cards/models/activity_card_models.dart';

class ComplianceAnalyticsDashboard extends StatelessWidget {
  final List<ActivityCard> cards;

  const ComplianceAnalyticsDashboard({super.key, required this.cards});

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) {
      return const Center(child: Text('No data available for analytics'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildKpiGrid(),
          const SizedBox(height: AppSpacing.xl),
          LayoutBuilder(builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 800;
            if (isMobile) {
              return Column(
                children: [
                  _buildComplianceChart(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildStatusDistribution(),
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _buildComplianceChart()),
                const SizedBox(width: AppSpacing.lg),
                Expanded(flex: 2, child: _buildStatusDistribution()),
              ],
            );
          }),
          const SizedBox(height: AppSpacing.xl),
          _buildParticipationInsights(),
        ],
      ),
    );
  }

  Widget _buildKpiGrid() {
    final overallCompliance = cards.isEmpty ? 0.0 : cards.map((c) => c.completionPercentage).reduce((a, b) => a + b) / cards.length;
    final pendingSignatures = cards.fold(0, (sum, c) => sum + c.signatures.where((s) => s.status == SignatureStatus.pending).length);
    final totalEvents = cards.fold(0, (sum, c) => sum + c.events.length);
    final attendedEvents = cards.fold(0, (sum, c) => sum + c.events.where((e) => e.attendanceStatus == AttendanceStatus.completed).length);
    final attendanceRate = totalEvents == 0 ? 0.0 : attendedEvents / totalEvents;
    final rejectedCards = cards.where((c) => c.status == ActivityCardStatus.rejected).length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1200 ? 4 : (constraints.maxWidth > 600 ? 2 : 1);
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: AppSpacing.lg,
          mainAxisSpacing: AppSpacing.lg,
          childAspectRatio: constraints.maxWidth > 600 ? 2.5 : 3.5,
          children: [
            _KpiCard(
              title: 'Overall Compliance',
              value: '${(overallCompliance * 100).toStringAsFixed(1)}%',
              icon: Icons.verified_user_rounded,
              color: Colors.green,
              trend: 'Based on ${cards.length} students',
            ),
            _KpiCard(
              title: 'Pending Signatures',
              value: '$pendingSignatures',
              icon: Icons.pending_actions_rounded,
              color: Colors.orange,
              trend: 'Action required',
            ),
            _KpiCard(
              title: 'Attendance Rate',
              value: '${(attendanceRate * 100).toStringAsFixed(1)}%',
              icon: Icons.event_available_rounded,
              color: Colors.blue,
              trend: '$attendedEvents/$totalEvents scans',
            ),
            _KpiCard(
              title: 'Rejected Cards',
              value: '$rejectedCards',
              icon: Icons.assignment_return_rounded,
              color: Colors.red,
              trend: 'Requires review',
            ),
          ],
        );
      },
    );
  }

  Widget _buildComplianceChart() {
    // Group students by completion ranges
    final ranges = [0, 0, 0, 0, 0]; // 0-20, 21-40, 41-60, 61-80, 81-100
    for (var card in cards) {
      final p = card.completionPercentage * 100;
      if (p <= 20) ranges[0]++;
      else if (p <= 40) ranges[1]++;
      else if (p <= 60) ranges[2]++;
      else if (p <= 80) ranges[3]++;
      else ranges[4]++;
    }

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
          Text('Compliance Distribution', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.xxl),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const labels = ['0-20%', '21-40%', '41-60%', '61-80%', '81-100%'];
                        if (value.toInt() < labels.length) {
                          return Text(labels[value.toInt()], style: const TextStyle(fontSize: 10, color: Colors.grey));
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(ranges.length, (i) => BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: ranges[i].toDouble(),
                      color: AppColors.primary,
                      width: 30,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                    ),
                  ],
                )),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDistribution() {
    final cleared = cards.where((c) => c.status == ActivityCardStatus.cleared).length;
    final partiallySigned = cards.where((c) => c.status == ActivityCardStatus.partiallySigned).length;
    final pending = cards.where((c) => c.status == ActivityCardStatus.pending).length;
    final rejected = cards.where((c) => c.status == ActivityCardStatus.rejected).length;
    final total = cards.length;

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
                  if (cleared > 0) PieChartSectionData(value: cleared.toDouble(), color: Colors.green, title: '${(cleared/total*100).toInt()}%', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  if (partiallySigned > 0) PieChartSectionData(value: partiallySigned.toDouble(), color: AppColors.primary, title: '${(partiallySigned/total*100).toInt()}%', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  if (pending > 0) PieChartSectionData(value: pending.toDouble(), color: Colors.orange, title: '${(pending/total*100).toInt()}%', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  if (rejected > 0) PieChartSectionData(value: rejected.toDouble(), color: Colors.red, title: '${(rejected/total*100).toInt()}%', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _StatusLegendItem(label: 'Cleared ($cleared)', color: Colors.green),
          _StatusLegendItem(label: 'Partially Signed ($partiallySigned)', color: AppColors.primary),
          _StatusLegendItem(label: 'Pending ($pending)', color: Colors.orange),
          _StatusLegendItem(label: 'Rejected ($rejected)', color: Colors.red),
        ],
      ),
    );
  }

  Widget _buildParticipationInsights() {
    // Map event names to their attendance rates
    final eventStats = <String, List<bool>>{};
    for (var card in cards) {
      for (var event in card.events) {
        eventStats.putIfAbsent(event.title, () => []).add(event.attendanceStatus == AttendanceStatus.completed);
      }
    }

    final insights = eventStats.entries.map((e) {
      final total = e.value.length;
      final attended = e.value.where((v) => v).length;
      return {'label': e.key, 'rate': attended / total};
    }).toList();

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
          if (insights.isEmpty) 
            const Text('No event data available')
          else
            ...insights.map((insight) => Column(
              children: [
                _ParticipationRow(
                  label: insight['label'] as String, 
                  rate: insight['rate'] as double, 
                  color: _getRateColor(insight['rate'] as double)
                ),
                if (insight != insights.last) const Divider(height: 24),
              ],
            )),
        ],
      ),
    );
  }

  Color _getRateColor(double rate) {
    if (rate >= 0.9) return Colors.green;
    if (rate >= 0.7) return Colors.blue;
    if (rate >= 0.5) return Colors.orange;
    return Colors.red;
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
