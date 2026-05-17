import 'package:flutter/material.dart';
import '../../../shared/layouts/dashboard_layout.dart';

class ProgramDetailsPage extends StatelessWidget {
  final String id;
  const ProgramDetailsPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      title: 'Program Details',
      child: Center(child: Text('Details for Program: $id')),
    );
  }
}
