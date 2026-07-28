import 'package:vouch_v2/core/widgets/loaders/flickr_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../providers/sanction_provider.dart';
import '../models/sanction_model.dart';
import 'package:go_router/go_router.dart';
import '../../../routes/route_names.dart';
import '../../../routes/route_paths.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart' as excel_lib;
import '../../../core/utils/file_saver_helper.dart';
import 'dart:typed_data';
import '../../../core/permissions/app_permissions.dart';
import '../../../core/config/supabase_config.dart';
import '../../users/widgets/user_management_header.dart';
import 'package:vouch_v2/shared/widgets/loading_overlay.dart';
import '../../../core/widgets/states/offline_state_view.dart';
import '../../academic_structure/providers/term_provider.dart';
import '../../organizations/providers/workspace_provider.dart';

class WorkspaceSanctionsPage extends ConsumerStatefulWidget {
  const WorkspaceSanctionsPage({super.key});

  @override
  ConsumerState<WorkspaceSanctionsPage> createState() => _WorkspaceSanctionsPageState();
}

class _WorkspaceSanctionsPageState extends ConsumerState<WorkspaceSanctionsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSyncing = false;
  final _client = SupabaseConfig.client;

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

  String _formatScoreRange(dynamic min, dynamic max) {
    final double minVal = (min as num?)?.toDouble() ?? 0.0;
    final String minStr = minVal % 1 == 0 ? minVal.toInt().toString() : minVal.toString();

    if (max == null) {
      return '$minStr+';
    }

    final double maxVal = (max as num).toDouble();
    if (minVal == maxVal) {
      return minStr;
    }

    final String maxStr = maxVal % 1 == 0 ? maxVal.toInt().toString() : maxVal.toString();
    return '$minStr - $maxStr';
  }

  Future<void> _deleteRule(BuildContext context, String ruleId) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _client.from('sanction_rules').delete().eq('id', ruleId);
      ref.invalidate(sanctionRulesProvider);
      ref.invalidate(workspaceSanctionsProvider);
      ref.invalidate(mySanctionsProvider);
      ref.invalidate(workspaceMandatoryEventsCountProvider);
      messenger.showSnackBar(const SnackBar(content: Text('Rule deleted successfully.')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
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
        excel_lib.TextCellValue('Total Sanction Score'),
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



  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleCard(BuildContext context, Map<String, dynamic> rule, bool canManageRules) {
    final theme = Theme.of(context);
    final minAbsence = rule['min_absence'];
    final maxAbsence = rule['max_absence'];
    final worth = rule['required_value'] != null ? (rule['required_value'] as num).toDouble() : null;
    final itemDesc = rule['item_description'] ?? 'No Description';
    
    String ruleTypeLabel = 'SINGLE SCORE';
    if (maxAbsence == null) {
      ruleTypeLabel = 'SCORE AND ABOVE';
    } else if (minAbsence != maxAbsence) {
      ruleTypeLabel = 'SCORE RANGE';
    }
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        itemDesc,
                        style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          ruleTypeLabel,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      worth != null ? '₱${worth.toStringAsFixed(2)}' : 'No Cash Worth',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: worth != null ? theme.colorScheme.primary : Colors.grey[500],
                      ),
                    ),
                  ],
                ),
                if (canManageRules) ...[
                  const SizedBox(width: AppSpacing.xs),
                  PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    onSelected: (val) {
                      if (val == 'edit') {
                        context.push(RoutePaths.workspaceEditSanctionRule, extra: rule);
                      } else if (val == 'delete') {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            title: Text(
                              'Delete Sanction Rule',
                              style: AppTextStyles.titleLarge.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            content: Text(
                              'Are you sure you want to delete this sanction rule? This action cannot be undone.',
                              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () async {
                                  Navigator.pop(context);
                                  _deleteRule(context, rule['id']);
                                },
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit Rule'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete Rule', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            const Spacer(),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Icon(Icons.gavel_rounded, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Absence Range: ${_formatScoreRange(minAbsence, maxAbsence)}',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;
    final isTablet = size.width >= 768 && size.width < 1024;
    final padding = isMobile 
        ? AppSpacing.md 
        : (isTablet ? AppSpacing.lg : AppSpacing.xl);

    final activeRole = ref.watch(workspaceProvider).activeRole;
    final canManageRules = activeRole?.hasPermission(AppPermissions.createSanctionRules) ?? false;
    final canSync = activeRole?.hasPermission(AppPermissions.receiveSanctionItems) ?? false;

    final sanctionsAsync = ref.watch(workspaceSanctionsProvider);
    final rulesAsync = ref.watch(sanctionRulesProvider);
    final maxSanctionScoreAsync = ref.watch(workspaceMandatoryEventsCountProvider);

    final offlineError = [sanctionsAsync.error, rulesAsync.error, maxSanctionScoreAsync.error]
        .firstWhere((e) => OfflineStateView.isOfflineError(e), orElse: () => null);

    if (offlineError != null) {
      return DashboardLayout(
        title: 'Sanctions',
        child: OfflineStateView(
          onRetry: () {
            ref.invalidate(workspaceSanctionsProvider);
            ref.invalidate(sanctionRulesProvider);
            ref.invalidate(workspaceMandatoryEventsCountProvider);
          },
        ),
      );
    }

    int maxSanctionScore = maxSanctionScoreAsync.value ?? 0;
    int totalRules = rulesAsync.value?.length ?? 0;
    int activeSanctions = sanctionsAsync.value?.where((s) => s.status != 'Item Received').length ?? 0;
    int clearedSanctions = sanctionsAsync.value?.where((s) => s.status == 'Item Received').length ?? 0;

    final rulesWidget = rulesAsync.when(
      data: (rules) {
        if (rules.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  Icon(Icons.rule_folder_rounded, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: AppSpacing.sm),
                  Text('No sanction rules defined yet.', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, gridConstraints) {
            int crossAxisCount = 1;
            if (gridConstraints.maxWidth > 1200) {
              crossAxisCount = 3;
            } else if (gridConstraints.maxWidth > 768) {
              crossAxisCount = 2;
            }

            if (crossAxisCount == 1) {
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: rules.length,
                separatorBuilder: (_, index) => const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) => _buildRuleCard(context, rules[index], canManageRules),
              );
            } else {
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                  mainAxisExtent: 160,
                ),
                itemCount: rules.length,
                itemBuilder: (context, index) => _buildRuleCard(context, rules[index], canManageRules),
              );
            }
          },
        );
      },
      loading: () => const Center(child: FlickrLoader()),
      error: (err, _) {
        if (OfflineStateView.isOfflineError(err)) {
          return OfflineStateView(
            onRetry: () => ref.invalidate(sanctionRulesProvider),
          );
        }
        return Center(child: Text('Error loading rules: $err'));
      },
    );

    final sanctionsWidget = sanctionsAsync.when(
      data: (sanctions) {
        if (sanctions.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 64),
              child: Column(
                children: [
                  Icon(Icons.gavel_rounded, size: 64, color: AppColors.textGrey.withValues(alpha: 0.2)),
                  const SizedBox(height: AppSpacing.md),
                  const Text('No sanction records found.', style: TextStyle(color: AppColors.textGrey)),
                ],
              ),
            ),
          );
        }

        final filteredSanctions = sanctions.where((s) {
          final query = _searchQuery.toLowerCase();
          return (s.studentName ?? '').toLowerCase().contains(query) ||
              (s.studentIdNumber ?? '').toLowerCase().contains(query) ||
              (s.programName ?? '').toLowerCase().contains(query);
        }).toList();

        final theme = Theme.of(context);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search sanctions by name, ID, or program...',
                        hintStyle: AppTextStyles.bodySmall.copyWith(
                          color: Colors.grey[400],
                        ),
                        prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Colors.grey),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18, color: Colors.grey),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      style: AppTextStyles.bodyMedium,
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                    ),
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
            Card(
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
                            DataColumn(label: Text('Total Sanction Score')),
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
          ],
        );
      },
      loading: () => const Center(child: FlickrLoader()),
      error: (err, _) {
        if (OfflineStateView.isOfflineError(err)) {
          return OfflineStateView(
            onRetry: () => ref.invalidate(workspaceSanctionsProvider),
          );
        }
        return Center(child: Text('Error loading sanctions: $err'));
      },
    );

    return DashboardLayout(
      title: 'Sanctions',
      child: LoadingOverlay(
        isLoading: _isSyncing,
        child: RefreshIndicator(
          onRefresh: () async {
            try {
              await ref.refresh(workspaceSanctionsProvider.future);
              await ref.refresh(sanctionRulesProvider.future);
              await ref.refresh(workspaceMandatoryEventsCountProvider.future);
            } catch (_) {}
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.gavel_rounded, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Sanctions',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              UserManagementHeader(
                title: 'Manage Sanctions',
                subtitle: 'Define rules and view sanction records of students.',
                actions: [
                  if (canSync)
                    HeaderActionButton(
                      icon: Icons.sync_rounded,
                      label: 'Assign Sanctions',
                      onPressed: () async {
                        final workspace = ref.read(workspaceProvider);
                        final org = workspace.selectedOrganization;
                        final term = ref.read(activeTermProvider).value;
                        if (org == null || term == null) return;

                        final messenger = ScaffoldMessenger.of(context);
                        setState(() => _isSyncing = true);
                        try {
                          await ref.read(sanctionRepositoryProvider).generateSanctionsForTerm(term.id, org.id, org.type);
                          ref.invalidate(workspaceSanctionsProvider);
                          ref.invalidate(mySanctionsProvider);
                          ref.invalidate(sanctionRulesProvider);
                          ref.invalidate(workspaceMandatoryEventsCountProvider);
                          
                          messenger.showSnackBar(const SnackBar(content: Text('Sanction records synchronized successfully.')));
                        } catch (e) {
                          messenger.showSnackBar(SnackBar(content: Text('Error syncing: $e')));
                        } finally {
                          setState(() => _isSyncing = false);
                        }
                      },
                    ),
                  if (canManageRules) ...[
                    const SizedBox(width: AppSpacing.md),
                    HeaderActionButton(
                      icon: Icons.add_rounded,
                      label: 'Add Rule',
                      onPressed: () => context.push(RoutePaths.workspaceCreateSanctionRule),
                      isPrimary: true,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              LayoutBuilder(
                builder: (context, constraints) {
                  int crossCount = 1;
                  double ratio = 3.5;
                  if (constraints.maxWidth > 900) {
                    crossCount = 4;
                    ratio = 2.0;
                  } else if (constraints.maxWidth > 600) {
                    crossCount = 2;
                    ratio = 2.5;
                  }

                  return GridView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossCount,
                      crossAxisSpacing: AppSpacing.md,
                      mainAxisSpacing: AppSpacing.md,
                      childAspectRatio: ratio,
                    ),
                    children: [
                      _buildStatCard(
                        title: 'Max Sanction Score',
                        value: maxSanctionScore.toString(),
                        icon: Icons.assignment_turned_in_rounded,
                        color: AppColors.primary,
                      ),
                      _buildStatCard(
                        title: 'Total Rules',
                        value: totalRules.toString(),
                        icon: Icons.rule_rounded,
                        color: AppColors.primary,
                      ),
                      _buildStatCard(
                        title: 'Pending Sanctions',
                        value: activeSanctions.toString(),
                        icon: Icons.pending_actions_rounded,
                        color: Colors.orange,
                      ),
                      _buildStatCard(
                        title: 'Cleared Sanctions',
                        value: clearedSanctions.toString(),
                        icon: Icons.check_circle_rounded,
                        color: Colors.green,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('Sanction Rules', style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('Rules defining required items to clear sanction scores.', style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
              const SizedBox(height: AppSpacing.md),
              rulesWidget,
              const SizedBox(height: AppSpacing.xxl),
              Text('Sanction Records', style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('View and manage students who have outstanding or cleared sanctions.', style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
              const SizedBox(height: AppSpacing.md),
              sanctionsWidget,
            ],
          ),
        ),
      ),
    ),
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
