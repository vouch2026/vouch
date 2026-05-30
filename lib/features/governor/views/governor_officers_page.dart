import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../../users/widgets/user_management_header.dart';

class GovernorOfficersPage extends ConsumerWidget {
  const GovernorOfficersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DashboardLayout(
      title: 'Organization Officers',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserManagementHeader(
              title: 'Officers',
              subtitle: 'Manage roles and responsibilities of organization leaders',
              actions: [
                HeaderActionButton(
                  icon: Icons.person_add_rounded,
                  label: 'Assign Officer',
                  onPressed: () {},
                  isPrimary: true,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 64.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.badge_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: AppSpacing.md),
                    Text(
                      'Officer Management Module',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      'This module allows you to assign roles and manage officer terms.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
