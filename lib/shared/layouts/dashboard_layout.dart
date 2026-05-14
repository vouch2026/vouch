import 'package:flutter/material.dart';
import '../widgets/sidebar/app_sidebar.dart';

class DashboardLayout extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
      ),
      drawer: const AppSidebar(),
      body: child,
    );
  }
}
