import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/elections_provider.dart';

class ElectionsTable extends ConsumerWidget {
  const ElectionsTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final electionsAsync = ref.watch(electionsProvider);
    final theme = Theme.of(context);

    return electionsAsync.when(
      data: (elections) => Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
        ),
        child: SizedBox(
          width: double.infinity,
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(theme.colorScheme.surfaceVariant.withOpacity(0.3)),
            columns: const [
              DataColumn(label: Text('Election Name')),
              DataColumn(label: Text('Type')),
              DataColumn(label: Text('Voting Period')),
              DataColumn(label: Text('Votes')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Actions')),
            ],
            rows: elections.map((e) => DataRow(
              cells: [
                DataCell(Text(e.name, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold))),
                DataCell(Text(e.type, style: AppTextStyles.bodySmall)),
                DataCell(Text('${e.startTime.day}/${e.startTime.month} - ${e.endTime.day}/${e.endTime.month}', style: AppTextStyles.bodySmall)),
                DataCell(Text('${e.votesCast ?? 0}', style: AppTextStyles.bodySmall)),
                DataCell(_StatusBadge(status: e.status)),
                DataCell(PopupMenuButton(
                  icon: const Icon(Icons.more_vert_rounded, size: 20),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'view', child: Text('View Details')),
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'voters', child: Text('Manage Voters')),
                    const PopupMenuItem(value: 'publish', child: Text('Publish Results')),
                  ],
                )),
              ],
            )).toList(),
          ),
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status.toLowerCase()) {
      case 'ongoing':
        color = Colors.green;
        break;
      case 'upcoming':
        color = Colors.blue;
        break;
      case 'completed':
        color = Colors.grey;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
