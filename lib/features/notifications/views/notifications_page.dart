import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../controllers/notification_controller.dart';
import '../widgets/notification_tile.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import 'package:vouch_v2/core/widgets/loaders/flickr_loader.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

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

    return DashboardLayout(
      title: 'Notifications',
      child: Column(
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

          // Notification List Area
          Expanded(
            child: notificationsAsync.when(
              data: (notifications) {
                if (notifications.isEmpty) {
                  return _buildEmptyState();
                }

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildFilteredList(notifications, 'all'),
                    _buildFilteredList(notifications, 'unread'),
                    _buildFilteredList(notifications, 'personal'),
                    _buildFilteredList(notifications, 'academic'),
                  ],
                );
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
          ),
        ],
      ),
    );
  }

  Widget _buildFilteredList(dynamic notificationsList, String filterType) {
    final List<dynamic> list = List.from(notificationsList);
    List<dynamic> filtered = [];

    switch (filterType) {
      case 'unread':
        filtered = list.where((n) => !n.isRead).toList();
        break;
      case 'personal':
        filtered = list.where((n) => n.notificationType == 'personal').toList();
        break;
      case 'academic':
        filtered = list
            .where((n) =>
                n.notificationType == 'program' ||
                n.notificationType == 'faculty' ||
                n.notificationType == 'campus')
            .toList();
        break;
      case 'all':
      default:
        filtered = list;
        break;
    }

    if (filtered.isEmpty) {
      return _buildEmptyState(message: 'No notifications found in this filter.');
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final notification = filtered[index];
        return NotificationTile(
          notification: notification,
          onTap: () {
            ref.read(notificationControllerProvider.notifier).markAsRead(notification.id);
            if (notification.actionRoute != null && notification.actionRoute!.isNotEmpty) {
              context.go(notification.actionRoute!);
            }
          },
        );
      },
    );
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
