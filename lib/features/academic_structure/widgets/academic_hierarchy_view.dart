import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../campuses/providers/campus_provider.dart';
import '../../faculties/providers/faculty_provider.dart';
import '../../programs/providers/program_provider.dart';
import '../../campuses/models/campus_model.dart';
import '../../faculties/models/faculty_model.dart';
import '../../programs/models/program_model.dart';

class AcademicHierarchyView extends ConsumerStatefulWidget {
  const AcademicHierarchyView({super.key});

  @override
  ConsumerState<AcademicHierarchyView> createState() => _AcademicHierarchyViewState();
}

class _AcademicHierarchyViewState extends ConsumerState<AcademicHierarchyView> {
  final Set<String> _expandedCampuses = {};

  void _toggleCampus(String id) {
    setState(() {
      if (_expandedCampuses.contains(id)) {
        _expandedCampuses.remove(id);
      } else {
        _expandedCampuses.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final campusesAsync = ref.watch(campusesProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Institutional Hierarchy',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      'Expand to view faculties and programs',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () => setState(() => _expandedCampuses.clear()),
                  icon: const Icon(Icons.unfold_less_rounded, size: 20),
                  label: const Text('Collapse All'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          campusesAsync.when(
            data: (campuses) => ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: campuses.length,
              itemBuilder: (context, index) {
                final campus = campuses[index];
                return _CampusNode(
                  campus: campus,
                  isExpanded: _expandedCampuses.contains(campus.id),
                  onTap: () => _toggleCampus(campus.id),
                );
              },
            ),
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(AppSpacing.xl), child: CircularProgressIndicator())),
            error: (e, s) => Center(child: Padding(padding: EdgeInsets.all(AppSpacing.xl), child: Text('Error: $e'))),
          ),
        ],
      ),
    );
  }
}

class _CampusNode extends ConsumerWidget {
  final CampusModel campus;
  final bool isExpanded;
  final VoidCallback onTap;

  const _CampusNode({
    required this.campus,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final facultiesAsync = ref.watch(facultiesByCampusProvider(campus.id));

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return Column(
          children: [
            ListTile(
              onTap: onTap,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.business_rounded, color: AppColors.primary),
              ),
              title: Text(
                campus.name,
                style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(campus.location, style: AppTextStyles.labelMedium),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  facultiesAsync.when(
                    data: (faculties) {
                       return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!isMobile) ...[
                            _StatBadge(label: '${faculties.length} Faculties', color: AppColors.accent),
                            const SizedBox(width: 16),
                          ],
                          Icon(
                            isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                            color: AppColors.textGrey,
                          ),
                        ],
                      );
                    },
                    loading: () => const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                    error: (e, s) => const Icon(Icons.error_outline, color: Colors.red, size: 20),
                  ),
                ],
              ),
            ),
            if (isExpanded)
              Padding(
                padding: EdgeInsets.only(left: isMobile ? 32 : 64, right: AppSpacing.lg),
                child: facultiesAsync.when(
                  data: (faculties) => Column(
                    children: faculties.map((f) => _FacultyNode(faculty: f)).toList(),
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (e, s) => const SizedBox.shrink(),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _FacultyNode extends ConsumerStatefulWidget {
  final FacultyModel faculty;

  const _FacultyNode({required this.faculty});

  @override
  ConsumerState<_FacultyNode> createState() => _FacultyNodeState();
}

class _FacultyNodeState extends ConsumerState<_FacultyNode> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final programsAsync = ref.watch(programsByFacultyProvider(widget.faculty.id));

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 500;

        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.05)),
          ),
          child: Column(
            children: [
              ListTile(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                dense: true,
                leading: const Icon(Icons.account_balance_rounded, color: AppColors.accent, size: 20),
                title: Text(
                  '${widget.faculty.name} (${widget.faculty.code})',
                  style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text('Dean: ${widget.faculty.deanName ?? "Unassigned"}', style: AppTextStyles.labelSmall),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    programsAsync.when(
                      data: (programs) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!isMobile) ...[
                              _StatBadge(label: '${programs.length} Programs', color: Colors.grey.shade100, textColor: Colors.grey.shade700),
                              const SizedBox(width: 8),
                            ],
                            Icon(
                              _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                              size: 18,
                              color: AppColors.textGrey,
                            ),
                          ],
                        );
                      },
                      loading: () => const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                      error: (e, s) => const Icon(Icons.error_outline, size: 16),
                    ),
                  ],
                ),
              ),
              if (_isExpanded)
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 0, 12, 12),
                  child: programsAsync.when(
                    data: (programs) => Column(
                      children: programs.map((p) => _ProgramNode(program: p)).toList(),
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, s) => Text('Error: $e'),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ProgramNode extends StatelessWidget {
  final ProgramModel program;

  const _ProgramNode({required this.program});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              program.name,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textDark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.edit_outlined, size: 14),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color? textColor;

  const _StatBadge({
    required this.label,
    required this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: textColor == null ? color.withValues(alpha: 0.1) : color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: textColor ?? color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
