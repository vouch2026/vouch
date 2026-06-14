import 'package:vouch_v2/core/widgets/loaders/flickr_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../../../routes/route_paths.dart';
import '../../users/widgets/user_management_header.dart';
import '../../events/models/event_model.dart';
import '../../events/providers/event_provider.dart';
import '../widgets/governor_event_card.dart';
import '../widgets/governor_past_event_card.dart';

import '../../organizations/providers/workspace_provider.dart';
import '../../events/views/student_events_view.dart';

class GovernorEventsPage extends ConsumerStatefulWidget {
  const GovernorEventsPage({super.key});

  @override
  ConsumerState<GovernorEventsPage> createState() => _GovernorEventsPageState();
}

class _GovernorEventsPageState extends ConsumerState<GovernorEventsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final workspace = ref.watch(workspaceProvider);
    final activeRole = workspace.activeRole?.roleName;
    final isStudentOrMember = activeRole == 'Student' || activeRole == 'Member';
    
    if (isStudentOrMember) {
      return const DashboardLayout(
        title: 'My Events',
        child: StudentEventsView(),
      );
    }

    final canCreateEvent = activeRole == 'Governor' || 
                           activeRole == 'President' || 
                           activeRole == 'Vice Governor' || 
                           activeRole == 'Vice President' || 
                           activeRole == 'Secretary';
    
    final eventsAsync = ref.watch(workspaceEventsProvider);
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;

    return DashboardLayout(
      title: 'Organization Events',
      child: eventsAsync.when(
        data: (events) {
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          
          final todayEvents = events.where((e) {
            final eDate = DateTime(e.eventDate.year, e.eventDate.month, e.eventDate.day);
            return eDate.isAtSameMomentAs(today) && !e.isPastTimeout;
          }).toList();
          
          final upcomingEvents = events.where((e) => e.eventDate.isAfter(today)).toList();
          final pastEvents = events.where((e) => e.isPastTimeout).toList();
          
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? AppSpacing.lg : AppSpacing.xl,
              vertical: isMobile ? AppSpacing.lg : AppSpacing.xl,
            ),
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 8),
                          Text(
                            'Events',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      UserManagementHeader(
                        title: 'Events',
                        subtitle: 'Manage organization events, attendance, and feedback',
                        actions: [
                          if (canCreateEvent)
                            HeaderActionButton(
                              icon: Icons.add_rounded,
                              label: 'Create Event',
                              onPressed: () => context.push(RoutePaths.workspaceCreateEvent),
                              isPrimary: true,
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          isScrollable: true,
                          tabAlignment: TabAlignment.start,
                          labelColor: theme.colorScheme.primary,
                          unselectedLabelColor: Colors.grey[600],
                          dividerColor: Colors.transparent,
                          indicatorColor: theme.colorScheme.primary,
                          indicatorWeight: 3,
                          labelStyle: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold),
                          tabs: const [
                            Tab(text: 'Today'),
                            Tab(text: 'Upcoming'),
                            Tab(text: 'Past'),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                  ),
                ),
              ],
              body: TabBarView(
                controller: _tabController,
                children: [
                  _buildTabView(todayEvents, (event) => GovernorEventCard(event: event), mainAxisExtent: 380),
                  _buildTabView(upcomingEvents, (event) => GovernorEventCard(event: event), mainAxisExtent: 380),
                  _buildTabView(pastEvents, (event) => GovernorPastEventCard(event: event), mainAxisExtent: 200),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: FlickrLoader()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildTabView(List<EventModel> events, Widget Function(EventModel) builder, {required double mainAxisExtent}) {
    if (events.isEmpty) {
      return SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 64),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.calendar_today_outlined, size: 48, color: Colors.grey[400]),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'No events found',
                  style: AppTextStyles.bodyLarge.copyWith(color: Colors.grey[600], fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate dynamic cross axis count matching student_events_view.dart
        int crossAxisCount = 1;
        if (constraints.maxWidth > 1200) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth > 900) {
          crossAxisCount = 3;
        } else if (constraints.maxWidth > 600) {
          crossAxisCount = 2;
        }

        return GridView.builder(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: AppSpacing.lg,
            mainAxisSpacing: AppSpacing.lg,
            // Dynamic aspect ratio based on width to keep card heights reasonable
            mainAxisExtent: mainAxisExtent, 
          ),
          itemCount: events.length,
          itemBuilder: (context, index) => builder(events[index]),
        );
      },
    );
  }
}
