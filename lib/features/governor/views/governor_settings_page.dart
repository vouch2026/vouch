import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/loaders/flickr_loader.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../../organizations/providers/workspace_provider.dart';
import '../../organizations/widgets/details/organization_settings_panel.dart';
import '../../users/widgets/user_management_header.dart';

class GovernorSettingsPage extends ConsumerWidget {
  const GovernorSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.watch(workspaceProvider);
    final org = workspace.selectedOrganization;
    final isLoading = workspace.isLoading;

    return DashboardLayout(
      title: 'Organization Settings',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const UserManagementHeader(
              title: 'Settings',
              subtitle: 'Configure your organization profile and preferences',
              actions: [],
            ),
            const SizedBox(height: AppSpacing.xl),
            
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.0),
                  child: FlickrLoader(),
                ),
              )
            else if (org == null)
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    children: [
                      Icon(Icons.business_rounded, size: 48, color: Colors.grey.shade300),
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
            else
              OrganizationSettingsPanel(org: org),
          ],
        ),
      ),
    );
  }
}
