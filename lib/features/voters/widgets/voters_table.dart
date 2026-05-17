import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/voters_provider.dart';

class VotersTable extends ConsumerWidget {
  const VotersTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final votersAsync = ref.watch(votersProvider);
    final theme = Theme.of(context);

    return votersAsync.when(
      data: (voters) => Card(
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
              DataColumn(label: Text('Student ID')),
              DataColumn(label: Text('Full Name')),
              DataColumn(label: Text('Program')),
              DataColumn(label: Text('Voting Status')),
              DataColumn(label: Text('Actions')),
            ],
            rows: voters.map((v) => DataRow(
              cells: [
                DataCell(Text(v.studentNumber, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold))),
                DataCell(Text(v.fullName, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold))),
                DataCell(Text(v.programName ?? 'N/A', style: AppTextStyles.bodySmall)),
                DataCell(_VotingStatusBadge(status: v.status)),
                DataCell(IconButton(
                  icon: const Icon(Icons.info_outline_rounded, size: 20),
                  onPressed: () {},
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

class _VotingStatusBadge extends StatelessWidget {
  final String status;
  const _VotingStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status.toLowerCase()) {
      case 'voted':
        color = Colors.green;
        break;
      case 'eligible':
        color = Colors.blue;
        break;
      case 'restricted':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
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
