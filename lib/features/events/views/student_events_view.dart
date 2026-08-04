import 'package:vouch_v2/core/widgets/loaders/flickr_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/states/offline_state_view.dart';
import '../../../core/providers/connectivity_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/event_model.dart';
import '../providers/event_provider.dart';
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
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;

    final isOffline = ref.watch(connectivityProvider).value == false;

    return eventsAsync.when(
      data: (events) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        
        final todayEvents = events.where((e) {
          final eDate = DateTime(e.eventDate.year, e.eventDate.month, e.eventDate.day);
          return eDate.isAtSameMomentAs(today) && !e.isPastTimeout;
        }).toList();
        todayEvents.sort((a, b) {
          final dateCompare = a.eventDate.compareTo(b.eventDate);
          if (dateCompare != 0) return dateCompare;
          return a.timeInStart.compareTo(b.timeInStart);
        });
        
        final upcomingEvents = events.where((e) => e.eventDate.isAfter(today)).toList();
        upcomingEvents.sort((a, b) {
          final dateCompare = a.eventDate.compareTo(b.eventDate);
          if (dateCompare != 0) return dateCompare;
          return a.timeInStart.compareTo(b.timeInStart);
        });

        final pastEvents = events.where((e) => e.isPastTimeout).toList();
        pastEvents.sort((a, b) {
          final dateCompare = b.eventDate.compareTo(a.eventDate);
          if (dateCompare != 0) return dateCompare;
          return b.timeOutEnd.compareTo(a.timeOutEnd);
        });
        
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
                    if (isOffline) ...[
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: AppSpacing.md),
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.orange.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.wifi_off_rounded, color: Colors.orange, size: 16),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                "You're offline. Showing cached content.",
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                    Text(
                      'Organization Events',
                      style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'View upcoming events and share your highlights',
                      style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey[600]),
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
                _buildTabView(todayEvents, (event) => StudentEventCard(event: event), mainAxisExtent: 400),
                _buildTabView(upcomingEvents, (event) => StudentEventCard(event: event), mainAxisExtent: 400),
                _buildTabView(pastEvents, (event) => StudentPastEventCard(event: event), mainAxisExtent: 200),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: FlickrLoader()),
      error: (err, _) {
        if (OfflineStateView.isOfflineError(err)) {
          return OfflineStateView(
            onRetry: () => ref.invalidate(workspaceEventsProvider),
          );
        }
        return Center(child: Text('Error: $err'));
      },
    );
  }

  Widget _buildTabView(List<EventModel> events, Widget Function(EventModel) builder, {required double mainAxisExtent}) {
    Widget content;
    if (events.isEmpty) {
      content = const SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 64),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.calendar_today_outlined, size: 48, color: Colors.grey),
                SizedBox(height: AppSpacing.md),
                Text(
                  'No events found',
                  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      content = LayoutBuilder(
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
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
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

    return RefreshIndicator(
      onRefresh: () async {
        try {
          await ref.refresh(workspaceEventsProvider.future);
        } catch (_) {}
      },
      child: content,
    );
  }
}
