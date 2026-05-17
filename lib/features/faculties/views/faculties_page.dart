import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../widgets/faculty_table.dart';

class FacultiesPage extends StatelessWidget {
  const FacultiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DashboardLayout(
        title: 'Faculty Management',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Institutional Faculties', style: AppTextStyles.titleLarge),
              const SizedBox(height: AppSpacing.md),
              const FacultyTable(),
            ],
          ),
        ),
      ),
    );
  }
}
