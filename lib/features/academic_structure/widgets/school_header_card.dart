import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../auth/providers/auth_provider.dart';
import '../../schools/models/school_model.dart';
import '../../schools/providers/school_provider.dart';
import '../../campuses/providers/campus_provider.dart';
import '../../faculties/providers/faculty_provider.dart';
import '../../programs/providers/program_provider.dart';
import '../providers/academic_structure_provider.dart';
import 'modals/edit_school_modal.dart';

/// Top-of-page banner for the selected school (university).
///
/// Single-school deployments (e.g. DORSU) get a banner card with live totals.
/// Multi-school deployments get a school switcher that scopes the hierarchy
/// and directory below via [onSchoolSelected].
///
/// Superadmins get an Edit/Delete overflow menu on the banner. Delete is
/// blocked while campuses still reference the school (DB RESTRICT) and
/// [onSchoolDeleted] lets the page clear its selection afterwards.
class SchoolHeaderCard extends ConsumerStatefulWidget {
  final String? selectedSchoolId;
  final ValueChanged<String>? onSchoolSelected;
  final VoidCallback? onSchoolDeleted;

  const SchoolHeaderCard({
    super.key,
    required this.selectedSchoolId,
    this.onSchoolSelected,
    this.onSchoolDeleted,
  });

  @override
  ConsumerState<SchoolHeaderCard> createState() => _SchoolHeaderCardState();
}

