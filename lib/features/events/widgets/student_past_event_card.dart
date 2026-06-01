import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../events/models/event_model.dart';
import '../../attendance/providers/attendance_provider.dart';
import '../views/student_event_details_page.dart';

class StudentPastEventCard extends ConsumerStatefulWidget {
  final EventModel event;

  const StudentPastEventCard({super.key, required this.event});

  @override
  ConsumerState<StudentPastEventCard> createState() => _StudentPastEventCardState();
}

class _StudentPastEventCardState extends ConsumerState<StudentPastEventCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final attendanceAsync = ref.watch(userEventAttendanceProvider(widget.event.id!));
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: _isHovered ? Matrix4.translationValues(0, -4, 0) : Matrix4.identity(),
        child: InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StudentEventDetailsPage(event: widget.event))),
          child: Card(
            elevation: _isHovered ? 8 : 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: _isHovered ? theme.colorScheme.primary : theme.colorScheme.outlineVariant.withOpacity(0.5),
                width: _isHovered ? 1.5 : 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.event.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      attendanceAsync.when(
                        data: (attendance) {
                          final isAbsent = attendance == null || attendance.status == 'Absent';
                          if (!isAbsent) return const SizedBox.shrink();
                          return _StatusBadge(label: 'ABSENT', color: theme.colorScheme.error);
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        DateFormat.yMMMMd().format(widget.event.eventDate),
                        style: AppTextStyles.labelMedium.copyWith(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const Spacer(),
                  attendanceAsync.when(
                    data: (attendance) => Column(
                      children: [
                        _buildTimeRow(
                          context, 
                          Icons.login_rounded, 
                          'Time in:', 
                          attendance?.actualTimeIn != null
                              ? DateFormat.jm().format(attendance!.actualTimeIn!.toLocal())
                              : 'No Record',
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        _buildTimeRow(
                          context, 
                          Icons.logout_rounded, 
                          'Time out:', 
                          attendance?.actualTimeOut != null
                              ? DateFormat.jm().format(attendance!.actualTimeOut!.toLocal())
                              : 'No Record',
                        ),
                      ],
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const Text('Error loading attendance'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeRow(BuildContext context, IconData icon, String label, String? time) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8)),
          ),
          const Spacer(),
          Text(
            time ?? '-',
            style: AppTextStyles.labelMedium.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
