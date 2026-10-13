import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart';
import '../../schools/providers/school_provider.dart';
import '../../campuses/providers/campus_provider.dart';
import '../../faculties/providers/faculty_provider.dart';
import '../../programs/providers/program_provider.dart';
import '../providers/academic_stats_provider.dart';
import '../widgets/academic_kpi_section.dart';
import '../widgets/academic_hierarchy_view.dart';
import '../widgets/academic_structure_table.dart';
import '../widgets/school_header_card.dart';
import '../widgets/modals/create_campus_modal.dart';
import '../widgets/modals/create_school_modal.dart';
import '../widgets/modals/create_faculty_modal.dart';
import '../widgets/modals/create_program_modal.dart';
import '../widgets/modals/manage_terms_modal.dart';
import '../providers/term_provider.dart';
import '../models/academic_term_model.dart';

enum _StructureView { hierarchy, directory }

class AcademicStructurePage extends ConsumerStatefulWidget {
  const AcademicStructurePage({super.key});

  @override
  ConsumerState<AcademicStructurePage> createState() =>
      _AcademicStructurePageState();
}

class _AcademicStructurePageState
    extends ConsumerState<AcademicStructurePage> {
  String? _selectedSchoolId;
  _StructureView _view = _StructureView.hierarchy;

  Future<void> _refreshAll() async {
    ref.invalidate(schoolsProvider);
    ref.invalidate(campusesProvider);
    ref.invalidate(facultiesProvider);
    ref.invalidate(programsProvider);
    ref.invalidate(academicStatsProvider);
    try {
      await Future.wait([
        ref.read(schoolsProvider.future),
        ref.read(campusesProvider.future),
        ref.read(facultiesProvider.future),
        ref.read(programsProvider.future),
      ]);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final activeTermAsync = ref.watch(activeTermProvider);
    final schools = ref.watch(schoolsProvider).valueOrNull ?? [];
    final selectedId =
        _selectedSchoolId ?? (schools.isNotEmpty ? schools.first.id : null);
    final selectedSchool = schools.isEmpty
        ? null
        : schools.firstWhere(
            (s) => s.id == selectedId,
            orElse: () => schools.first,
          );

    return DashboardLayout(
      title: 'Academic Structure',
      child: RefreshIndicator(
        onRefresh: _refreshAll,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, activeTermAsync),
              const SizedBox(height: AppSpacing.xl),
              const AcademicKpiSection(),
              const SizedBox(height: AppSpacing.xl),
              SchoolHeaderCard(
                selectedSchoolId: selectedId,
                onSchoolSelected: (id) =>
                    setState(() => _selectedSchoolId = id),
                onSchoolDeleted: () =>
                    setState(() => _selectedSchoolId = null),
              ),
              const SizedBox(height: AppSpacing.xl),
              _buildViewToggle(),
              const SizedBox(height: AppSpacing.md),
              if (_view == _StructureView.hierarchy)
                AcademicHierarchyView(
                  selectedSchoolId: selectedId,
                  schoolName: selectedSchool?.displayName,
                )
              else
                AcademicStructureTable(
                  selectedSchoolId: selectedId,
                  schoolName: selectedSchool?.displayName,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViewToggle() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        return Row(
          children: [
            Expanded(
              child: SegmentedButton<_StructureView>(
                segments: const [
                  ButtonSegment(
                    value: _StructureView.hierarchy,
                    icon: Icon(Icons.account_tree_outlined, size: 18),
                    label: Text('Hierarchy'),
                  ),
                  ButtonSegment(
                    value: _StructureView.directory,
                    icon: Icon(Icons.table_chart_outlined, size: 18),
                    label: Text('Directory'),
                  ),
                ],
                selected: {_view},
                onSelectionChanged: (selected) =>
                    setState(() => _view = selected.first),
                style: SegmentedButton.styleFrom(
                  visualDensity: isMobile
                      ? VisualDensity.compact
                      : VisualDensity.standard,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(
      BuildContext context, AsyncValue<AcademicTermModel?> activeTermAsync) {
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
                          Flexible(
                            child: Text(
                              'Academic Structure',
                              style: AppTextStyles.displaySmall.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                                fontSize: isMobile ? 24 : 36,
                              ),
                            ),
                          ),
                          if (!isMobile) ...[
                            const SizedBox(width: AppSpacing.md),
                            activeTermAsync.when(
                              data: (term) => term != null
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(
                                            alpha: 0.1),
                                        borderRadius:
                                            BorderRadius.circular(20),
                                        border: Border.all(
                                            color: AppColors.primary.withValues(
                                                alpha: 0.2)),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                              Icons.event_available_rounded,
                                              size: 16,
                                              color: AppColors.primary),
                                          const SizedBox(width: 8),
                                          Text(
                                            '${term.academicYear} - ${term.semester}',
                                            style: AppTextStyles.labelLarge
                                                .copyWith(
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
                        'Manage schools, campuses, faculties, programs, and academic leadership',
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
                    icon: Icons.account_balance_outlined,
                    label: 'Add School',
                    onPressed: () => showDialog(
                      context: context,
                      builder: (context) => const CreateSchoolModal(),
                    ),
                    color: const Color(0xFF0F766E),
                  ),
                  const SizedBox(width: AppSpacing.md),
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
    return FilledButton.tonalIcon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20, color: color),
      label: Text(label),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
