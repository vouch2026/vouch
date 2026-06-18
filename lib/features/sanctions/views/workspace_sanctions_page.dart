import 'package:vouch_v2/core/widgets/loaders/flickr_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../providers/sanction_provider.dart';
import 'sanction_rules_page.dart';
import '../models/sanction_model.dart';
import 'package:go_router/go_router.dart';
import '../../../routes/route_names.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart' as excel_lib;
import '../../../core/utils/file_saver_helper.dart';
import 'dart:typed_data';

class WorkspaceSanctionsPage extends ConsumerStatefulWidget {
  const WorkspaceSanctionsPage({super.key});

  @override
  ConsumerState<WorkspaceSanctionsPage> createState() => _WorkspaceSanctionsPageState();
}

class _WorkspaceSanctionsPageState extends ConsumerState<WorkspaceSanctionsPage> {
  String _currentView = 'records'; // 'records' or 'rules'

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      title: 'Compliance & Sanctions',
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
            child: Row(
              children: [
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'records', label: Text('Sanction Records'), icon: Icon(Icons.gavel_rounded)),
                    ButtonSegment(value: 'rules', label: Text('Sanction Rules'), icon: Icon(Icons.rule_rounded)),
                  ],
                  selected: {_currentView},
                  onSelectionChanged: (val) {
                    setState(() {
                      _currentView = val.first;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _currentView == 'records'
                ? const _SanctionRecordsTab()
                : const SanctionRulesPage(),
          ),
        ],
      ),
    );
  }
}

class _SanctionRecordsTab extends ConsumerStatefulWidget {
  const _SanctionRecordsTab();

  @override
  ConsumerState<_SanctionRecordsTab> createState() => _SanctionRecordsTabState();
}

