import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class LiveElectionMonitoring extends ConsumerWidget {
  const LiveElectionMonitoring({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Live Election Monitoring', style: AppTextStyles.titleLarge),
            _LiveIndicator(),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 900;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: _buildMainMonitor(context),
                ),
                if (isWide) ...[
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    flex: 1,
                    child: _buildActivityFeed(context),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildMainMonitor(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            _MonitoringRow(label: 'Total Votes Cast', value: '8,450', subValue: '+12 in last min'),
            const Divider(height: AppSpacing.xl),
            _MonitoringRow(label: 'Active Voting Sessions', value: '142', subValue: 'Currently logged in'),
            const Divider(height: AppSpacing.xl),
            _MonitoringRow(label: 'Voter Turnout', value: '68.5%', subValue: 'Target: 75%'),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityFeed(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text('Activity Feed', style: AppTextStyles.titleSmall),
          ),
          const Divider(height: 1),
          SizedBox(
            height: 200,
            child: ListView.separated(
              itemCount: 5,
              separatorBuilder: (c, i) => const Divider(height: 1, indent: AppSpacing.md),
              itemBuilder: (c, i) => ListTile(
                dense: true,
                leading: const Icon(Icons.how_to_vote_rounded, size: 16, color: Colors.blue),
                title: Text('Vote cast in FCET Council', style: AppTextStyles.bodySmall),
                subtitle: const Text('2 seconds ago', style: TextStyle(fontSize: 10)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MonitoringRow extends StatelessWidget {
  final String label;
  final String value;
  final String subValue;

  const _MonitoringRow({required this.label, required this.value, required this.subValue});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey[600])),
            const SizedBox(height: 4),
            Text(subValue, style: const TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
          ],
        ),
        Text(value, style: AppTextStyles.headlineMedium.copyWith(fontWeight: FontWeight.bold, color: Colors.blue)),
      ],
    );
  }
}

class _LiveIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          const Text('LIVE MONITORING', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
