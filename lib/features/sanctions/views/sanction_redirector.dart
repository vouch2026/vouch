import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../organizations/providers/workspace_provider.dart';
import '../../../core/permissions/app_permissions.dart';
import 'workspace_sanctions_page.dart';
import 'sanction_profile_page.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/widgets/loaders/flickr_loader.dart';

import '../../../core/widgets/states/offline_state_view.dart';

class SanctionRedirector extends ConsumerWidget {
  const SanctionRedirector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeRole = ref.watch(workspaceProvider).activeRole;
    final isAdviser = activeRole?.roleName.toLowerCase() == 'adviser';
    
    final canManage = (activeRole?.hasAnyPermission([
      AppPermissions.createSanctionRules,
      AppPermissions.receiveSanctionItems,
    ]) ?? false) || isAdviser;

    if (canManage) {
      return const WorkspaceSanctionsPage();
    } else {
      final userProfileAsync = ref.watch(userProfileProvider);
      return userProfileAsync.when(
        data: (userProfile) {
          if (userProfile == null || userProfile.id == null) {
            return const Scaffold(
              body: Center(child: Text('User profile not found.')),
            );
          }
          return SanctionProfilePage(
            studentId: userProfile.id!,
            isPersonalView: true,
          );
        },
        loading: () => const Scaffold(
          body: Center(child: FlickrLoader()),
        ),
        error: (err, _) {
          if (OfflineStateView.isOfflineError(err)) {
            return Scaffold(
              body: OfflineStateView(
                onRetry: () => ref.invalidate(userProfileProvider),
              ),
            );
          }
          return Scaffold(
            body: Center(child: Text('Error: $err')),
          );
        },
      );
    }
  }
}
