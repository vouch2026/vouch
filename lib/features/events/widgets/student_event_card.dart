import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/time_formatter.dart';
import '../../events/models/event_model.dart';
import '../views/student_event_details_page.dart';

class StudentEventCard extends StatefulWidget {
  final EventModel event;

  const StudentEventCard({super.key, required this.event});

  @override
  State<StudentEventCard> createState() => _StudentEventCardState();
}

class _StudentEventCardState extends State<StudentEventCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        transform: _isHovered ? Matrix4.translationValues(0, -4, 0) : Matrix4.identity(),
        child: InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StudentEventDetailsPage(event: widget.event))),
          child: Card(
            elevation: _isHovered ? 8 : 0,
            clipBehavior: Clip.antiAlias,
            shadowColor: theme.colorScheme.primary.withValues(alpha: 0.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: _isHovered ? theme.colorScheme.primary : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                width: _isHovered ? 1.5 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      height: 160,
                      width: double.infinity,
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: _buildEventImage(widget.event.imageUrl),
                    ),
                    if (widget.event.isMandatory)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            'MANDATORY',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.event.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          children: [
                            Icon(Icons.calendar_today_outlined, size: 14, color: theme.colorScheme.primary),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              DateFormat.yMMMMd().format(widget.event.eventDate),
                              style: AppTextStyles.labelMedium.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        _buildInfoRow(context, Icons.login_rounded, 'Time in:', TimeFormatter.formatTimeRange(widget.event.timeInStart, widget.event.timeInEnd)),
                        const SizedBox(height: AppSpacing.xs),
                        _buildInfoRow(context, Icons.logout_rounded, 'Time out:', TimeFormatter.formatTimeRange(widget.event.timeOutStart, widget.event.timeOutEnd)),
                        const SizedBox(height: AppSpacing.md),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StudentEventDetailsPage(event: widget.event))),
                            style: FilledButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('View Details'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.labelMedium.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventImage(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return const Center(child: Icon(Icons.image_outlined, color: Colors.grey, size: 40));
    }
    
    return Image.network(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.broken_image_outlined, size: 32, color: Colors.grey),
            SizedBox(height: 8),
            Text('Image error', style: TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
