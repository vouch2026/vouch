import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../routes/route_paths.dart';
import '../../announcements/models/announcement_model.dart';
import '../../organizations/providers/workspace_provider.dart';

class GovernorAnnouncementCard extends ConsumerStatefulWidget {
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
  ConsumerState<GovernorAnnouncementCard> createState() => _GovernorAnnouncementCardState();
}

class _GovernorAnnouncementCardState extends ConsumerState<GovernorAnnouncementCard> {

  Future<void> _launchUrl(String url) async {
    String formattedUrl = url.trim();
    if (formattedUrl.isNotEmpty) {
      if (!formattedUrl.contains('://')) {
        formattedUrl = 'https://$formattedUrl';
      }
      try {
        final uri = Uri.parse(formattedUrl);
        if (!await launchUrl(uri)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not launch $formattedUrl')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid URL: $formattedUrl')),
          );
        }
      }
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final workspace = ref.watch(workspaceProvider);
    final activeRole = workspace.activeRole?.roleName;
    final canManage = activeRole != 'Student' && activeRole != 'Member';
    
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.announcement.imageUrl != null)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                widget.announcement.imageUrl!,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    _CategoryBadge(category: widget.announcement.type),
                    const Spacer(),
                    Text(
                      widget.announcement.createdAt != null 
                        ? DateFormat.yMMMd().format(widget.announcement.createdAt!)
                        : '',
                      style: AppTextStyles.labelSmall.copyWith(color: Colors.grey[600]),
                    ),
                    if (canManage) ...[
                      const SizedBox(width: AppSpacing.sm),
                      _buildOptionsMenu(),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  widget.announcement.title,
                  style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  widget.announcement.content,
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey[800], height: 1.5),
                  maxLines: widget.announcement.imageUrl != null ? 3 : 6,
                  overflow: TextOverflow.ellipsis,
                ),
                
                if (widget.announcement.linkUrls != null && widget.announcement.linkUrls!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  ...widget.announcement.linkUrls!.map((link) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.1)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.link_rounded, size: 16, color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _launchUrl(link),
                              child: Text(
                                link,
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () => _copyToClipboard(link),
                            icon: const Icon(Icons.copy_rounded, size: 14),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                    ),
                  )),
                ],
                
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
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsMenu() {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      icon: const Icon(Icons.more_vert_rounded, size: 20),
      onSelected: (val) {
        if (val == 'pin') widget.onPin?.call();
        if (val == 'edit') {
          context.push(RoutePaths.workspaceCreateAnnouncement, extra: widget.announcement);
        }
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
              SizedBox(width: 8),
              Text('Edit Announcement'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
              SizedBox(width: 8),
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
      case 'fees':
        color = Colors.orange;
        break;
      case 'academic':
        color = Colors.purple;
        break;
      default:
        color = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        category.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }
}
