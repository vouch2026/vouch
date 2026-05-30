import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../../users/widgets/user_management_header.dart';

class GovernorCollectionsPage extends ConsumerWidget {
  const GovernorCollectionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DashboardLayout(
      title: 'Collection Management',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserManagementHeader(
              title: 'Collections',
              subtitle: 'Track and manage fee collections and financial inflows',
              actions: [
                HeaderActionButton(
                  icon: Icons.add_chart_rounded,
                  label: 'New Collection',
                  onPressed: () {},
                  isPrimary: true,
                ),
                HeaderActionButton(
                  icon: Icons.file_download_outlined,
                  label: 'Export Report',
                  onPressed: () {},
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
                    Icon(Icons.account_balance_wallet_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: AppSpacing.md),
                    Text(
                      'Financial Collections Module',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      'Monitor real-time collections and student payment statuses.',
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
