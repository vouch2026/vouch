import 'dart:typed_data';

import 'package:excel/excel.dart' as excel_lib;
import 'package:vouch_v2/core/widgets/loaders/flickr_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/file_saver_helper.dart';
import '../providers/academic_structure_provider.dart';
import '../models/academic_structure_item.dart';
import '../../campuses/providers/campus_provider.dart';
import '../../faculties/providers/faculty_provider.dart';
import '../../programs/providers/program_provider.dart';
import './modals/create_campus_modal.dart';
import './modals/create_faculty_modal.dart';
import './modals/create_program_modal.dart';
import './modals/edit_campus_modal.dart';
import './modals/edit_faculty_modal.dart';
import './modals/edit_program_modal.dart';

/// Flat, searchable directory of every School → Campus → Faculty → Program
/// row. Rendered below the hierarchy tree on the Academic Structure page.
///
/// Previously this widget was mounted nowhere and its Export / Add buttons
/// were dead — all controls below are now fully wired.
class AcademicStructureTable extends ConsumerStatefulWidget {
  final String? selectedSchoolId;
  final String? schoolName;

  const AcademicStructureTable(
      {super.key, this.selectedSchoolId, this.schoolName});

  @override
  ConsumerState<AcademicStructureTable> createState() =>
      _AcademicStructureTableState();
}

