import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/faculty_provider.dart';

class FacultyTable extends ConsumerWidget {
  const FacultyTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final facultiesAsync = ref.watch(facultiesProvider);
    final theme = Theme.of(context);

    return facultiesAsync.when(
      data: (faculties) => Card(
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
              DataColumn(label: Text('Faculty Name')),
              DataColumn(label: Text('Code')),
              DataColumn(label: Text('Dean')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Actions')),
            ],
            rows: faculties.map((faculty) => DataRow(
              cells: [
                DataCell(Text(faculty.name, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold))),
                DataCell(Text(faculty.code, style: AppTextStyles.bodySmall)),
                DataCell(Text(faculty.deanName ?? 'Unassigned', style: AppTextStyles.bodySmall)),
                DataCell(_StatusBadge(status: faculty.status)),
                DataCell(IconButton(icon: const Icon(Icons.more_vert_rounded), onPressed: () {})),
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
