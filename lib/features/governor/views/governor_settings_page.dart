import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/loaders/flickr_loader.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../../organizations/providers/workspace_provider.dart';
import '../../organizations/providers/organization_provider.dart';
import '../../organizations/models/organization_model.dart';
import '../../organizations/widgets/details/organization_settings_panel.dart';
import '../../../core/providers/connectivity_provider.dart';
import '../../../core/widgets/states/offline_state_view.dart';

class GovernorSettingsPage extends ConsumerWidget {
  const GovernorSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.watch(workspaceProvider);
    final selectedOrg = workspace.selectedOrganization;
    final isLoading = workspace.isLoading;
    final isOffline = ref.watch(connectivityProvider).value == false;

    return DashboardLayout(
      title: 'Organization Settings',
      child: isLoading
          ? const Center(child: FlickrLoader())
          : selectedOrg == null
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
              : ref.watch(organizationProvider(selectedOrg.id)).when(
                    data: (org) {
                      if (org == null) {
                        return const Center(child: Text('Organization not found'));
                      }
                      if (isOffline) {
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
                              child: _buildOfflineBanner(),
                            ),
                            Expanded(
                              child: OrganizationSettingsPanel(org: org),
                            ),
                          ],
                        );
                      }
                      return OrganizationSettingsPanel(org: org);
                    },
                    loading: () => const Center(child: FlickrLoader()),
                    error: (error, stack) {
                      // Fallback: check if we have cached organization in Hive workspaces box
                      final box = Hive.box('workspaces');
                      final cacheKey = 'organization_${selectedOrg.id}';
                      final cached = box.get(cacheKey);
                      if (cached != null) {
                        try {
                          final jsonMap = Map<String, dynamic>.from(cached as Map);
                          final org = OrganizationModel.fromJson(jsonMap);
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
                                child: _buildOfflineBanner(),
                              ),
                              Expanded(
                                child: OrganizationSettingsPanel(org: org),
                              ),
                            ],
                          );
                        } catch (_) {}
                      }

                      if (OfflineStateView.isOfflineError(error)) {
                        return OfflineStateView(
                          onRetry: () => ref.invalidate(organizationProvider(selectedOrg.id)),
                        );
                      }
                      return Center(child: Text('Error: $error'));
                    },
                  ),
    );
  }

  Widget _buildOfflineBanner() {
    return Container(
      width: double.infinity,
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
              'You\'re offline. Showing cached settings.',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.orange.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

