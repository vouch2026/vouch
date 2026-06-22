import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/activity_card_models.dart';
import 'package:intl/intl.dart';

class ActivityCardEventsTable extends StatelessWidget {
  final List<ActivityCardEvent> events;
  final bool useHorizontalPadding;

  const ActivityCardEventsTable({
    super.key,
    required this.events,
    this.useHorizontalPadding = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: useHorizontalPadding ? AppSpacing.lg : 0),
          child: const Padding(
            padding: EdgeInsets.only(left: 6.0),
            child: Text(
              'MANDATORY EVENTS COMPLIANCE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.textGrey,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: useHorizontalPadding ? AppSpacing.lg : 0),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.grey.shade100),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: constraints.maxWidth,
                      ),
                      child: DataTable(
                        columnSpacing: AppSpacing.lg,
                        headingRowColor: WidgetStateProperty.all(AppColors.primary.withValues(alpha: 0.04)),
                        columns: [
                          DataColumn(
                            label: Text(
                              'EVENT', 
                              style: AppTextStyles.labelSmall.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'DATE', 
                              style: AppTextStyles.labelSmall.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'STATUS', 
                              style: AppTextStyles.labelSmall.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'VERIFIED BY', 
                              style: AppTextStyles.labelSmall.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                        rows: events.map((event) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(event.title, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.textDark)),
                                    Text(event.category, style: AppTextStyles.labelSmall.copyWith(fontSize: 9, color: AppColors.textGrey)),
                                  ],
                                ),
                              ),
                              DataCell(Text(DateFormat('MMM d, yyyy').format(event.date), style: AppTextStyles.bodySmall.copyWith(color: AppColors.textDark))),
                              DataCell(_AttendanceStatusBadge(status: event.attendanceStatus)),
                              DataCell(Text(event.verifiedBy ?? '—', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textDark))),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
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
        color = AppColors.success;
        icon = Icons.check_circle_outline_rounded;
        label = 'Completed';
        break;
      case AttendanceStatus.sanctionCleared:
        color = AppColors.success;
        icon = Icons.assignment_turned_in_rounded;
        label = 'Sanction Cleared';
        break;
      case AttendanceStatus.pending:
        color = AppColors.warning;
        icon = Icons.access_time_rounded;
        label = 'Pending';
        break;
      case AttendanceStatus.absent:
        color = AppColors.error;
        icon = Icons.cancel_outlined;
        label = 'Absent';
        break;
      case AttendanceStatus.excused:
        color = AppColors.info;
        icon = Icons.info_outline_rounded;
        label = 'Excused';
        break;
      default:
        color = AppColors.textGrey;
        icon = Icons.help_outline_rounded;
        label = 'Unknown';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(color: color, fontWeight: FontWeight.bold, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
