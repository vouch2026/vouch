import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/sidebar/app_sidebar.dart';
import '../widgets/navbar/profile_dropdown.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (actions != null) ...actions!,
          const ProfileDropdown(),
        ],
      ),
      drawer: const AppSidebar(),
      body: child,
    );
  }
}
