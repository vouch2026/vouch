import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/campus_provider.dart';
import '../../faculties/providers/faculty_provider.dart';
import '../../programs/providers/program_provider.dart';

class AcademicHierarchyTree extends ConsumerWidget {
  const AcademicHierarchyTree({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campusesAsync = ref.watch(campusesProvider);

    return campusesAsync.when(
      data: (campuses) => ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: campuses.length,
        separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) => _CampusNode(campus: campuses[index]),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}

class _CampusNode extends ConsumerStatefulWidget {
  final dynamic campus;
  const _CampusNode({required this.campus});

  @override
  ConsumerState<_CampusNode> createState() => _CampusNodeState();
}

class _CampusNodeState extends ConsumerState<_CampusNode> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final facultiesAsync = ref.watch(facultiesByCampusProvider(widget.campus.id));

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          ListTile(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(Icons.business_rounded, color: theme.colorScheme.primary, size: 20),
            ),
            title: Text(widget.campus.name, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
            subtitle: Text(widget.campus.location, style: AppTextStyles.bodySmall),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildActionChip(Icons.add_rounded, 'Faculty', () {}),
                const SizedBox(width: AppSpacing.xs),
                Icon(_isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded),
              ],
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.md, AppSpacing.md),
              child: facultiesAsync.when(
                data: (faculties) => Column(
                  children: faculties.map((f) => _FacultyNode(faculty: f)).toList(),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (e, s) => Text('Error loading faculties: $e'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionChip(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: Colors.blue),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _FacultyNode extends ConsumerStatefulWidget {
  final dynamic faculty;
  const _FacultyNode({required this.faculty});

  @override
  ConsumerState<_FacultyNode> createState() => _FacultyNodeState();
}

class _FacultyNodeState extends ConsumerState<_FacultyNode> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final programsAsync = ref.watch(programsByFacultyProvider(widget.faculty.id));

    return Column(
      children: [
        ListTile(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          dense: true,
          leading: Icon(Icons.account_balance_rounded, color: theme.colorScheme.secondary, size: 18),
          title: Text(widget.faculty.name, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
          subtitle: Text('Dean: ${widget.faculty.deanName ?? "Unassigned"}', style: AppTextStyles.bodySmall),
          trailing: Icon(_isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded, size: 20),
        ),
        if (_isExpanded)
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.xl),
            child: programsAsync.when(
              data: (programs) => Column(
                children: programs.map((p) => _ProgramNode(program: p)).toList(),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, s) => Text('Error loading programs: $e'),
            ),
          ),
      ],
    );
  }
}

class _ProgramNode extends StatelessWidget {
  final dynamic program;
  const _ProgramNode({required this.program});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      dense: true,
      leading: Icon(Icons.school_rounded, color: theme.colorScheme.tertiary, size: 16),
      title: Text(program.name, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w500)),
      subtitle: Text('Head: ${program.programHeadName ?? "Unassigned"}', style: const TextStyle(fontSize: 10)),
      trailing: IconButton(
        icon: const Icon(Icons.settings_outlined, size: 14),
        onPressed: () {},
      ),
    );
  }
}
