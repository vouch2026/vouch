import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_spacing.dart';
import '../../events/models/event_model.dart';
import '../../events/providers/event_provider.dart';
import '../providers/event_feedback_provider.dart';
import '../widgets/officer_rate_event_card.dart';

/// Content of the officer "Rate" tab: every past event with its average,
/// breakdown, and Survey/Results entry points.
class OfficerRateTab extends ConsumerWidget {
  final List<EventModel> pastEvents;

  const OfficerRateTab({super.key, required this.pastEvents});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (pastEvents.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async {
          try {
            await ref.refresh(workspaceEventsProvider.future);
          } catch (_) {}
        },
        child: const SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 64),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star_outline_rounded,
                      size: 48, color: Colors.grey),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    'No past events yet',
                    style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        try {
          await ref.refresh(workspaceEventsProvider.future);
        } catch (_) {}
        for (final e in pastEvents) {
          final id = e.id;
          if (id == null) continue;
          ref.invalidate(eventRatingSummaryProvider(id));
          ref.invalidate(eventResponsesProvider(id));
          ref.invalidate(surveyForEventProvider(id));
        }
      },
      child: LayoutBuilder(
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
              mainAxisExtent: 360,
            ),
            itemCount: pastEvents.length,
            itemBuilder: (context, index) =>
                OfficerRateEventCard(event: pastEvents[index]),
          );
        },
      ),
    );
  }
}
