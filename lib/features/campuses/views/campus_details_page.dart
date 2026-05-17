import 'package:flutter/material.dart';
import '../../../shared/layouts/dashboard_layout.dart';

class CampusDetailsPage extends StatelessWidget {
  final String id;
  const CampusDetailsPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      title: 'Campus Details',
      child: Center(child: Text('Details for Campus: $id')),
    );
  }
}
