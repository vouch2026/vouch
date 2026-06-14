import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/event_model.dart';
import '../providers/event_provider.dart';
import 'student_event_details_page.dart';
import '../widgets/student_past_event_card.dart';
import '../widgets/student_event_card.dart';

class StudentEventsView extends ConsumerStatefulWidget {
  const StudentEventsView({super.key});

  @override
  ConsumerState<StudentEventsView> createState() => _StudentEventsViewState();
}

class _StudentEventsViewState extends ConsumerState<StudentEventsView> with SingleTickerProviderStateMixin {
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
    final eventsAsync = ref.watch(workspaceEventsProvider);

    return eventsAsync.when(
      data: (events) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        
        final todayEvents = events.where((e) {
          final eDate = DateTime(e.eventDate.year, e.eventDate.month, e.eventDate.day);
          return eDate.isAtSameMomentAs(today) && !e.isPastTimeout;
        }).toList();
        
        final upcomingEvents = events.where((e) => e.eventDate.isAfter(today)).toList();
        final pastEvents = events.where((e) => e.isPastTimeout).toList();
        
        return NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Organization Events',
                          style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'View upcoming events and share your highlights',
                          style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Container(
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
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildTabView(todayEvents, (event) => StudentEventCard(event: event), mainAxisExtent: 400),
              _buildTabView(upcomingEvents, (event) => StudentEventCard(event: event), mainAxisExtent: 400),
              _buildTabView(pastEvents, (event) => StudentPastEventCard(event: event), mainAxisExtent: 200),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildTabView(List<EventModel> events, Widget Function(EventModel) builder, {required double mainAxisExtent}) {
    if (events.isEmpty) {
      return Center(
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
      );
    }
    
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 1;
        if (constraints.maxWidth > 1200) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth > 900) {
          crossAxisCount = 3;
        } else if (constraints.maxWidth > 600) {
          crossAxisCount = 2;
        }

        return GridView.builder(
          padding: const EdgeInsets.all(AppSpacing.lg),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: AppSpacing.lg,
            mainAxisSpacing: AppSpacing.lg,
            mainAxisExtent: mainAxisExtent, 
          ),
          itemCount: events.length,
          itemBuilder: (context, index) => builder(events[index]),
        );
      },
    );
  }
}
