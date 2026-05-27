import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/sidebar/dynamic_sidebar.dart';
import '../widgets/navbar/profile_dropdown.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/organizations/providers/workspace_provider.dart';

class DashboardLayout extends ConsumerWidget {
  final Widget child;
  final String title;
  final List<Widget>? actions;

  const DashboardLayout({
    super.key,
    required this.child,
    required this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.watch(workspaceProvider);
    final selectedOrg = workspace.selectedOrganization;
    final userProfile = ref.watch(userProfileProvider).value;
    final isSuperAdmin = userProfile?.role == 'super_admin';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title),
            if (selectedOrg != null && !isSuperAdmin)
              Text(
                '${selectedOrg.name} • ${workspace.activeRole?.roleName ?? 'Member'}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
          ],
        ),
        actions: [
          if (actions != null) ...actions!,
          const ProfileDropdown(),
        ],
      ),
      drawer: const DynamicSidebar(),
      body: child,
    );
  }
}

