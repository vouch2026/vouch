import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/academic_structure_provider.dart';
import '../models/academic_structure_item.dart';
import '../../campuses/providers/campus_provider.dart';
import '../../faculties/providers/faculty_provider.dart';
import '../../programs/providers/program_provider.dart';
import './modals/edit_campus_modal.dart';
import './modals/edit_faculty_modal.dart';
import './modals/edit_program_modal.dart';

class AcademicStructureTable extends ConsumerStatefulWidget {
  const AcademicStructureTable({super.key});

  @override
  ConsumerState<AcademicStructureTable> createState() => _AcademicStructureTableState();
}

class _AcademicStructureTableState extends ConsumerState<AcademicStructureTable> {
  String _searchQuery = '';
  int _currentPage = 0;
  final int _rowsPerPage = 10;

  @override
  Widget build(BuildContext context) {
    final structureAsync = ref.watch(academicStructureProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: structureAsync.when(
        data: (data) {
          final filteredData = data.where((item) {
            final query = _searchQuery.toLowerCase();
            return item.campusName.toLowerCase().contains(query) ||
                item.facultyName.toLowerCase().contains(query) ||
                item.programName.toLowerCase().contains(query) ||
                (item.programHeadName?.toLowerCase().contains(query) ?? false);
          }).toList();

          final totalEntries = filteredData.length;
          final totalPages = (totalEntries / _rowsPerPage).ceil();
          final start = _currentPage * _rowsPerPage;
          final end = (start + _rowsPerPage < totalEntries) ? start + _rowsPerPage : totalEntries;
          
          List<AcademicStructureItem> paginatedData = [];
          if (totalEntries > 0) {
             paginatedData = filteredData.sublist(start, end);
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const Divider(height: 1),
              _buildFilters(),
              const Divider(height: 1),
              _buildDataTable(paginatedData),
              _buildPagination(totalEntries, start, end, totalPages),
            ],
          );
        },
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.xxl),
            child: CircularProgressIndicator(),
          ),
        ),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Text('Error loading data: $err'),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: AppSpacing.md,
        runSpacing: AppSpacing.md,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Hierarchy Data',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                'Comprehensive list of all academic units',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textGrey,
                ),
              ),
            ],
          ),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            children: [
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.file_download_outlined, size: 20),
                label: const Text('Export CSV'),
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text('Add Hierarchy Unit'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmall = constraints.maxWidth < 600;
          
          final searchField = TextField(
            decoration: InputDecoration(
              hintText: 'Search hierarchy...',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            ),
            onChanged: (val) => setState(() {
              _searchQuery = val;
              _currentPage = 0;
            }),
          );

          final chips = [
            _FilterChip(label: 'Campus', onSelected: (b) {}),
            const SizedBox(width: AppSpacing.sm),
            _FilterChip(label: 'Faculty', onSelected: (b) {}),
            const SizedBox(width: AppSpacing.sm),
            _FilterChip(label: 'Program', onSelected: (b) {}),
          ];

          if (isSmall) {
            return Column(
              children: [
                searchField,
                const SizedBox(height: AppSpacing.md),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: chips),
                ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: searchField),
              const SizedBox(width: AppSpacing.md),
              ...chips,
            ],
          );
        },
      ),
    );
  }

  Widget _buildDataTable(List<AcademicStructureItem> data) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        horizontalMargin: AppSpacing.lg,
        headingRowHeight: 56,
        dataRowMaxHeight: 64,
        headingTextStyle: AppTextStyles.labelMedium.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.textGrey,
        ),
        columns: const [
          DataColumn(label: Text('Campus')),
          DataColumn(label: Text('Faculty')),
          DataColumn(label: Text('Program')),
          DataColumn(label: Text('Lead')),
          DataColumn(label: Text('Students')),
          DataColumn(label: Text('Orgs')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Actions')),
        ],
        rows: data.map((item) => _buildRow(item)).toList(),
      ),
    );
  }

  DataRow _buildRow(AcademicStructureItem item) {
    return DataRow(
      cells: [
        DataCell(Text(item.campusName, style: AppTextStyles.labelMedium)),
        DataCell(Text(item.facultyName, style: AppTextStyles.labelMedium)),
        DataCell(Text(item.programName, style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold))),
        DataCell(Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.programHeadName ?? 'N/A', style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w600)),
            Text(item.programHeadName != null ? 'Assigned' : 'Unassigned', 
                style: AppTextStyles.labelSmall.copyWith(
                  color: item.programHeadName != null ? Colors.green : Colors.orange,
                )),
          ],
        )),
        DataCell(Text(item.studentCount.toString(), style: AppTextStyles.labelMedium)),
        DataCell(Text(item.orgCount.toString(), style: AppTextStyles.labelMedium)),
        DataCell(Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: (item.status == 'active' ? Colors.green : Colors.grey).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            item.status.toUpperCase(), 
            style: TextStyle(
              color: item.status == 'active' ? Colors.green : Colors.grey, 
              fontSize: 11, 
              fontWeight: FontWeight.bold,
            ),
          ),
        )),
        DataCell(Row(
          children: [
            IconButton(
              onPressed: () => _handleEdit(item),
              icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'Edit Unit',
            ),
            const SizedBox(width: 12),
            IconButton(
              onPressed: () => _confirmDelete(item),
              icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'Delete Unit',
            ),
          ],
        )),
      ],
    );
  }

  Future<void> _handleEdit(AcademicStructureItem item) async {
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('What would you like to edit?'),
        content: const Text('Select the academic level you wish to modify.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'campus'),
            child: const Text('Campus'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'faculty'),
            child: const Text('Faculty'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'program'),
            child: const Text('Program'),
          ),
        ],
      ),
    );

    if (choice == null || !mounted) return;

    try {
      if (choice == 'campus') {
        final campuses = await ref.read(campusesProvider.future);
        final campus = campuses.firstWhere((c) => c.id == item.campusId);
        if (mounted) {
          showDialog(context: context, builder: (context) => EditCampusModal(campus: campus));
        }
      } else if (choice == 'faculty') {
        final faculties = await ref.read(facultiesProvider.future);
        final faculty = faculties.firstWhere((f) => f.id == item.facultyId);
        if (mounted) {
          showDialog(context: context, builder: (context) => EditFacultyModal(faculty: faculty));
        }
      } else if (choice == 'program') {
        final programs = await ref.read(programsProvider.future);
        final program = programs.firstWhere((p) => p.id == item.programId);
        if (mounted) {
          showDialog(context: context, builder: (context) => EditProgramModal(program: program));
        }
      }
    } catch (e) {
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _confirmDelete(AcademicStructureItem item) async {
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Academic Unit?'),
        content: Text('Deleting a parent unit (Campus/Faculty) will also delete all its children. Are you sure you want to delete ${item.programName}, or its parent units?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'program'),
            child: const Text('Delete Program', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'faculty'),
            child: const Text('Delete Faculty', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'campus'),
            child: const Text('Delete Campus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (choice == null || !mounted) return;

    try {
      if (choice == 'campus') {
        await ref.read(campusesProvider.notifier).deleteCampus(item.campusId);
      } else if (choice == 'faculty') {
        await ref.read(facultiesProvider.notifier).deleteFaculty(item.facultyId);
      } else if (choice == 'program') {
        await ref.read(programsProvider.notifier).deleteProgram(item.programId);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${choice[0].toUpperCase()}${choice.substring(1)} deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting $choice: $e')),
        );
      }
    }
  }

  Widget _buildPagination(int totalEntries, int start, int end, int totalPages) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: AppSpacing.md,
        runSpacing: AppSpacing.md,
        children: [
          Text(
            'Showing ${totalEntries == 0 ? 0 : start + 1} to $end of $totalEntries entries',
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.textGrey),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: _currentPage > 0 ? () => setState(() => _currentPage--) : null,
                icon: const Icon(Icons.chevron_left_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey.shade100,
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: _currentPage < totalPages - 1 ? () => setState(() => _currentPage++) : null,
                icon: const Icon(Icons.chevron_right_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey.shade100,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final Function(bool) onSelected;

  const _FilterChip({required this.label, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      onSelected: onSelected,
      backgroundColor: Colors.white,
      selectedColor: AppColors.primary.withValues(alpha: 0.1),
      checkmarkColor: AppColors.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      labelStyle: AppTextStyles.labelSmall.copyWith(
        color: AppColors.textDark,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
