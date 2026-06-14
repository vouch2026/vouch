import 'package:vouch_v2/core/widgets/loaders/flickr_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/candidates_provider.dart';

class CandidatesTable extends ConsumerWidget {
  const CandidatesTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final candidatesAsync = ref.watch(candidatesProvider);
    final theme = Theme.of(context);

    return candidatesAsync.when(
      data: (candidates) => Card(
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
              DataColumn(label: Text('Candidate Name')),
              DataColumn(label: Text('Organization')),
              DataColumn(label: Text('Position')),
              DataColumn(label: Text('Votes')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Actions')),
            ],
            rows: candidates.map((c) => DataRow(
              cells: [
                DataCell(Text(c.fullName, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold))),
                DataCell(Text(c.organizationName ?? 'N/A', style: AppTextStyles.bodySmall)),
                DataCell(Text(c.position, style: AppTextStyles.bodySmall)),
                DataCell(Text('${c.votes}', style: AppTextStyles.bodySmall)),
                DataCell(_StatusBadge(status: c.status)),
                DataCell(PopupMenuButton(
                  icon: const Icon(Icons.more_vert_rounded, size: 20),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'approve', child: Text('Approve')),
                    const PopupMenuItem(value: 'reject', child: Text('Reject')),
                    const PopupMenuItem(value: 'platform', child: Text('View Platform')),
                    const PopupMenuItem(value: 'disqualify', child: Text('Disqualify')),
                  ],
                )),
              ],
            )).toList(),
          ),
        ),
      ),
      loading: () => const Center(child: FlickrLoader()),
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
      case 'approved':
        color = Colors.green;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'rejected':
        color = Colors.red;
        break;
      case 'disqualified':
        color = Colors.red.shade900;
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
