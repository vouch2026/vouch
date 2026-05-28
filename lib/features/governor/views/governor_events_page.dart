import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../../users/widgets/user_management_header.dart';
import '../models/governor_event_mock_data.dart';
import '../widgets/governor_event_card.dart';
import '../widgets/governor_past_event_card.dart';
import '../widgets/governor_rate_event_card.dart';

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

    return DashboardLayout(
      title: 'Organization Events',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: UserManagementHeader(
              title: 'Events',
              subtitle: 'Manage organization events, attendance, and feedback',
              actions: [
                HeaderActionButton(
                  icon: Icons.add_rounded,
                  label: 'Create Event',
                  onPressed: () {},
                  isPrimary: true,
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
                border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
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
                  Tab(text: 'Ratings'),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: AppSpacing.md),
          
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTabView(GovernorEventMockData.todayEvents, (event) => GovernorEventCard(event: event)),
                _buildTabView(GovernorEventMockData.upcomingEvents, (event) => GovernorEventCard(event: event)),
                _buildTabView(GovernorEventMockData.pastEvents, (event) => GovernorPastEventCard(event: event)),
                _buildTabView(GovernorEventMockData.ratedEvents, (event) => GovernorRateEventCard(event: event)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabView(List<Map<String, dynamic>> events, Widget Function(Map<String, dynamic>) builder) {
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
        // Calculate dynamic cross axis count
        int crossAxisCount = 1;
        if (constraints.maxWidth > 1200) {
          crossAxisCount = 3;
        } else if (constraints.maxWidth > 700) {
          crossAxisCount = 2;
        }

        return GridView.builder(
          padding: const EdgeInsets.all(AppSpacing.lg),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: AppSpacing.lg,
            mainAxisSpacing: AppSpacing.lg,
            // Dynamic aspect ratio based on width to keep card heights reasonable
            mainAxisExtent: _tabController.index == 3 ? 320 : 380, 
          ),
          itemCount: events.length,
          itemBuilder: (context, index) => builder(events[index]),
        );
      },
    );
  }
}
