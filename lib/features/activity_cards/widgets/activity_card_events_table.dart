import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/activity_card_models.dart';
import 'package:intl/intl.dart';

class ActivityCardEventsTable extends StatelessWidget {
  final List<ActivityCardEvent> events;

  const ActivityCardEventsTable({
    super.key,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(
            'MANDATORY EVENTS COMPLIANCE',
            style: AppTextStyles.labelSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.grey.shade100),
            child: DataTable(
              columnSpacing: AppSpacing.lg,
              headingRowColor: MaterialStateProperty.all(Colors.grey.shade50),
              columns: const [
                DataColumn(label: Text('EVENT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                DataColumn(label: Text('DATE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                DataColumn(label: Text('ATTENDANCE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                DataColumn(label: Text('VERIFIED BY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
              ],
              rows: events.map((event) {
                return DataRow(
                  cells: [
                    DataCell(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(event.title, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)),
                          Text(event.category, style: AppTextStyles.labelSmall.copyWith(fontSize: 9)),
                        ],
                      ),
                    ),
                    DataCell(Text(DateFormat('MMM d, yyyy').format(event.date), style: AppTextStyles.labelSmall)),
                    DataCell(_AttendanceStatusBadge(status: event.attendanceStatus)),
                    DataCell(Text(event.verifiedBy ?? '—', style: AppTextStyles.labelSmall)),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _AttendanceStatusBadge extends StatelessWidget {
  final AttendanceStatus status;

  const _AttendanceStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    String label;

    switch (status) {
      case AttendanceStatus.completed:
        color = Colors.green;
        icon = Icons.check_circle_outline_rounded;
        label = 'Completed';
        break;
      case AttendanceStatus.pending:
        color = Colors.orange;
        icon = Icons.access_time_rounded;
        label = 'Pending';
        break;
      case AttendanceStatus.absent:
        color = Colors.red;
        icon = Icons.cancel_outlined;
        label = 'Absent';
        break;
      case AttendanceStatus.excused:
        color = Colors.blue;
        icon = Icons.info_outline_rounded;
        label = 'Excused';
        break;
      default:
        color = Colors.grey;
        icon = Icons.help_outline_rounded;
        label = 'Unknown';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