class _SchoolHeaderCardState extends ConsumerState<SchoolHeaderCard> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    final schoolsAsync = ref.watch(schoolsProvider);

    return schoolsAsync.when(
      data: (schools) {
        if (schools.isEmpty) return _buildNoSchoolState(context);
        final school = _resolveSchool(schools, widget.selectedSchoolId);
        return _buildCard(context, school, schools);
      },
      loading: () => _buildLoadingState(context),
      error: (e, _) => _buildErrorState(context, e),
    );
  }

  SchoolModel _resolveSchool(List<SchoolModel> schools, String? selectedId) {
    if (selectedId != null) {
      for (final s in schools) {
        if (s.id == selectedId) return s;
      }
    }
    return schools.first;
  }

  Widget _buildCard(
      BuildContext context, SchoolModel school, List<SchoolModel> schools) {
    final theme = Theme.of(context);
    final isSuperAdmin =
        ref.watch(userProfileProvider).valueOrNull?.role == 'super_admin';
    final campuses =
        ref.watch(campusesBySchoolProvider(school.id)).valueOrNull ?? const [];
    final allFaculties = ref.watch(facultiesProvider).valueOrNull ?? const [];
    final allPrograms = ref.watch(programsProvider).valueOrNull ?? const [];
    final studentCounts =
        ref.watch(studentCountsProvider).valueOrNull ?? const {};

    final campusIds = campuses.map((c) => c.id).toSet();
    final schoolFaculties =
        allFaculties.where((f) => campusIds.contains(f.campusId)).toList();
    final facultyIds = schoolFaculties.map((f) => f.id).toSet();
    final schoolPrograms =
        allPrograms.where((p) => facultyIds.contains(p.facultyId)).toList();
    var studentTotal = 0;
    for (final p in schoolPrograms) {
      studentTotal += studentCounts[p.id] ?? 0;
    }

    final isActive = school.status.toLowerCase() == 'active';

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        return Card(
          elevation: 0,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.75),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _SchoolLogo(school: school, size: isMobile ? 52 : 64),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  school.name,
                                  style: (isMobile
                                          ? AppTextStyles.titleMedium
                                          : AppTextStyles.titleLarge)
                                      .copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? Colors.green.withValues(alpha: 0.2)
                                      : Colors.grey.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.4)),
                                ),
                                child: Text(
                                  school.status.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (school.shortName != null &&
                              school.shortName!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              school.shortName!,
                              style: AppTextStyles.labelMedium.copyWith(
                                  color:
                                      Colors.white.withValues(alpha: 0.85)),
                            ),
                          ],
                          const SizedBox(height: 2),
                          Text(
                            'School • ${campuses.length} ${campuses.length == 1 ? 'campus' : 'campuses'}',
                            style: AppTextStyles.labelSmall.copyWith(
                                color: Colors.white.withValues(alpha: 0.8)),
                          ),
                        ],
                      ),
                    ),
                    if (schools.length > 1 &&
                        widget.onSchoolSelected != null) ...[
                      const SizedBox(width: AppSpacing.md),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: school.id,
                            icon: const Icon(Icons.arrow_drop_down, size: 18),
                            items: [
                              for (final s in schools)
                                DropdownMenuItem(
                                  value: s.id,
                                  child: Text(
                                    s.displayName,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                            ],
                            onChanged: (id) {
                              if (id != null) {
                                widget.onSchoolSelected!(id);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                    if (isSuperAdmin) ...[
                      const SizedBox(width: 4),
                      _SchoolActionsMenu(
                        isDeleting: _isDeleting,
                        onEdit: () => showDialog(
                          context: context,
                          builder: (context) =>
                              EditSchoolModal(school: school),
                        ),
                        onDelete: () => _onDeletePressed(
                          school,
                          campusCount: campuses.length,
                          facultyCount: schoolFaculties.length,
                          programCount: schoolPrograms.length,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: isMobile
                    ? Wrap(
                        spacing: AppSpacing.md,
                        runSpacing: AppSpacing.md,
                        children: [
                          _TotalChip(
                              label: 'Campuses',
                              value: '${campuses.length}',
                              icon: Icons.business_rounded),
                          _TotalChip(
                              label: 'Faculties',
                              value: '${schoolFaculties.length}',
                              icon: Icons.account_balance_rounded),
                          _TotalChip(
                              label: 'Programs',
                              value: '${schoolPrograms.length}',
                              icon: Icons.school_rounded),
                          _TotalChip(
                              label: 'Students',
                              value: '$studentTotal',
                              icon: Icons.people_outline_rounded),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                              child: _TotalStat(
                                  label: 'Campuses',
                                  value: '${campuses.length}',
                                  icon: Icons.business_rounded,
                                  color: AppColors.primary)),
                          Expanded(
                              child: _TotalStat(
                                  label: 'Faculties',
                                  value: '${schoolFaculties.length}',
                                  icon: Icons.account_balance_rounded,
                                  color: AppColors.accent)),
                          Expanded(
                              child: _TotalStat(
                                  label: 'Programs',
                                  value: '${schoolPrograms.length}',
                                  icon: Icons.school_rounded,
                                  color: Colors.indigo)),
                          Expanded(
                              child: _TotalStat(
                                  label: 'Students',
                                  value: '$studentTotal',
                                  icon: Icons.people_outline_rounded,
                                  color: Colors.teal)),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _onDeletePressed(
    SchoolModel school, {
    required int campusCount,
    required int facultyCount,
    required int programCount,
  }) async {
    if (_isDeleting) return;

    // DB enforces ON DELETE RESTRICT while campuses reference the school —
    // block up front with an explanation instead of a raw Postgres error.
    if (campusCount > 0) {
      await showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Cannot delete school'),
          content: Text(
            '"${school.displayName}" still has $campusCount ${campusCount == 1 ? 'campus' : 'campuses'} '
            '($facultyCount ${facultyCount == 1 ? 'faculty' : 'faculties'}, '
            '$programCount ${programCount == 1 ? 'program' : 'programs'}).\n\n'
            'Reassign or delete those units first, then try again.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Understood'),
            ),
          ],
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete school?'),
        content: Text(
          'Are you sure you want to permanently delete "${school.name}"?\n\n'
          'It has no campuses, faculties, or programs. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isDeleting = true);
    try {
      await ref.read(schoolsProvider.notifier).deleteSchool(school.id);
      widget.onSchoolDeleted?.call();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${school.name}" deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting school: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  Widget _buildLoadingState(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: const Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: AppSpacing.md),
            Text('Loading school...'),
          ],
        ),
      ),
    );
  }

  Widget _buildNoSchoolState(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            Icon(Icons.account_balance_outlined,
                size: 48,
                color: theme.colorScheme.primary.withValues(alpha: 0.3)),
            const SizedBox(height: AppSpacing.md),
            Text('No school found',
                style: AppTextStyles.titleMedium
                    .copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Add a school to start organizing campuses, faculties, and programs under it.',
              style:
                  AppTextStyles.bodyMedium.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object e) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Text('Error loading school: $e')),
            TextButton(
              onPressed: () => ref.invalidate(schoolsProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SchoolActionsMenu extends StatelessWidget {
  final bool isDeleting;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SchoolActionsMenu({
    required this.isDeleting,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: isDeleting
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white),
            )
          : const Icon(Icons.more_vert_rounded,
              size: 20, color: Colors.white),
      tooltip: 'School actions',
      enabled: !isDeleting,
      offset: const Offset(0, 36),
      onSelected: (value) {
        if (value == 'edit') {
          onEdit();
        } else if (value == 'delete') {
          onDelete();
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 18),
              SizedBox(width: 8),
              Text('Edit school'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline_rounded,
                  size: 18, color: Colors.red),
              SizedBox(width: 8),
              Text('Delete school',
                  style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }
}

class _SchoolLogo extends StatelessWidget {
  final SchoolModel school;
  final double size;

  const _SchoolLogo({required this.school, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
      ),
      child: school.logoUrl != null && school.logoUrl!.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                school.logoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                    Icons.account_balance_outlined,
                    color: Colors.white,
                    size: 28),
              ),
            )
          : const Icon(Icons.account_balance_outlined,
              color: Colors.white, size: 28),
    );
  }
}

class _TotalStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _TotalStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: AppSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: AppTextStyles.headlineSmall
                    .copyWith(fontWeight: FontWeight.bold)),
            Text(label,
                style: AppTextStyles.labelMedium
                    .copyWith(color: Colors.grey[600])),
          ],
        ),
      ],
    );
  }
}

class _TotalChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _TotalChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(value,
              style: AppTextStyles.labelMedium
                  .copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(width: 4),
          Text(label,
              style:
                  AppTextStyles.labelSmall.copyWith(color: Colors.grey[600])),
        ],
      ),
    );
  }
}
