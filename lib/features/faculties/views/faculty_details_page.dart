import 'package:flutter/material.dart';
import '../../../shared/layouts/dashboard_layout.dart';

class FacultyDetailsPage extends StatelessWidget {
  final String id;
  const FacultyDetailsPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      title: 'Faculty Details',
      child: Center(child: Text('Details for Faculty: $id')),
    );
  }
}
