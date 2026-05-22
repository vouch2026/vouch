import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart';
import '../../../routes/route_paths.dart';

class ProgramDetailsPage extends StatelessWidget {
  final String id;
  const ProgramDetailsPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      title: 'Program Management',
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Breadcrumbs
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, 0),
              child: Row(
                children: [
                  Icon(Icons.school_rounded, size: 16, color: AppColors.textGrey.withOpacity(0.5)),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => context.go(RoutePaths.academicStructure),
                    child: Text('Academic Structure', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey)),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.textGrey.withOpacity(0.5)),
                  const SizedBox(width: 8),
                  Text('Program Details', style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildBanner(),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: AppSpacing.xl),
                  _buildStatsGrid(),
                  const SizedBox(height: AppSpacing.xl),
                  _buildOrganizationsList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.indigo,
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: -30,
            right: -30,
            child: Icon(
              Icons.school_rounded,
              size: 200,
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Transform.translate(
          offset: const Offset(0, -30),
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Icon(Icons.school_rounded, size: 40, color: Colors.indigo),
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bachelor of Science in Information Technology',
                style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                'BSIT • Head: Prof. Jane Doe',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: const Text('Edit Program'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.indigo,
            side: const BorderSide(color: Colors.indigo),
            elevation: 0,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        _DetailStatCard(label: 'Total Students', value: '350', icon: Icons.people_outline_rounded, color: Colors.indigo),
        const SizedBox(width: AppSpacing.md),
        _DetailStatCard(label: 'Active Orgs', value: '3', icon: Icons.corporate_fare_rounded, color: Colors.teal),
        const SizedBox(width: AppSpacing.md),
        _DetailStatCard(label: 'Participation', value: '94%', icon: Icons.trending_up_rounded, color: Colors.green),
      ],
    );
  }

  Widget _buildOrganizationsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Program Organizations',
          style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.md),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 2,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.indigo.withValues(alpha: 0.1),
                  child: Text(index == 0 ? 'CS' : 'ITS', style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
                ),
                title: Text(
                  index == 0 ? 'Computer Science Society' : 'IT Students Society',
                  style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('Academic Organization'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {},
              ),
            );
          },
        ),
      ],
    );
  }
}

class _DetailStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _DetailStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: AppSpacing.md),
            Text(
              value,
              style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.textGrey),
            ),
          ],
        ),
      ),
    );
  }
}