class _AcademicStructureTableState
    extends ConsumerState<AcademicStructureTable> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _campusFilter;
  String? _facultyFilter;
  String? _statusFilter;
  String _sortValue = 'programAsc';
  int _currentPage = 0;
  int _rowsPerPage = 10;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _resetPage() => _currentPage = 0;

  bool get _hasActiveFilters =>
      _searchQuery.trim().isNotEmpty ||
      _campusFilter != null ||
      _facultyFilter != null ||
      _statusFilter != null;

  void _clearAll() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _campusFilter = null;
      _facultyFilter = null;
      _statusFilter = null;
      _resetPage();
    });
  }

  List<AcademicStructureItem> _applyFilters(
      List<AcademicStructureItem> rows, Set<String> scopedCampusIds) {
    final q = _searchQuery.trim().toLowerCase();
    final filtered = rows.where((item) {
      if (widget.selectedSchoolId != null &&
          !scopedCampusIds.contains(item.campusId)) {
        return false;
      }
      if (_campusFilter != null && item.campusId != _campusFilter) {
        return false;
      }
      if (_facultyFilter != null && item.facultyId != _facultyFilter) {
        return false;
      }
      if (_statusFilter != null &&
          item.status.toLowerCase() != _statusFilter!.toLowerCase()) {
        return false;
      }
      if (q.isNotEmpty) {
        final haystacks = [
          item.campusName.toLowerCase(),
          item.facultyName.toLowerCase(),
          item.programName.toLowerCase(),
          (item.programHeadName ?? '').toLowerCase(),
        ];
        if (!haystacks.any((h) => h.contains(q))) return false;
      }
      return true;
    }).toList();

    switch (_sortValue) {
      case 'campusAsc':
        filtered.sort((a, b) =>
            a.campusName.toLowerCase().compareTo(b.campusName.toLowerCase()));
        break;
      case 'studentsDesc':
        filtered.sort((a, b) => b.studentCount.compareTo(a.studentCount));
        break;
      case 'studentsAsc':
        filtered.sort((a, b) => a.studentCount.compareTo(b.studentCount));
        break;
      case 'programAsc':
      default:
        filtered.sort((a, b) =>
            a.programName.toLowerCase().compareTo(b.programName.toLowerCase()));
        break;
    }
    return filtered;
  }

  Future<void> _exportExcel(List<AcademicStructureItem> rows) async {
    try {
      final excel = excel_lib.Excel.createExcel();
      final defaultSheet = excel.getDefaultSheet() ?? 'Sheet1';
      final sheet = excel[defaultSheet];

      sheet.appendRow([
        excel_lib.TextCellValue('Report Type'),
        excel_lib.TextCellValue('Academic Structure Directory'),
      ]);
      sheet.appendRow([
        excel_lib.TextCellValue('School'),
        excel_lib.TextCellValue(widget.schoolName ?? 'All schools'),
      ]);
      sheet.appendRow([
        excel_lib.TextCellValue('Export Date'),
        excel_lib.TextCellValue(
            DateTime.now().toLocal().toString().substring(0, 19)),
      ]);
      sheet.appendRow([
        excel_lib.TextCellValue('Total Records'),
        excel_lib.TextCellValue('${rows.length}'),
      ]);
      sheet.appendRow([]);

      sheet.appendRow([
        excel_lib.TextCellValue('Campus'),
        excel_lib.TextCellValue('Faculty'),
        excel_lib.TextCellValue('Program'),
        excel_lib.TextCellValue('Program Head'),
        excel_lib.TextCellValue('Students'),
        excel_lib.TextCellValue('Organizations'),
        excel_lib.TextCellValue('Status'),
      ]);

      for (final item in rows) {
        sheet.appendRow([
          excel_lib.TextCellValue(item.campusName),
          excel_lib.TextCellValue(item.facultyName),
          excel_lib.TextCellValue(item.programName),
          excel_lib.TextCellValue(item.programHeadName ?? 'Unassigned'),
          excel_lib.TextCellValue('${item.studentCount}'),
          excel_lib.TextCellValue('${item.orgCount}'),
          excel_lib.TextCellValue(item.status.toUpperCase()),
        ]);
      }

      final bytes = excel.encode();
      if (bytes == null) throw Exception('Failed to encode excel');
      final fileName =
          'Academic_Structure_Directory_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final isSuccess =
          await FileSaverUtil.saveFile(Uint8List.fromList(bytes), fileName);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isSuccess
                ? 'Directory downloaded successfully!'
                : 'Failed to download directory.'),
            backgroundColor: isSuccess ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error downloading directory: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAddMenu() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Academic Unit'),
        content: const Text('Select the level you wish to create.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              showDialog(
                  context: context,
                  builder: (context) => const CreateCampusModal());
            },
            child: const Text('Campus'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              showDialog(
                  context: context,
                  builder: (context) => const CreateFacultyModal());
            },
            child: const Text('Faculty'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              showDialog(
                  context: context,
                  builder: (context) => const CreateProgramModal());
            },
            child: const Text('Program'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final structureAsync = ref.watch(academicStructureProvider);
    final scopedCampusIds = widget.selectedSchoolId == null
        ? const <String>{}
        : (ref
                .watch(campusesBySchoolProvider(widget.selectedSchoolId!))
                .valueOrNull
                ?.map((c) => c.id)
                .toSet() ??
            const <String>{});

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: structureAsync.when(
        data: (data) {
          final scopedRows = widget.selectedSchoolId == null
              ? data
              : data
                  .where((i) => scopedCampusIds.contains(i.campusId))
                  .toList();
          final filteredData = _applyFilters(data, scopedCampusIds);

          final totalEntries = filteredData.length;
          final totalPages = (totalEntries / _rowsPerPage).ceil();
          final safePage = _currentPage >= totalPages
              ? (totalPages > 0 ? totalPages - 1 : 0)
              : _currentPage;
          final start = safePage * _rowsPerPage;
          final end = (start + _rowsPerPage < totalEntries)
              ? start + _rowsPerPage
              : totalEntries;

          final List<AcademicStructureItem> paginatedData =
              totalEntries > 0 ? filteredData.sublist(start, end) : [];

          // Dynamic dropdown options from the school-scoped rows.
          final campusOptions = <String, String>{};
          final facultyOptions = <String, String>{};
          final facultyCampus = <String, String>{};
          for (final item in scopedRows) {
            campusOptions.putIfAbsent(item.campusId, () => item.campusName);
            facultyOptions.putIfAbsent(item.facultyId, () => item.facultyName);
            facultyCampus.putIfAbsent(item.facultyId, () => item.campusId);
          }
          if (_campusFilter != null &&
              !campusOptions.containsKey(_campusFilter)) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              setState(() {
                _campusFilter = null;
                _facultyFilter = null;
                _resetPage();
              });
            });
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(filteredData),
              const Divider(height: 1),
              _buildFilters(campusOptions, facultyOptions, facultyCampus),
              const Divider(height: 1),
              if (paginatedData.isEmpty)
                _buildEmptyState(scopedRows.isEmpty)
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 700) {
                      return _buildCardList(paginatedData);
                    }
                    return _buildDataTable(paginatedData);
                  },
                ),
              _buildPagination(totalEntries, start, end, totalPages, safePage),
            ],
          );
        },
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.xxl),
            child: FlickrLoader(),
          ),
        ),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              children: [
                Text('Error loading data: $err'),
                TextButton(
                  onPressed: () =>
                      ref.invalidate(academicStructureProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(List<AcademicStructureItem> filteredForExport) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 600;
          final title = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Directory Data',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                widget.schoolName != null
                    ? 'Every program under ${widget.schoolName}'
                    : 'Comprehensive list of all academic units',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textGrey,
                ),
              ),
            ],
          );
          final actions = Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            children: [
              OutlinedButton.icon(
                onPressed: filteredForExport.isEmpty
                    ? null
                    : () => _exportExcel(filteredForExport),
                icon: const Icon(Icons.file_download_outlined, size: 20),
                label: const Text('Export Excel'),
              ),
              ElevatedButton.icon(
                onPressed: _showAddMenu,
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text('Add Unit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
              ),
            ],
          );
          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                title,
                const SizedBox(height: AppSpacing.md),
                actions,
              ],
            );
          }
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [Expanded(child: title), actions],
          );
        },
      ),
    );
  }

  Widget _buildFilters(Map<String, String> campusOptions,
      Map<String, String> facultyOptions, Map<String, String> facultyCampus) {
    final theme = Theme.of(context);
    final campusEntries = campusOptions.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    final visibleFacultyEntries = facultyOptions.entries
        .where((e) =>
            _campusFilter == null || facultyCampus[e.key] == _campusFilter)
        .toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    Widget dropdown({
      required String label,
      required String? value,
      required List<MapEntry<String, String>> entries,
      required ValueChanged<String?> onChanged,
    }) {
      return DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        isExpanded: true,
        value: value,
        items: [
          DropdownMenuItem(value: null, child: Text('All $label')),
          for (final e in entries)
            DropdownMenuItem(value: e.key, child: Text(e.value)),
        ],
        onChanged: (val) {
          setState(() {
            onChanged(val);
            _resetPage();
          });
        },
      );
    }

    final sortDropdown = DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Sort by',
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      isExpanded: true,
      value: _sortValue,
      items: const [
        DropdownMenuItem(value: 'programAsc', child: Text('Program A–Z')),
        DropdownMenuItem(value: 'campusAsc', child: Text('Campus A–Z')),
        DropdownMenuItem(
            value: 'studentsDesc', child: Text('Most students')),
        DropdownMenuItem(
            value: 'studentsAsc', child: Text('Fewest students')),
      ],
      onChanged: (val) {
        if (val != null) {
          setState(() {
            _sortValue = val;
            _resetPage();
          });
        }
      },
    );

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmall = constraints.maxWidth < 600;
          final fieldWidth = isSmall
              ? (constraints.maxWidth - AppSpacing.xl) / 2 - 10
              : 200.0;

          final searchField = TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search campus, faculty, program, or lead...',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      tooltip: 'Clear search',
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () => setState(() {
                        _searchController.clear();
                        _searchQuery = '';
                        _resetPage();
                      }),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: theme.colorScheme.primary, width: 1.5),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            ),
            onChanged: (val) => setState(() {
              _searchQuery = val;
              _resetPage();
            }),
          );

          final filterFields = [
            SizedBox(
              width: fieldWidth,
              child: dropdown(
                label: 'Campus',
                value: _campusFilter,
                entries: campusEntries,
                onChanged: (val) {
                  _campusFilter = val;
                  _facultyFilter = null;
                },
              ),
            ),
            SizedBox(
              width: fieldWidth,
              child: dropdown(
                label: 'Faculty',
                value: _facultyFilter,
                entries: visibleFacultyEntries,
                onChanged: (val) => _facultyFilter = val,
              ),
            ),
            SizedBox(
              width: fieldWidth,
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Status',
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                isExpanded: true,
                value: _statusFilter,
                items: const [
                  DropdownMenuItem(
                      value: null, child: Text('All Statuses')),
                  DropdownMenuItem(
                      value: 'active', child: Text('Active')),
                  DropdownMenuItem(
                      value: 'inactive', child: Text('Inactive')),
                ],
                onChanged: (val) => setState(() {
                  _statusFilter = val;
                  _resetPage();
                }),
              ),
            ),
            SizedBox(width: fieldWidth, child: sortDropdown),
          ];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isSmall) ...[
                searchField,
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  children: filterFields,
                ),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: searchField),
                    const SizedBox(width: AppSpacing.md),
                    ...filterFields,
                  ],
                ),
              if (_hasActiveFilters) ...[
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (_searchQuery.trim().isNotEmpty)
                      InputChip(
                        label: Text('"${_searchQuery.trim()}"'),
                        avatar:
                            const Icon(Icons.search_rounded, size: 14),
                        onDeleted: () => setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                          _resetPage();
                        }),
                      ),
                    if (_campusFilter != null)
                      InputChip(
                        label: Text(
                            'Campus: ${campusOptions[_campusFilter] ?? _campusFilter}'),
                        onDeleted: () => setState(() {
                          _campusFilter = null;
                          _facultyFilter = null;
                          _resetPage();
                        }),
                      ),
                    if (_facultyFilter != null)
                      InputChip(
                        label: Text(
                            'Faculty: ${facultyOptions[_facultyFilter] ?? _facultyFilter}'),
                        onDeleted: () => setState(() {
                          _facultyFilter = null;
                          _resetPage();
                        }),
                      ),
                    if (_statusFilter != null)
                      InputChip(
                        label: Text('Status: $_statusFilter'),
                        onDeleted: () => setState(() {
                          _statusFilter = null;
                          _resetPage();
                        }),
                      ),
                    TextButton.icon(
                      onPressed: _clearAll,
                      icon: const Icon(Icons.clear_all_rounded, size: 16),
                      label: const Text('Clear all'),
                    ),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(bool noUnitsAtAll) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        children: [
          Icon(
            noUnitsAtAll
                ? Icons.account_tree_outlined
                : Icons.search_off_rounded,
            size: 56,
            color: AppColors.primary.withValues(alpha: 0.25),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            noUnitsAtAll ? 'No academic units yet' : 'No results found',
            style: AppTextStyles.titleMedium
                .copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            noUnitsAtAll
                ? 'Add a campus, faculty, or program to populate this directory.'
                : 'No units match your current search and filters.',
            style:
                AppTextStyles.bodyMedium.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          if (noUnitsAtAll)
            ElevatedButton.icon(
              onPressed: _showAddMenu,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add Unit'),
            )
          else
            FilledButton.tonalIcon(
              onPressed: _clearAll,
              icon: const Icon(Icons.clear_all_rounded, size: 18),
              label: const Text('Clear search & filters'),
            ),
        ],
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

  Widget _buildCardList(List<AcademicStructureItem> data) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: data.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final item = data[index];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(item.programName,
                          style: AppTextStyles.bodyMedium
                              .copyWith(fontWeight: FontWeight.bold)),
                    ),
                    _StatusBadge(status: item.status),
                  ],
                ),
                const SizedBox(height: 4),
                Text('${item.campusName} • ${item.facultyName}',
                    style: AppTextStyles.labelSmall
                        .copyWith(color: Colors.grey[600])),
                const SizedBox(height: 4),
                Text(
                  'Lead: ${item.programHeadName ?? "Unassigned"} • '
                  '${item.studentCount} students • ${item.orgCount} orgs',
                  style: AppTextStyles.labelSmall
                      .copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _handleEdit(item),
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text('Edit'),
                    ),
                    TextButton.icon(
                      onPressed: () => _confirmDelete(item),
                      icon: const Icon(Icons.delete_outline_rounded,
                          size: 16, color: Colors.red),
                      label: const Text('Delete',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  DataRow _buildRow(AcademicStructureItem item) {
    return DataRow(
      cells: [
        DataCell(Text(item.campusName, style: AppTextStyles.labelMedium)),
        DataCell(Text(item.facultyName, style: AppTextStyles.labelMedium)),
        DataCell(Text(item.programName,
            style: AppTextStyles.labelMedium
                .copyWith(fontWeight: FontWeight.bold))),
        DataCell(Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.programHeadName ?? 'N/A',
                style: AppTextStyles.labelMedium
                    .copyWith(fontWeight: FontWeight.w600)),
            Text(item.programHeadName != null ? 'Assigned' : 'Unassigned',
                style: AppTextStyles.labelSmall.copyWith(
                  color: item.programHeadName != null
                      ? Colors.green
                      : Colors.orange,
                )),
          ],
        )),
        DataCell(
            Text(item.studentCount.toString(), style: AppTextStyles.labelMedium)),
        DataCell(
            Text(item.orgCount.toString(), style: AppTextStyles.labelMedium)),
        DataCell(_StatusBadge(status: item.status)),
        DataCell(Row(
          children: [
            IconButton(
              onPressed: () => _handleEdit(item),
              icon: const Icon(Icons.edit_outlined,
                  size: 18, color: AppColors.primary),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'Edit Unit',
            ),
            const SizedBox(width: 12),
            IconButton(
              onPressed: () => _confirmDelete(item),
              icon: const Icon(Icons.delete_outline_rounded,
                  size: 18, color: Colors.red),
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
          showDialog(
              context: context,
              builder: (context) => EditCampusModal(campus: campus));
        }
      } else if (choice == 'faculty') {
        final faculties = await ref.read(facultiesProvider.future);
        final faculty = faculties.firstWhere((f) => f.id == item.facultyId);
        if (mounted) {
          showDialog(
              context: context,
              builder: (context) => EditFacultyModal(faculty: faculty));
        }
      } else if (choice == 'program') {
        final programs = await ref.read(programsProvider.future);
        final program = programs.firstWhere((p) => p.id == item.programId);
        if (mounted) {
          showDialog(
              context: context,
              builder: (context) => EditProgramModal(program: program));
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
        content: Text(
            'Deleting a parent unit (Campus/Faculty) will also delete all its children. Are you sure you want to delete ${item.programName}, or its parent units?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'program'),
            child:
                const Text('Delete Program', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'faculty'),
            child:
                const Text('Delete Faculty', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'campus'),
            child:
                const Text('Delete Campus', style: TextStyle(color: Colors.red)),
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
          SnackBar(
              content: Text(
                  '${choice[0].toUpperCase()}${choice.substring(1)} deleted successfully')),
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

  Widget _buildPagination(
      int totalEntries, int start, int end, int totalPages, int safePage) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 500;
          final countText = Text(
            'Showing ${totalEntries == 0 ? 0 : start + 1} to $end of $totalEntries entries',
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.textGrey),
          );
          final rowsDropdown = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Rows:',
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.textGrey)),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: _rowsPerPage,
                underline: const SizedBox.shrink(),
                items: [5, 10, 20, 50]
                    .map((v) =>
                        DropdownMenuItem(value: v, child: Text('$v')))
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    setState(() {
                      _rowsPerPage = v;
                      _resetPage();
                    });
                  }
                },
              ),
            ],
          );
          final navButtons = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: safePage > 0
                    ? () => setState(() => _currentPage = safePage - 1)
                    : null,
                icon: const Icon(Icons.chevron_left_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey.shade100,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text('${safePage + 1} / ${totalPages > 0 ? totalPages : 1}',
                    style: AppTextStyles.labelSmall),
              ),
              IconButton(
                onPressed: safePage < totalPages - 1
                    ? () => setState(() => _currentPage = safePage + 1)
                    : null,
                icon: const Icon(Icons.chevron_right_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey.shade100,
                ),
              ),
            ],
          );

          if (isNarrow) {
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [rowsDropdown, navButtons],
                ),
                const SizedBox(height: 8),
                countText,
              ],
            );
          }
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              countText,
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  rowsDropdown,
                  const SizedBox(width: AppSpacing.md),
                  navButtons,
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isActive = status.toLowerCase() == 'active';
    final color = isActive ? Colors.green : Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
