import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/campus_provider.dart';

class CampusTable extends ConsumerWidget {
  const CampusTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campusesAsync = ref.watch(campusesProvider);
    final theme = Theme.of(context);

    return campusesAsync.when(
      data: (campuses) => Card(
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
              DataColumn(label: Text('Campus Name')),
              DataColumn(label: Text('Location')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Actions')),
            ],
            rows: campuses.map((campus) => DataRow(
              cells: [
                DataCell(Text(campus.name, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold))),
                DataCell(Text(campus.location, style: AppTextStyles.bodySmall)),
                DataCell(_StatusBadge(status: campus.status)),
                DataCell(Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.edit_outlined, size: 20), onPressed: () {}),
                    IconButton(icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.red), onPressed: () {}),
                  ],
                )),
              ],
            )).toList(),
          ),
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Text('Error: $e'),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = status == 'active' ? Colors.green : Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
