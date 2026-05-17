import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../widgets/program_table.dart';

class ProgramsPage extends StatelessWidget {
  const ProgramsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DashboardLayout(
        title: 'Program Management',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Academic Programs', style: AppTextStyles.titleLarge),
              const SizedBox(height: AppSpacing.md),
              const ProgramTable(),
            ],
          ),
        ),
      ),
    );
  }
}
