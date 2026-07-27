import 'package:vouch_v2/core/widgets/loaders/flickr_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/layouts/dashboard_layout.dart';
import '../../../users/widgets/user_management_header.dart';
import '../../../activity_cards/models/activity_card_models.dart';
import '../../../activity_cards/providers/activity_card_provider.dart';
import '../../../organizations/providers/workspace_provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../routes/route_paths.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart' as excel_lib;
import '../../../../core/utils/file_saver_helper.dart';
import 'dart:typed_data';
import '../../../../core/widgets/states/offline_state_view.dart';

class GovernorActivityCardsPage extends ConsumerStatefulWidget {
  const GovernorActivityCardsPage({super.key});

  @override
  ConsumerState<GovernorActivityCardsPage> createState() => _GovernorActivityCardsPageState();
}

class _GovernorActivityCardsPageState extends ConsumerState<GovernorActivityCardsPage> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'Needs Action';
  late TabController _tabController;

  // Cleared clearances filters and pagination state
  final TextEditingController _clearedSearchController = TextEditingController();
  DateTimeRange? _clearedDateRange;
  TimeOfDay? _clearedStartTime;
  TimeOfDay? _clearedEndTime;
  int _clearedCurrentPage = 1;
  int _clearedPageSize = 10;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(() {
      setState(() {});
    });
    _clearedSearchController.addListener(() {
      setState(() {
        _clearedCurrentPage = 1;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _clearedSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;
    final padding = EdgeInsets.symmetric(
      horizontal: isMobile ? AppSpacing.lg : AppSpacing.xl,
      vertical: isMobile ? AppSpacing.lg : AppSpacing.xl,
    );

    final workspace = ref.watch(workspaceProvider);
    final activeRole = workspace.activeRole;
    final orgType = workspace.selectedOrganization?.type;

    final cardsAsync = ref.watch(organizationActivityCardsProvider);

    return DashboardLayout(
      title: 'Organization Activity Cards',
      child: Padding(
        padding: padding,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.card_membership_rounded, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 8),
                      Text(
                        'Activity Cards',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  UserManagementHeader(
                    title: 'Activity Cards',
                    subtitle: 'Manage student clearances, signatures, and compliance',
                    actions: const [],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      labelColor: theme.colorScheme.primary,
                      unselectedLabelColor: Colors.grey[600],
                      indicatorColor: theme.colorScheme.primary,
                      indicatorWeight: 3,
                      dividerColor: Colors.transparent,
                      labelStyle: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold),
                      tabs: const [
                        Tab(text: 'Pending Clearances'),
                        Tab(text: 'Cleared Clearances'),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: [
              cardsAsync.when(
                data: (cards) {
                  final query = _searchController.text.toLowerCase();
                  final filteredCards = cards.where((card) {
                    // Only display students who have actually requested for clearance
                    final hasRequested = !card.id.startsWith('temp-');
                    if (!hasRequested) return false;

                    // Exclude cleared students from Pending tab
                    if (card.status == ActivityCardStatus.cleared) return false;
  
                    final matchesSearch = (card.studentName?.toLowerCase().contains(query) ?? false) ||
                        (card.studentIdNumber?.toLowerCase().contains(query) ?? false);
                    if (!matchesSearch) return false;

                    // Status Filter Logic
                    if (_selectedStatus == 'Needs Action') {
                      final roleName = activeRole?.roleName.toLowerCase().trim();
                      if (roleName == 'secretary') {
                        return card.status == ActivityCardStatus.secretaryReview;
                      } else if (roleName == 'treasurer') {
                        return card.status == ActivityCardStatus.treasurerReview;
                      } else if (roleName == 'governor' || roleName == 'president') {
                        return card.status == ActivityCardStatus.governorReview;
                      } else if (roleName == 'adviser' || roleName == 'instructor') {
                        return card.status == ActivityCardStatus.adviserReview;
                      } else if (roleName == 'program head') {
                        return card.status == ActivityCardStatus.programHeadReview;
                      } else if (roleName == 'faculty dean' || roleName == 'dean') {
                        return card.status == ActivityCardStatus.deanReview;
                      }
                      return true; // Fallback
                    } else if (_selectedStatus == 'All') {
                      return true;
                    } else {
                      // Map selected label to enum key (e.g. Governor Review or President Review -> governorReview)
                      String normalizedSelected = _selectedStatus;
                      if (_selectedStatus == 'Governor Review' || _selectedStatus == 'President Review') {
                        normalizedSelected = 'Governor Review';
                      }
                      return card.status.name.toLowerCase() == normalizedSelected.toLowerCase().replaceAll(' ', '');
                    }
                  }).toList();
                  
                  return _buildClearanceList(context, filteredCards, orgType);
                },
                loading: () => const Center(child: FlickrLoader()),
                error: (err, stack) {
                  if (OfflineStateView.isOfflineError(err)) {
                    return OfflineStateView(
                      onRetry: () => ref.invalidate(organizationActivityCardsProvider),
                    );
                  }
                  return Center(child: Text('Error: $err'));
                },
              ),
              cardsAsync.when(
                data: (cards) {
                  final query = _clearedSearchController.text.toLowerCase();
                  final filteredClearedCards = cards.where((card) {
                    // Only show cleared students in Cleared tab
                    if (card.status != ActivityCardStatus.cleared) return false;

                    final matchesSearch = (card.studentName?.toLowerCase().contains(query) ?? false) ||
                        (card.studentIdNumber?.toLowerCase().contains(query) ?? false);
                    if (!matchesSearch) return false;

                    // Date range filter
                    if (_clearedDateRange != null) {
                      if (card.clearedAt == null) return false;
                      final clearedAtLocal = card.clearedAt!.toLocal();
                      final startOfDay = DateTime(_clearedDateRange!.start.year, _clearedDateRange!.start.month, _clearedDateRange!.start.day, 0, 0, 0);
                      final endOfDay = DateTime(_clearedDateRange!.end.year, _clearedDateRange!.end.month, _clearedDateRange!.end.day, 23, 59, 59);
                      if (clearedAtLocal.isBefore(startOfDay) || clearedAtLocal.isAfter(endOfDay)) {
                        return false;
                      }
                    }

                    // Time range filter
                    if (_clearedStartTime != null || _clearedEndTime != null) {
                      if (card.clearedAt == null) return false;
                      final clearedAtLocal = card.clearedAt!.toLocal();
                      final clearedTime = TimeOfDay.fromDateTime(clearedAtLocal);
                      
                      if (_clearedStartTime != null) {
                        if (clearedTime.hour < _clearedStartTime!.hour || 
                            (clearedTime.hour == _clearedStartTime!.hour && clearedTime.minute < _clearedStartTime!.minute)) {
                          return false;
                        }
                      }
                      
                      if (_clearedEndTime != null) {
                        if (clearedTime.hour > _clearedEndTime!.hour || 
                            (clearedTime.hour == _clearedEndTime!.hour && clearedTime.minute > _clearedEndTime!.minute)) {
                          return false;
                        }
                      }
                    }

                    return true;
                  }).toList();

                  final totalItems = filteredClearedCards.length;
                  final totalPages = (totalItems / _clearedPageSize).ceil();
                  
                  // Clamp current page
                  if (_clearedCurrentPage > totalPages && totalPages > 0) {
                    _clearedCurrentPage = totalPages;
                  } else if (totalPages == 0) {
                    _clearedCurrentPage = 1;
                  }

                  final startIndex = (_clearedCurrentPage - 1) * _clearedPageSize;
                  final endIndex = startIndex + _clearedPageSize;
                  final paginatedCards = filteredClearedCards.sublist(
                    startIndex,
                    endIndex > totalItems ? totalItems : endIndex,
                  );

                  return _buildClearedClearanceList(context, paginatedCards, filteredClearedCards, totalItems, totalPages);
                },
                loading: () => const Center(child: FlickrLoader()),
                error: (err, stack) {
                  if (OfflineStateView.isOfflineError(err)) {
                    return OfflineStateView(
                      onRetry: () => ref.invalidate(organizationActivityCardsProvider),
                    );
                  }
                  return Center(child: Text('Error: $err'));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClearanceList(BuildContext context, List<ActivityCard> cards, String? orgType) {
    return Column(
      children: [
        _buildFilters(orgType),
        const SizedBox(height: AppSpacing.lg),
        Expanded(child: _buildStudentsTable(cards, orgType)),
      ],
    );
  }

  Widget _buildFilters(String? orgType) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;

        return Flex(
          direction: isCompact ? Axis.vertical : Axis.horizontal,
          children: [
            Expanded(
              flex: isCompact ? 0 : 1,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by student name or ID...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            SizedBox(width: isCompact ? 0 : AppSpacing.md, height: isCompact ? AppSpacing.md : 0),
            SizedBox(
              width: isCompact ? double.infinity : null,
              child: _buildStatusDropdown(orgType),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusDropdown(String? orgType) {
    final govPresLabel = orgType == 'faculty-based' ? 'Governor Review' : 'President Review';
    final dropdownItems = [
      'Needs Action',
      'All',
      'Secretary Review',
      'Treasurer Review',
      govPresLabel,
      'Adviser Review',
      'Program Head Review',
      'Dean Review',
      'Rejected'
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedStatus == 'Cleared' ? 'All' : _selectedStatus,
          items: dropdownItems
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: (val) => setState(() => _selectedStatus = val!),
        ),
      ),
    );
  }

  Widget _buildClearedClearanceList(
    BuildContext context, 
    List<ActivityCard> cards, 
    List<ActivityCard> allFilteredCards, 
    int totalItems, 
    int totalPages,
  ) {
    return Column(
      children: [
        _buildClearedFilters(allFilteredCards),
        const SizedBox(height: AppSpacing.lg),
        Expanded(child: _buildClearedStudentsTable(cards, totalItems, totalPages)),
      ],
    );
  }

  Widget _buildClearedFilters(List<ActivityCard> allFilteredCards) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final searchField = TextField(
          controller: _clearedSearchController,
          decoration: InputDecoration(
            hintText: 'Search by student name or ID...',
            prefixIcon: const Icon(Icons.search_rounded),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 14),
          ),
        );

        final dateButton = InkWell(
          onTap: _selectClearedDateRange,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.surface,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.date_range_rounded, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    _clearedDateRange == null
                        ? 'Filter by Date'
                        : '${DateFormat('MM/dd/yy').format(_clearedDateRange!.start)} - ${DateFormat('MM/dd/yy').format(_clearedDateRange!.end)}',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      color: _clearedDateRange == null ? Colors.grey[700] : AppColors.primary,
                      fontWeight: _clearedDateRange == null ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                ),
                if (_clearedDateRange != null) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _clearedDateRange = null;
                        _clearedCurrentPage = 1;
                      });
                    },
                    child: const Icon(Icons.close_rounded, size: 16, color: Colors.grey),
                  ),
                ],
              ],
            ),
          ),
        );

        final timeButton = InkWell(
          onTap: _selectClearedTimeRange,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.surface,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.access_time_rounded, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    (_clearedStartTime == null && _clearedEndTime == null)
                        ? 'Filter by Time'
                        : '${_clearedStartTime?.format(context) ?? "Any"} - ${_clearedEndTime?.format(context) ?? "Any"}',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      color: (_clearedStartTime == null && _clearedEndTime == null) ? Colors.grey[700] : AppColors.primary,
                      fontWeight: (_clearedStartTime == null && _clearedEndTime == null) ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                ),
                if (_clearedStartTime != null || _clearedEndTime != null) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _clearedStartTime = null;
                        _clearedEndTime = null;
                        _clearedCurrentPage = 1;
                      });
                    },
                    child: const Icon(Icons.close_rounded, size: 16, color: Colors.grey),
                  ),
                ],
              ],
            ),
          ),
        );

        // Mobile Layout (stacked vertically for best usability and touch targets)
        if (width < 600) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              searchField,
              const SizedBox(height: AppSpacing.md),
              dateButton,
              const SizedBox(height: AppSpacing.md),
              timeButton,
              const SizedBox(height: AppSpacing.md),
              ElevatedButton.icon(
                onPressed: allFilteredCards.isEmpty ? null : () => _downloadClearedExcel(allFilteredCards),
                icon: const Icon(Icons.file_download_rounded, color: Colors.white),
                label: const Text('Download Excel Report'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          );
        }

        // Tablet Layout (Search spans full width, buttons placed side-by-side below)
        if (width < 950) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              searchField,
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(child: dateButton),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: timeButton),
                  const SizedBox(width: AppSpacing.md),
                  ElevatedButton.icon(
                    onPressed: allFilteredCards.isEmpty ? null : () => _downloadClearedExcel(allFilteredCards),
                    icon: const Icon(Icons.file_download_rounded, color: Colors.white),
                    label: const Text('Export'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ],
          );
        }

        // Desktop Layout (single row, search expanded, buttons have constrained min-widths)
        return Row(
          children: [
            Expanded(
              child: searchField,
            ),
            const SizedBox(width: AppSpacing.md),
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 190),
              child: dateButton,
            ),
            const SizedBox(width: AppSpacing.md),
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 190),
              child: timeButton,
            ),
            const SizedBox(width: AppSpacing.md),
            ElevatedButton.icon(
              onPressed: allFilteredCards.isEmpty ? null : () => _downloadClearedExcel(allFilteredCards),
              icon: const Icon(Icons.file_download_rounded, color: Colors.white),
              label: const Text('Export Excel'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _downloadClearedExcel(List<ActivityCard> allFilteredCards) async {
    try {
      final workspace = ref.read(workspaceProvider);
      final orgName = workspace.selectedOrganization?.name ?? 'Unknown Organization';
      final dateStr = DateFormat('MMMM dd, yyyy').format(DateTime.now());

      final excel = excel_lib.Excel.createExcel();
      final defaultSheet = excel.getDefaultSheet() ?? 'Sheet1';
      final sheet = excel[defaultSheet];

      sheet.appendRow([
        excel_lib.TextCellValue('Cleared Students'),
      ]);
      sheet.appendRow([
        excel_lib.TextCellValue('Organization Name: $orgName'),
      ]);
      sheet.appendRow([
        excel_lib.TextCellValue('Date: $dateStr'),
      ]);
      sheet.appendRow([]);

      sheet.appendRow([
        excel_lib.TextCellValue('Id no.'),
        excel_lib.TextCellValue('Name'),
        excel_lib.TextCellValue('Faculty'),
        excel_lib.TextCellValue('Program'),
        excel_lib.TextCellValue('Year Level'),
        excel_lib.TextCellValue('Status'),
      ]);

      for (final card in allFilteredCards) {
        final idNo = card.studentIdNumber ?? 'N/A';
        final name = card.studentName ?? 'Unknown Student';
        final faculty = card.studentFaculty ?? 'N/A';
        final program = card.studentProgram ?? 'N/A';
        final yearLevel = card.studentYear ?? 'N/A';
        final status = card.status == ActivityCardStatus.cleared ? 'Cleared' : card.status.name;

        sheet.appendRow([
          excel_lib.TextCellValue(idNo),
          excel_lib.TextCellValue(name),
          excel_lib.TextCellValue(faculty),
          excel_lib.TextCellValue(program),
          excel_lib.TextCellValue(yearLevel),
          excel_lib.TextCellValue(status),
        ]);
      }

      final bytes = excel.encode();
      if (bytes == null) throw Exception("Failed to encode excel");

      final String cleanOrgName = orgName.replaceAll(RegExp(r'[^\w\s\-]'), '_');
      final String fileName = "${cleanOrgName}_Cleared_Students_${DateFormat('yyyyMMdd').format(DateTime.now())}.xlsx";

      final isSuccess = await FileSaverUtil.saveFile(Uint8List.fromList(bytes), fileName);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isSuccess ? 'Excel report downloaded successfully.' : 'Failed to save excel report.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export excel: $e')),
        );
      }
    }
  }

  Future<void> _selectClearedDateRange() async {
    final startDate = await showDatePicker(
      context: context,
      initialDate: _clearedDateRange?.start ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Select Start Date',
    );
    if (startDate != null) {
      if (!mounted) return;
      final endDate = await showDatePicker(
        context: context,
        initialDate: _clearedDateRange?.end ?? startDate,
        firstDate: startDate,
        lastDate: DateTime.now().add(const Duration(days: 365)),
        helpText: 'Select End Date',
      );
      if (endDate != null) {
        setState(() {
          _clearedDateRange = DateTimeRange(start: startDate, end: endDate);
          _clearedCurrentPage = 1;
        });
      }
    }
  }

  Future<void> _selectClearedTimeRange() async {
    final startTime = await showTimePicker(
      context: context,
      initialTime: _clearedStartTime ?? const TimeOfDay(hour: 8, minute: 0),
      helpText: 'Select Start Time',
    );
    if (startTime != null) {
      if (!mounted) return;
      final endTime = await showTimePicker(
        context: context,
        initialTime: _clearedEndTime ?? const TimeOfDay(hour: 17, minute: 0),
        helpText: 'Select End Time',
      );
      if (endTime != null) {
        setState(() {
          _clearedStartTime = startTime;
          _clearedEndTime = endTime;
          _clearedCurrentPage = 1;
        });
      }
    }
  }

  Widget _buildClearedStudentsTable(List<ActivityCard> cards, int totalItems, int totalPages) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: constraints.maxWidth > 800 ? constraints.maxWidth : 800,
                    ),
                    child: DataTable(
                      columnSpacing: AppSpacing.lg,
                      headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
                      columns: const [
                        DataColumn(label: Text('ID NO.', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('STUDENT', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('FACULTY', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('PROGRAM', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('EVENTS', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('FEES', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('COMPLETION', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('CLEARED DATE', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('ACTIONS', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: cards.map((card) => _buildClearedDataRow(card)).toList(),
                    ),
                  ),
                ),
              );
            },
          ),
          _buildPaginationControls(totalItems, totalPages),
        ],
      ),
    );
  }

  DataRow _buildClearedDataRow(ActivityCard card) {
    final name = card.studentName ?? 'Unknown Student';
    final program = card.studentProgram ?? 'N/A';
    
    final totalEvents = card.events.length;
    final completedEvents = card.events.where((e) => e.attendanceStatus == AttendanceStatus.completed || e.attendanceStatus == AttendanceStatus.excused || e.attendanceStatus == AttendanceStatus.sanctionCleared).length;
    final eventsDisplay = '$completedEvents/$totalEvents';
    
    final totalFees = card.fees.length;
    final paidFees = card.fees.where((f) => f.isPaid).length;
    final feesDisplay = '$paidFees/$totalFees';

    final clearedAtText = card.clearedAt != null
        ? DateFormat('MMM dd, yyyy hh:mm a').format(card.clearedAt!.toLocal())
        : 'N/A';

    final studentIdNo = card.studentIdNumber ?? 'N/A';

    return DataRow(
      cells: [
        DataCell(Text(studentIdNo, style: const TextStyle(fontWeight: FontWeight.w500))),
        DataCell(
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(name[0], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary)),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        DataCell(Text(card.studentFaculty ?? 'N/A')),
        DataCell(Text(program)),
        DataCell(
          Row(
            children: [
              const Icon(Icons.event_available_rounded, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(eventsDisplay, style: const TextStyle(fontSize: 11)),
            ],
          ),
        ),
        DataCell(
          Row(
            children: [
              const Icon(Icons.payments_rounded, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(feesDisplay, style: const TextStyle(fontSize: 11)),
            ],
          ),
        ),
        DataCell(
          Row(
            children: [
              SizedBox(
                width: 60,
                child: LinearProgressIndicator(
                  value: card.completionPercentage,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(_getCompletionColor(card.completionPercentage)),
                  minHeight: 4,
                ),
              ),
              const SizedBox(width: 8),
              Text('${(card.completionPercentage * 100).toInt()}%', style: TextStyle(fontSize: 11, color: _getCompletionColor(card.completionPercentage), fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        DataCell(Text(clearedAtText, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.green))),
        DataCell(
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            onPressed: () => context.push('${RoutePaths.workspaceActivityCards}/${card.studentId}'),
          ),
        ),
      ],
    );
  }

  Widget _buildPaginationControls(int totalItems, int totalPages) {
    final startItem = totalItems == 0 ? 0 : (_clearedCurrentPage - 1) * _clearedPageSize + 1;
    final endItem = (_clearedCurrentPage * _clearedPageSize) > totalItems
        ? totalItems
        : (_clearedCurrentPage * _clearedPageSize);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Showing $startItem to $endItem of $totalItems cleared clearances',
            style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[600]),
          ),
          Row(
            children: [
              Text(
                'Rows per page: ',
                style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[600]),
              ),
              DropdownButton<int>(
                value: _clearedPageSize,
                items: [5, 10, 20, 50]
                    .map((size) => DropdownMenuItem<int>(
                          value: size,
                          child: Text('$size', style: AppTextStyles.bodySmall),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _clearedPageSize = val;
                      _clearedCurrentPage = 1;
                    });
                  }
                },
              ),
              const SizedBox(width: AppSpacing.md),
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded),
                onPressed: _clearedCurrentPage > 1
                    ? () => setState(() => _clearedCurrentPage--)
                    : null,
              ),
              Text(
                '$_clearedCurrentPage of ${totalPages == 0 ? 1 : totalPages}',
                style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded),
                onPressed: _clearedCurrentPage < totalPages
                    ? () => setState(() => _clearedCurrentPage++)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsTable(List<ActivityCard> cards, String? orgType) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: constraints.maxWidth > 800 ? constraints.maxWidth : 800,
                ),
                child: DataTable(
                  columnSpacing: AppSpacing.lg,
                  headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
                  columns: const [
                    DataColumn(label: Text('ID NO.', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('STUDENT', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('FACULTY', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('PROGRAM', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('EVENTS', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('FEES', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('COMPLETION', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('STATUS', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('ACTIONS', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: cards.map((card) => _buildDataRow(card, orgType)).toList(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  DataRow _buildDataRow(ActivityCard card, String? orgType) {
    final name = card.studentName ?? 'Unknown Student';
    final program = card.studentProgram ?? 'N/A';
    
    final totalEvents = card.events.length;
    final completedEvents = card.events.where((e) => e.attendanceStatus == AttendanceStatus.completed || e.attendanceStatus == AttendanceStatus.excused || e.attendanceStatus == AttendanceStatus.sanctionCleared).length;
    final eventsDisplay = '$completedEvents/$totalEvents';
    
    final totalFees = card.fees.length;
    final paidFees = card.fees.where((f) => f.isPaid).length;
    final feesDisplay = '$paidFees/$totalFees';

    final studentIdNo = card.studentIdNumber ?? 'N/A';

    return DataRow(
      cells: [
        DataCell(Text(studentIdNo, style: const TextStyle(fontWeight: FontWeight.w500))),
        DataCell(
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(name[0], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary)),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        DataCell(Text(card.studentFaculty ?? 'N/A')),
        DataCell(Text(program)),
        DataCell(
          Row(
            children: [
              const Icon(Icons.event_available_rounded, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(eventsDisplay, style: const TextStyle(fontSize: 11)),
            ],
          ),
        ),
        DataCell(
          Row(
            children: [
              const Icon(Icons.payments_rounded, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(feesDisplay, style: const TextStyle(fontSize: 11)),
            ],
          ),
        ),
        DataCell(
          Row(
            children: [
              SizedBox(
                width: 60,
                child: LinearProgressIndicator(
                  value: card.completionPercentage,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(_getCompletionColor(card.completionPercentage)),
                  minHeight: 4,
                ),
              ),
              const SizedBox(width: 8),
              Text('${(card.completionPercentage * 100).toInt()}%', style: TextStyle(fontSize: 11, color: _getCompletionColor(card.completionPercentage), fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        DataCell(_buildStatusBadge(card.status, orgType)),
        DataCell(
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            onPressed: () => context.push('${RoutePaths.workspaceActivityCards}/${card.studentId}'),
          ),
        ),
      ],
    );
  }

  Color _getCompletionColor(double percentage) {
    if (percentage >= 1.0) return Colors.green;
    if (percentage >= 0.7) return AppColors.primary;
    if (percentage >= 0.4) return Colors.orange;
    return Colors.red;
  }

  Widget _buildStatusBadge(ActivityCardStatus status, String? orgType) {
    Color color;
    String label;

    switch (status) {
      case ActivityCardStatus.cleared:
        color = Colors.green;
        label = 'CLEARED';
        break;
      case ActivityCardStatus.draft:
        color = Colors.grey;
        label = 'DRAFT';
        break;
      case ActivityCardStatus.inProgress:
        color = Colors.blue;
        label = 'IN PROGRESS';
        break;
      case ActivityCardStatus.secretaryReview:
        color = Colors.amber.shade700;
        label = 'SECRETARY REVIEW';
        break;
      case ActivityCardStatus.treasurerReview:
        color = Colors.amber.shade700;
        label = 'TREASURER REVIEW';
        break;
      case ActivityCardStatus.governorReview:
        color = Colors.amber.shade700;
        label = orgType == 'faculty-based' ? 'GOVERNOR REVIEW' : 'PRESIDENT REVIEW';
        break;
      case ActivityCardStatus.adviserReview:
        color = Colors.amber.shade700;
        label = 'ADVISER REVIEW';
        break;
      case ActivityCardStatus.programHeadReview:
        color = Colors.amber.shade700;
        label = 'PROGRAM HEAD REVIEW';
        break;
      case ActivityCardStatus.deanReview:
        color = Colors.amber.shade700;
        label = 'DEAN REVIEW';
        break;
      case ActivityCardStatus.partiallySigned:
        color = AppColors.primary;
        label = 'PARTIALLY';
        break;
      case ActivityCardStatus.rejected:
        color = Colors.red;
        label = 'REJECTED';
        break;
      case ActivityCardStatus.inReview:
        color = Colors.blue;
        label = 'IN REVIEW';
        break;
      default:
        color = Colors.orange;
        label = 'PENDING';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold),
      ),
    );
  }
}
