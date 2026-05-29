import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../announcements/models/announcement_model.dart';

class GovernorAnnouncementCard extends StatefulWidget {
  final AnnouncementModel announcement;
  final VoidCallback? onDelete;
  final VoidCallback? onPin;

  const GovernorAnnouncementCard({
    super.key,
    required this.announcement,
    this.onDelete,
    this.onPin,
  });

  @override
  State<GovernorAnnouncementCard> createState() => _GovernorAnnouncementCardState();
}

class _GovernorAnnouncementCardState extends State<GovernorAnnouncementCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const isPinned = false; // Placeholder
    const category = 'General'; // Placeholder
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: _isHovered ? Matrix4.translationValues(0, -4, 0) : Matrix4.identity(),
        child: Card(
          elevation: _isHovered ? 8 : 0,
          shadowColor: theme.colorScheme.primary.withOpacity(0.15),
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
                    const _CategoryBadge(category: category),
                    const Spacer(),
                    if (isPinned)
                      Icon(Icons.push_pin_rounded, size: 16, color: theme.colorScheme.primary),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      widget.announcement.createdAt != null 
                        ? DateFormat.yMMMd().format(widget.announcement.createdAt!)
                        : '',
                      style: AppTextStyles.labelSmall.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _buildOptionsMenu(),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.announcement.title,
                        style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        widget.announcement.content,
                        style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey[800], height: 1.5),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Text(
                        (widget.announcement.authorName ?? 'A')[0].toUpperCase(),
                        style: TextStyle(color: theme.colorScheme.primary, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'By ${widget.announcement.authorName ?? 'System'}',
                        style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Icon(Icons.remove_red_eye_outlined, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    const Text(
                      '0', // Placeholder
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionsMenu() {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      icon: const Icon(Icons.more_vert_rounded, size: 20),
      onSelected: (val) {
        if (val == 'pin') widget.onPin?.call();
        if (val == 'delete') widget.onDelete?.call();
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'pin',
          child: Row(
            children: [
              Icon(Icons.push_pin_outlined, size: 18),
              SizedBox(width: 8),
              Text('Pin to top'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 18),
              const SizedBox(width: 8),
              Text('Edit Announcement'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
              const SizedBox(width: 8),
              Text('Delete', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final String category;
  const _CategoryBadge({required this.category});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (category.toLowerCase()) {
      case 'urgent':
        color = Colors.red;
        break;
      case 'events':
        color = Colors.blue;
        break;
      default:
        color = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        category.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }
}
