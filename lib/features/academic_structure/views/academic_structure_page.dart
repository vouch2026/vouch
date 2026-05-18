import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/academic_kpi_section.dart';
import '../widgets/academic_hierarchy_view.dart';
import '../widgets/academic_structure_table.dart';
import '../widgets/modals/create_campus_modal.dart';
import '../widgets/modals/create_faculty_modal.dart';
import '../widgets/modals/create_program_modal.dart';

class AcademicStructurePage extends ConsumerWidget {
  const AcademicStructurePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DashboardLayout(
      title: 'Academic Structure',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: AppSpacing.xl),
            const AcademicKpiSection(),
            const SizedBox(height: AppSpacing.xl),
            const AcademicHierarchyView(),
            const SizedBox(height: AppSpacing.xl),
            const AcademicStructureTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 800;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Academic Structure',
                        style: AppTextStyles.displaySmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                          fontSize: isMobile ? 24 : 36,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Manage campuses, faculties, programs, and academic leadership',
                        style: AppTextStyles.titleSmall.copyWith(
                          color: AppColors.textGrey,
                          fontWeight: FontWeight.w400,
                          fontSize: isMobile ? 12 : 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _QuickActionButton(
                    icon: Icons.add_business_rounded,
                    label: 'Add Campus',
                    onPressed: () => showDialog(
                      context: context,
                      builder: (context) => const CreateCampusModal(),
                    ),
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  _QuickActionButton(
                    icon: Icons.account_balance_rounded,
                    label: 'Add Faculty',
                    onPressed: () => showDialog(
                      context: context,
                      builder: (context) => const CreateFacultyModal(),
                    ),
                    color: AppColors.accent,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  _QuickActionButton(
                    icon: Icons.school_rounded,
                    label: 'Add Program',
                    onPressed: () => showDialog(
                      context: context,
                      builder: (context) => const CreateProgramModal(),
                    ),
                    color: Colors.indigo,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color color;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    );
  }
}
