import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/sidebar/app_sidebar.dart';
import '../widgets/sidebar/governor_sidebar.dart';
import '../widgets/navbar/profile_dropdown.dart';
import '../../features/auth/providers/auth_provider.dart';

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
    final userProfile = ref.watch(userProfileProvider).value;
    final isGovernor = userProfile?.role == 'governor';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (actions != null) ...actions!,
          const ProfileDropdown(),
        ],
      ),
      drawer: isGovernor ? const GovernorSidebar() : const AppSidebar(),
      body: child,
    );
  }
}
