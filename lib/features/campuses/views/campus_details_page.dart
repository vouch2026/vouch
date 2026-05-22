import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart';
import '../../../routes/route_paths.dart';

class CampusDetailsPage extends StatelessWidget {
  final String id;
  const CampusDetailsPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      title: 'Campus Management',
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Breadcrumbs
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, 0),
              child: Row(
                children: [
                  Icon(Icons.business_rounded, size: 16, color: AppColors.textGrey.withOpacity(0.5)),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => context.go(RoutePaths.academicStructure),
                    child: Text('Academic Structure', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey)),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.textGrey.withOpacity(0.5)),
                  const SizedBox(width: 8),
                  Text('Campus Details', style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
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
                  _buildDescription(),
                  const SizedBox(height: AppSpacing.xl),
                  _buildFacultiesList(),
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
      height: 200,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: -50,
            right: -50,
            child: Icon(
              Icons.business_rounded,
              size: 250,
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
          offset: const Offset(0, -40),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/logos/vouch.png',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'DORSU Main Campus',
                    style: AppTextStyles.displaySmall.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'ACTIVE',
                      style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textGrey),
                  const SizedBox(width: 4),
                  Text(
                    'Mati City, Davao Oriental',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey),
                  ),
                ],
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: const Text('Edit Campus'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            elevation: 0,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        _DetailStatCard(label: 'Total Faculties', value: '7', icon: Icons.account_balance_rounded, color: AppColors.primary),
        const SizedBox(width: AppSpacing.md),
        _DetailStatCard(label: 'Total Programs', value: '24', icon: Icons.school_rounded, color: AppColors.accent),
        const SizedBox(width: AppSpacing.md),
        _DetailStatCard(label: 'Total Students', value: '12,540', icon: Icons.people_outline_rounded, color: Colors.indigo),
        const SizedBox(width: AppSpacing.md),
        _DetailStatCard(label: 'Organizations', value: '48', icon: Icons.corporate_fare_rounded, color: Colors.teal),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About Campus',
          style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'The Main Campus of Davao Oriental State University (DORSU) is the heart of academic excellence in the region, providing diverse programs in Computing, Engineering, Education, and the Arts.',
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textGrey, height: 1.6),
        ),
      ],
    );
  }

  Widget _buildFacultiesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Associated Faculties',
          style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.md),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.accent,
                  child: Icon(Icons.account_balance_rounded, color: Colors.white, size: 18),
                ),
                title: Text(
                  index == 0 ? 'Faculty of Computing, Engineering and Technology' : 'Faculty of Teacher Education',
                  style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('Mati City, Davao Oriental'),
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
