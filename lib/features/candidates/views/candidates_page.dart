import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../widgets/candidates_table.dart';

class CandidatesPage extends StatelessWidget {
  const CandidatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      title: 'Candidates',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Candidate Management', style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
            Text('Track candidate applications, platforms, and disqualifications', 
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey[600])),
            const SizedBox(height: AppSpacing.xl),
            const CandidatesTable(),
          ],
        ),
      ),
    );
  }
}
