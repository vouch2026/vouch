import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../controllers/notification_controller.dart';
import '../models/notification_model.dart';
import '../widgets/notification_tile.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import 'package:vouch_v2/core/widgets/loaders/flickr_loader.dart';
import 'package:cached_network_image/cached_network_image.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  NotificationModel? _selectedNotification;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationControllerProvider);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 1024;
    final isTablet = size.width >= 600 && size.width < 1024;

    return DashboardLayout(
      title: 'Notifications',
      child: notificationsAsync.when(
        data: (notifications) {
          // If selected notification is no longer in the list (e.g. state reset), clear selection
          if (_selectedNotification != null && 
              !notifications.any((n) => n.id == _selectedNotification!.id)) {
            _selectedNotification = null;
          }

          // Build master-detail split pane for desktop and tablet
          if (isDesktop || isTablet) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Pane: List of notifications (with TabBar & Action Bar)
                Expanded(
                  flex: isDesktop ? 4 : 5,
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        right: BorderSide(color: AppColors.border, width: 1),
                      ),
                    ),
                    child: _buildListPane(notifications),
                  ),
                ),
                
                // Right Pane: Detail View Card
                Expanded(
                  flex: isDesktop ? 6 : 7,
                  child: Container(
                    color: AppColors.background,
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: _buildDetailPane(),
                  ),
                ),
              ],
            );
          }

          // Mobile View: Single Pane List
          return _buildListPane(notifications);
        },
        loading: () => const Center(child: FlickrLoader()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Text(
              'Failed to load notifications: $err',
              style: GoogleFonts.poppins(color: AppColors.error),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the Master List pane containing filter tabs and list items
  Widget _buildListPane(List<NotificationModel> notifications) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filter Tabs
        Container(
          color: AppColors.white,
          child: TabBar(
            controller: _tabController,
            isScrollable: false,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textGrey,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelStyle: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Unread'),
              Tab(text: 'Personal'),
              Tab(text: 'Academic'),
            ],
          ),
        ),

        // Action Bar (Mark all as read)
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                ),
                onPressed: () {
                  ref.read(notificationControllerProvider.notifier).markAllAsRead();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'All notifications marked as read',
                        style: GoogleFonts.poppins(color: AppColors.white),
                      ),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.done_all, size: 16, color: AppColors.primary),
                label: Text(
                  'Mark all as read',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Notifications Tab Content
        Expanded(
          child: notifications.isEmpty
              ? _buildEmptyState()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildFilteredList(notifications, 'all'),
                    _buildFilteredList(notifications, 'unread'),
                    _buildFilteredList(notifications, 'personal'),
                    _buildFilteredList(notifications, 'academic'),
                  ],
                ),
        ),
      ],
    );
  }

  /// Builds the filtered listview
  Widget _buildFilteredList(List<NotificationModel> notificationsList, String filterType) {
    List<NotificationModel> filtered = [];

    switch (filterType) {
      case 'unread':
        filtered = notificationsList.where((n) => !n.isRead).toList();
        break;
      case 'personal':
        filtered = notificationsList.where((n) => n.notificationType == 'personal').toList();
        break;
      case 'academic':
        filtered = notificationsList
            .where((n) =>
                n.notificationType == 'program' ||
                n.notificationType == 'faculty' ||
                n.notificationType == 'campus')
            .toList();
        break;
      case 'all':
      default:
        filtered = notificationsList;
        break;
    }

    if (filtered.isEmpty) {
      return _buildEmptyState(message: 'No notifications found in this filter.');
    }

    final double screenWidth = MediaQuery.of(context).size.width;
    final bool hasSplitPane = screenWidth >= 600;

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final notification = filtered[index];
        final isSelected = _selectedNotification?.id == notification.id;

        return Container(
          color: (hasSplitPane && isSelected)
              ? AppColors.primary.withOpacity(0.08)
              : Colors.transparent,
          child: NotificationTile(
            notification: notification,
            onTap: () {
              // Mark as read
              ref.read(notificationControllerProvider.notifier).markAsRead(notification.id);

              if (hasSplitPane) {
                setState(() {
                  _selectedNotification = notification;
                });
              } else {
                // On mobile, show modal details drawer / sheet or route
                _showMobileDetailsSheet(notification);
              }
            },
          ),
        );
      },
    );
  }

  /// Builds the detail view content on the right side (for Tablet/Desktop)
  Widget _buildDetailPane() {
    if (_selectedNotification == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: 72,
              color: AppColors.textGrey.withOpacity(0.4),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Select a notification',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textGrey,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Choose a notification from the list to view its complete details here.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textGrey,
              ),
            ),
          ],
        ),
      );
    }

    final n = _selectedNotification!;
    final targetColor = _getTargetColor(n.notificationType);

    return Card(
      elevation: 0,
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                if (n.metadata['scope_logo'] != null && (n.metadata['scope_logo'] as String).isNotEmpty) ...[
                  CachedNetworkImage(
                    imageUrl: n.metadata['scope_logo'] as String,
                    imageBuilder: (context, imageProvider) => Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                      ),
                    ),
                    placeholder: (context, url) => const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    errorWidget: (context, url, error) => const Icon(
                      Icons.broken_image,
                      size: 24,
                      color: AppColors.textGrey,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
                  decoration: BoxDecoration(
                    color: targetColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                  ),
                  child: Text(
                    n.metadata['scope_code'] != null && (n.metadata['scope_code'] as String).isNotEmpty
                        ? (n.metadata['scope_code'] as String).toUpperCase()
                        : n.notificationType.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: targetColor,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.border.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                  ),
                  child: Text(
                    n.category.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textGrey,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormat('MMM d, y • hh:mm a').format(n.createdAt),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Title
            Text(
              n.title,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const Divider(height: AppSpacing.xxl),

            // Content body
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Text(
                  n.content,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    height: 1.6,
                    color: AppColors.textDark.withOpacity(0.85),
                  ),
                ),
              ),
            ),

            // Action Routing Button
            if (n.actionRoute != null && n.actionRoute!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                  ),
                  onPressed: () => context.go(n.actionRoute!),
                  icon: const Icon(Icons.open_in_new, size: 18),
                  label: Text(
                    'View Related Action / Page',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Mobile Details Drawer
  void _showMobileDetailsSheet(NotificationModel n) {
    final targetColor = _getTargetColor(n.notificationType);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radiusXl),
            ),
          ),
          padding: EdgeInsets.only(
            top: AppSpacing.lg,
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: MediaQuery.of(context).padding.bottom + AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bottomsheet handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Badges & Date Row
              Row(
                children: [
                  if (n.metadata['scope_logo'] != null && (n.metadata['scope_logo'] as String).isNotEmpty) ...[
                    CachedNetworkImage(
                      imageUrl: n.metadata['scope_logo'] as String,
                      imageBuilder: (context, imageProvider) => Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                        ),
                      ),
                      placeholder: (context, url) => const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 1.5),
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.broken_image,
                        size: 20,
                        color: AppColors.textGrey,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                    decoration: BoxDecoration(
                      color: targetColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                    ),
                    child: Text(
                      n.metadata['scope_code'] != null && (n.metadata['scope_code'] as String).isNotEmpty
                          ? (n.metadata['scope_code'] as String).toUpperCase()
                          : n.notificationType.toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: targetColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.border.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                    ),
                    child: Text(
                      n.category.toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    DateFormat('MMM d, hh:mm a').format(n.createdAt),
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Title
              Text(
                n.title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const Divider(height: AppSpacing.lg),

              // Scrollable Content
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Text(
                    n.content,
                    style: GoogleFonts.poppins(
                      fontSize: 13.5,
                      height: 1.5,
                      color: AppColors.textDark.withOpacity(0.85),
                    ),
                  ),
                ),
              ),

              // Action Routing Button
              if (n.actionRoute != null && n.actionRoute!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      context.go(n.actionRoute!);
                    },
                    icon: const Icon(Icons.open_in_new, size: 18),
                    label: Text(
                      'View Details',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Color _getTargetColor(String type) {
    switch (type) {
      case 'personal':
        return AppColors.info;
      case 'program':
        return AppColors.warning;
      case 'faculty':
        return AppColors.success;
      case 'campus':
        return AppColors.primary;
      case 'global':
      default:
        return AppColors.textGrey;
    }
  }

  Widget _buildEmptyState({String message = 'All caught up! No notifications here.'}) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.06),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_none_outlined,
                  size: 64,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'No Notifications',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textGrey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
