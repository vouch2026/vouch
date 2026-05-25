import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/academic_kpi_section.dart';
import '../widgets/academic_hierarchy_view.dart';
import '../widgets/modals/create_campus_modal.dart';
import '../widgets/modals/create_faculty_modal.dart';
import '../widgets/modals/create_program_modal.dart';
import '../widgets/modals/manage_terms_modal.dart';
import '../providers/term_provider.dart';
import '../models/academic_term_model.dart';

class AcademicStructurePage extends ConsumerWidget {
  const AcademicStructurePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTermAsync = ref.watch(activeTermProvider);

    return DashboardLayout(
      title: 'Academic Structure',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, activeTermAsync),
            const SizedBox(height: AppSpacing.xl),
            const AcademicKpiSection(),
            const SizedBox(height: AppSpacing.xl),
            const AcademicHierarchyView(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AsyncValue<AcademicTermModel?> activeTermAsync) {
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
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Academic Structure',
                            style: AppTextStyles.displaySmall.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                              fontSize: isMobile ? 24 : 36,
                            ),
                          ),
                          if (!isMobile) ...[
                            const SizedBox(width: AppSpacing.md),
                            activeTermAsync.when(
                              data: (term) => term != null
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.event_available_rounded, size: 16, color: AppColors.primary),
                                          const SizedBox(width: 8),
                                          Text(
                                            '${term.academicYear} - ${term.semester}',
                                            style: AppTextStyles.labelLarge.copyWith(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : const SizedBox(),
                              loading: () => const SizedBox(),
                              error: (_, __) => const SizedBox(),
                            ),
                          ],
                        ],
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
                      if (isMobile) ...[
                        const SizedBox(height: 8),
                        activeTermAsync.when(
                          data: (term) => term != null
                              ? Text(
                                  'Current: ${term.academicYear} - ${term.semester}',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : const SizedBox(),
                          loading: () => const SizedBox(),
                          error: (_, __) => const SizedBox(),
                        ),
                      ],
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
                  const SizedBox(width: AppSpacing.md),
                  _QuickActionButton(
                    icon: Icons.calendar_month_rounded,
                    label: 'Manage Terms',
                    onPressed: () => showDialog(
                      context: context,
                      builder: (context) => const ManageTermsModal(),
                    ),
                    color: Colors.teal,
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
