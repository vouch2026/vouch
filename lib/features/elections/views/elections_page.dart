import 'package:flutter/material.dart';
import '../../../shared/layouts/dashboard_layout.dart';

class ElectionsPage extends StatelessWidget {
  const ElectionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardLayout(
      title: 'Elections',
      child: Center(child: Text('Elections Management')),
    );
  }
}
