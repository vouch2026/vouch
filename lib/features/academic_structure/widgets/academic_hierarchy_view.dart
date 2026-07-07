import 'package:vouch_v2/core/widgets/loaders/flickr_loader.dart';
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
import './modals/edit_campus_modal.dart';
import './modals/edit_faculty_modal.dart';
import './modals/edit_program_modal.dart';

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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Institutional Hierarchy',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Expand to view faculties and programs',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.textGrey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
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
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(AppSpacing.xl), child: FlickrLoader())),
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

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Campus?'),
        content: Text('Are you sure you want to delete ${campus.name}? This will also delete all associated faculties and programs.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(campusesProvider.notifier).deleteCampus(campus.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Campus deleted successfully')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting campus: $e')),
          );
        }
      }
    }
  }

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
                vertical: AppSpacing.md, // Increased padding
              ),
              leading: Container(
                width: 56, // Increased size
                height: 56, // Increased size
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16), // More rounded
                ),
                child: campus.logoUrl != null && campus.logoUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          campus.logoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.business_rounded, color: AppColors.primary, size: 28),
                        ),
                      )
                    : const Icon(Icons.business_rounded, color: AppColors.primary, size: 28),
              ),
              title: Text(
                campus.name,
                style: AppTextStyles.titleMedium.copyWith( // Larger font
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              subtitle: Text(
                campus.location, 
                style: AppTextStyles.labelMedium.copyWith(color: AppColors.textGrey),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (context) => EditCampusModal(campus: campus),
                    ),
                    icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.primary),
                    tooltip: 'Edit Campus',
                  ),
                  IconButton(
                    onPressed: () => _confirmDelete(context, ref),
                    icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.red),
                    tooltip: 'Delete Campus',
                  ),
                  const SizedBox(width: 8),
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
                            size: 28,
                          ),
                        ],
                      );
                    },
                    loading: () => const SizedBox(width: 20, height: 20, child: FlickrLoader()),
                    error: (e, s) => const Icon(Icons.error_outline, color: Colors.red, size: 20),
                  ),
                ],
              ),
            ),
            if (isExpanded)
              Padding(
                padding: EdgeInsets.only(left: isMobile ? 32 : 64, right: AppSpacing.lg, bottom: AppSpacing.md),
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

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Faculty?'),
        content: Text('Are you sure you want to delete ${widget.faculty.name}? This will also delete all associated programs.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(facultiesProvider.notifier).deleteFaculty(widget.faculty.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Faculty deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting faculty: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final programsAsync = ref.watch(programsByFacultyProvider(widget.faculty.id));

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 500;

        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              ListTile(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: widget.faculty.logoUrl != null && widget.faculty.logoUrl!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.network(
                            widget.faculty.logoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.account_balance_rounded, color: AppColors.accent, size: 20),
                          ),
                        )
                      : const Icon(Icons.account_balance_rounded, color: AppColors.accent, size: 20),
                ),
                title: Text(
                  '${widget.faculty.name} (${widget.faculty.code})',
                  style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                subtitle: Text('Dean: ${widget.faculty.deanName ?? "Unassigned"}', style: AppTextStyles.labelSmall),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (context) => EditFacultyModal(faculty: widget.faculty),
                      ),
                      icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _confirmDelete,
                      icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
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
                              size: 20,
                              color: AppColors.textGrey,
                            ),
                          ],
                        );
                      },
                      loading: () => const SizedBox(width: 16, height: 16, child: FlickrLoader()),
                      error: (e, s) => const Icon(Icons.error_outline, size: 16),
                    ),
                  ],
                ),
              ),
              if (_isExpanded)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: programsAsync.when(
                    data: (programs) => Column(
                      children: [
                        const Divider(),
                        const SizedBox(height: 8),
                        ...programs.map((p) => _ProgramNode(program: p)).toList(),
                      ],
                    ),
                    loading: () => const Center(child: FlickrLoader()),
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

class _ProgramNode extends ConsumerWidget {
  final ProgramModel program;

  const _ProgramNode({required this.program});

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Program?'),
        content: Text('Are you sure you want to delete ${program.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(programsProvider.notifier).deleteProgram(program.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Program deleted successfully')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting program: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: program.logoUrl != null && program.logoUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      program.logoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.school_rounded, color: AppColors.primary, size: 14),
                    ),
                  )
                : const Icon(Icons.school_rounded, color: AppColors.primary, size: 14),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              program.name,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textDark,
                fontWeight: FontWeight.bold, // Bolder
                fontSize: 14,
              ),
            ),
          ),
          IconButton(
            onPressed: () => showDialog(
              context: context,
              builder: (context) => EditProgramModal(program: program),
            ),
            icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.primary),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            visualDensity: VisualDensity.compact,
            tooltip: 'Edit Program',
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: () => _confirmDelete(context, ref),
            icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Colors.red),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            visualDensity: VisualDensity.compact,
            tooltip: 'Delete Program',
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
