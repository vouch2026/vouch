import 'package:vouch_v2/core/widgets/loaders/flickr_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../../organizations/providers/workspace_provider.dart';
import '../providers/activity_card_provider.dart';
import 'activity_card_details_page.dart';
import '../../../routes/route_paths.dart';

class ActivityCardRedirector extends ConsumerWidget {
  const ActivityCardRedirector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.watch(workspaceProvider);
    final selectedOrg = workspace.selectedOrganization;
    final cardsAsync = ref.watch(studentActivityCardsProvider);

    return cardsAsync.when(
      data: (cards) {
        if (selectedOrg != null) {
          final card = cards.where((c) => c.organizationId == selectedOrg.id).firstOrNull;
          if (card != null) {
            Future.microtask(() {
              if (context.mounted) {
                context.go('${RoutePaths.activityCards}/${card.organizationId}');
              }
            });
            // Show the page directly while the redirect is happening
            return ActivityCardDetailsPage(id: card.organizationId);
          } else {
            return const DashboardLayout(
              title: 'Activity Card',
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assignment_late_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No activity card found for this organization.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        } else {
          return const DashboardLayout(
            title: 'Activity Card',
            child: Center(
              child: Text('Please select an organization first.'),
            ),
          );
        }
      },
      loading: () => const DashboardLayout(
        title: 'Activity Card',
        child: Center(child: FlickrLoader()),
      ),
      error: (err, _) => DashboardLayout(
        title: 'Activity Card',
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading activity cards: $err'),
              TextButton(
                onPressed: () => ref.refresh(studentActivityCardsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