class _SanctionRecordsTabState extends ConsumerState<_SanctionRecordsTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getYearDisplay(int? year) {
    if (year == null) return 'N/A';
    switch (year) {
      case 1:
        return '1st Year';
      case 2:
        return '2nd Year';
      case 3:
        return '3rd Year';
      case 4:
        return '4th Year';
      default:
        return '$year\'th Year';
    }
  }

  Future<void> _downloadExcelReport(List<SanctionModel> sanctions) async {
    try {
      final excel = excel_lib.Excel.createExcel();
      final defaultSheet = excel.getDefaultSheet() ?? 'Sheet1';
      final sheet = excel[defaultSheet];

      sheet.appendRow([
        excel_lib.TextCellValue('Sanction Report'),
      ]);
      sheet.appendRow([
        excel_lib.TextCellValue('Date Generated'),
        excel_lib.TextCellValue(DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())),
      ]);
      sheet.appendRow([]);

      sheet.appendRow([
        excel_lib.TextCellValue('Student ID'),
        excel_lib.TextCellValue('Student Name'),
        excel_lib.TextCellValue('Program'),
        excel_lib.TextCellValue('Year Level'),
        excel_lib.TextCellValue('Sanction Score'),
        excel_lib.TextCellValue('Assigned Sanction'),
        excel_lib.TextCellValue('Status'),
        excel_lib.TextCellValue('Received By'),
        excel_lib.TextCellValue('Received At'),
      ]);

      for (final sanction in sanctions) {
        final yearDisplay = sanction.yearLevel == null ? 'N/A' : _getYearDisplay(sanction.yearLevel);
        
        final formattedScore = sanction.totalAbsences % 1 == 0
            ? sanction.totalAbsences.toInt().toString()
            : sanction.totalAbsences.toStringAsFixed(1);

        final receivedAtStr = sanction.receivedAt != null
            ? DateFormat('yyyy-MM-dd').format(sanction.receivedAt!)
            : '-';

        sheet.appendRow([
          excel_lib.TextCellValue(sanction.studentIdNumber ?? '-'),
          excel_lib.TextCellValue(sanction.studentName ?? 'Unknown'),
          excel_lib.TextCellValue(sanction.programName ?? 'N/A'),
          excel_lib.TextCellValue(yearDisplay),
          excel_lib.TextCellValue(formattedScore),
          excel_lib.TextCellValue(sanction.requiredItem),
          excel_lib.TextCellValue(sanction.status),
          excel_lib.TextCellValue(sanction.receivedByName ?? '-'),
          excel_lib.TextCellValue(receivedAtStr),
        ]);
      }

      final bytes = excel.encode();
      if (bytes == null) throw Exception("Failed to encode excel");

      final String fileName = "Sanction_Report_${DateFormat('yyyyMMdd').format(DateTime.now())}.xlsx";
      
      final isSuccess = await FileSaverUtil.saveFile(Uint8List.fromList(bytes), fileName);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isSuccess ? 'Sanction report downloaded successfully!' : 'Failed to download report.'),
            backgroundColor: isSuccess ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error downloading report: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sanctionsAsync = ref.watch(workspaceSanctionsProvider);

    return sanctionsAsync.when(
      data: (sanctions) {
        if (sanctions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.gavel_rounded, size: 64, color: AppColors.textGrey.withValues(alpha: 0.2)),
                const SizedBox(height: AppSpacing.md),
                const Text('No sanction records found.', style: TextStyle(color: AppColors.textGrey)),
              ],
            ),
          );
        }

        final filteredSanctions = sanctions.where((s) {
          final query = _searchQuery.toLowerCase();
          return (s.studentName ?? '').toLowerCase().contains(query) ||
              (s.studentIdNumber ?? '').toLowerCase().contains(query) ||
              (s.programName ?? '').toLowerCase().contains(query);
        }).toList();

        return Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search sanctions by name, ID, or program...',
                        prefixIcon: const Icon(Icons.search_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      ),
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  OutlinedButton.icon(
                    onPressed: () => _downloadExcelReport(filteredSanctions),
                    icon: const Icon(Icons.download_rounded),
                    label: const Text('Download Excel'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minWidth: constraints.maxWidth),
                          child: SingleChildScrollView(
                            child: DataTable(
                              showCheckboxColumn: false,
                              columnSpacing: AppSpacing.lg,
                              headingRowColor: WidgetStateProperty.all(theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)),
                              columns: const [
                                DataColumn(label: Text('Student ID no.')),
                                DataColumn(label: Text('Name')),
                                DataColumn(label: Text('Program')),
                                DataColumn(label: Text('Year Level')),
                                DataColumn(label: Text('Sanction Score')),
                                DataColumn(label: Text('Assigned Sanction')),
                                DataColumn(label: Text('Status')),
                              ],
                              rows: filteredSanctions.map((sanction) {
                                final scoreColor = sanction.totalAbsences == 0 ? AppColors.success : AppColors.error;

                                return DataRow(
                                  onSelectChanged: (_) {
                                    context.pushNamed(
                                      RouteNames.workspaceSanctionProfile,
                                      pathParameters: {'studentId': sanction.studentId},
                                    );
                                  },
                                  cells: [
                                    DataCell(Text(sanction.studentIdNumber ?? 'N/A', style: AppTextStyles.bodyMedium)),
                                    DataCell(Text(sanction.studentName ?? 'Unknown', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold))),
                                    DataCell(Text(sanction.programName ?? 'N/A', style: AppTextStyles.bodyMedium)),
                                    DataCell(Text(_getYearDisplay(sanction.yearLevel), style: AppTextStyles.bodyMedium)),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: scoreColor.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: scoreColor.withValues(alpha: 0.2)),
                                        ),
                                        child: Text(
                                          sanction.totalAbsences % 1 == 0
                                              ? sanction.totalAbsences.toInt().toString()
                                              : sanction.totalAbsences.toStringAsFixed(1),
                                          style: TextStyle(
                                            color: scoreColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        sanction.requiredItem,
                                        style: AppTextStyles.bodyMedium,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    DataCell(
                                      _StatusBadge(status: sanction.status),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: FlickrLoader()),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isReceived = status == 'Item Received';
    final color = isReceived ? AppColors.success : AppColors.warning;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
