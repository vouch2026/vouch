import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../widgets/voters_table.dart';

class VotersPage extends StatelessWidget {
  const VotersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      title: 'Voters',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Voter Monitoring', style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
            Text('Monitor voter eligibility, registration, and participation', 
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey[600])),
            const SizedBox(height: AppSpacing.xl),
            const VotersTable(),
          ],
        ),
      ),
    );
  }
}
