import 'package:vouch_v2/core/widgets/loaders/flickr_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../../organizations/providers/workspace_provider.dart';
import 'governor_dashboard_view.dart';

class WorkspaceDashboardPage extends ConsumerWidget {
  const WorkspaceDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.watch(workspaceProvider);
    final selectedOrg = workspace.selectedOrganization;

    return DashboardLayout(
      key: ValueKey(selectedOrg?.id ?? 'global-workspace'),
      title: 'Workspace Command Center',
      child: workspace.isLoading 
          ? const Center(child: FlickrLoader())
          : const GovernorDashboardView(),
    );
  }
}
