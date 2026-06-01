import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/sidebar/dynamic_sidebar.dart';
import '../widgets/navbar/profile_dropdown.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/organizations/providers/workspace_provider.dart';
import '../../core/providers/sidebar_provider.dart';
import 'responsive_layout.dart';

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
    final isSidebarVisible = ref.watch(sidebarVisibleProvider);
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Scaffold(
      body: Stack(
        children: [
          Row(
            children: [
              if (isDesktop && isSidebarVisible)
                const SizedBox(
                  width: 280,
                  child: DynamicSidebar(),
                ),
              Expanded(
                child: Scaffold(
                  appBar: AppBar(
                    leading: (!isSidebarVisible || !isDesktop)
                        ? IconButton(
                            icon: const Icon(Icons.menu),
                            onPressed: () => ref
                                .read(sidebarVisibleProvider.notifier)
                                .state = true,
                          )
                        : null,
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title),
                        if (selectedOrg != null && !isSuperAdmin)
                          Text(
                            '${selectedOrg.name} • ${workspace.activeRole?.roleName ?? 'Member'}',
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                      ],
                    ),
                    actions: [
                      if (actions != null) ...actions!,
                      const ProfileDropdown(),
                    ],
                  ),
                  body: child,
                ),
              ),
            ],
          ),
          
          // Mobile/Tablet Sidebar Overlay
          if (!isDesktop && isSidebarVisible)
            Stack(
              children: [
                // Scrim
                GestureDetector(
                  onTap: () => ref.read(sidebarVisibleProvider.notifier).state = false,
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.3),
                  ),
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 280,
                      child: DynamicSidebar(),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => ref.read(sidebarVisibleProvider.notifier).state = false,
                        child: Container(
                          color: Colors.transparent,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}

