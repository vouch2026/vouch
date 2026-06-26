import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/loaders/flickr_loader.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../../organizations/providers/workspace_provider.dart';
import '../../organizations/widgets/details/organization_settings_panel.dart';

class GovernorSettingsPage extends ConsumerWidget {
  const GovernorSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.watch(workspaceProvider);
    final org = workspace.selectedOrganization;
    final isLoading = workspace.isLoading;

    return DashboardLayout(
      title: 'Organization Settings',
      child: isLoading
          ? const Center(child: FlickrLoader())
          : org == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.business_rounded, size: 48, color: Colors.grey),
                        const SizedBox(height: AppSpacing.md),
                        const Text(
                          'No Active Organization Selected',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Please select an organization workspace from the dashboard to configure settings.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                )
              : OrganizationSettingsPanel(org: org),
    );
  }
}
