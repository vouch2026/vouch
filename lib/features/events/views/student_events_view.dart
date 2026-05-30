import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/event_model.dart';
import '../providers/event_provider.dart';
import 'student_event_details_page.dart';
import '../widgets/student_rate_event_card.dart';

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
    _tabController = TabController(length: 4, vsync: this);
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
          return eDate.isAtSameMomentAs(today);
        }).toList();
        
        final upcomingEvents = events.where((e) => e.eventDate.isAfter(today)).toList();
        final pastEvents = events.where((e) => e.eventDate.isBefore(today)).toList();
        
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
                          Tab(text: 'Rate'),
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
              _buildTabView(todayEvents, (event) => _StudentEventCard(event: event)),
              _buildTabView(upcomingEvents, (event) => _StudentEventCard(event: event)),
              _buildTabView(pastEvents, (event) => _StudentEventCard(event: event, isPast: true)),
              _buildTabView(pastEvents, (event) => StudentRateEventCard(event: event)),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildTabView(List<EventModel> events, Widget Function(EventModel) builder) {
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
            mainAxisExtent: 400, 
          ),
          itemCount: events.length,
          itemBuilder: (context, index) => builder(events[index]),
        );
      },
    );
  }
}

class _StudentEventCard extends StatelessWidget {
  final EventModel event;
  final bool isPast;

  const _StudentEventCard({required this.event, this.isPast = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StudentEventDetailsPage(event: event))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: event.imageUrl != null
                      ? Image.network(event.imageUrl!, fit: BoxFit.cover)
                      : const Icon(Icons.image_outlined, color: Colors.grey, size: 40),
                ),
                if (event.isMandatory)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'MANDATORY',
                        style: AppTextStyles.labelSmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 14, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat.yMMMMd().format(event.eventDate),
                        style: AppTextStyles.labelMedium.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.shortDescription ?? 'No description available.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StudentEventDetailsPage(event: event))),
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('View Details'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
