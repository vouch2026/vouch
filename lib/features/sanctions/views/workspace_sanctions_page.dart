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
import '../../auth/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import '../../../routes/route_names.dart';
import 'package:intl/intl.dart';

class WorkspaceSanctionsPage extends ConsumerStatefulWidget {
  const WorkspaceSanctionsPage({super.key});

  @override
  ConsumerState<WorkspaceSanctionsPage> createState() => _WorkspaceSanctionsPageState();
}

class _WorkspaceSanctionsPageState extends ConsumerState<WorkspaceSanctionsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      title: 'Compliance & Sanctions',
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Compliance'),
              Tab(text: 'Sanctions'),
            ],
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textGrey,
            indicatorColor: AppColors.primary,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                _ComplianceTab(),
                _SanctionsManagementTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ComplianceTab extends ConsumerStatefulWidget {
  const _ComplianceTab();

  @override
  ConsumerState<_ComplianceTab> createState() => _ComplianceTabState();
}

class _ComplianceTabState extends ConsumerState<_ComplianceTab> {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final complianceAsync = ref.watch(workspaceComplianceProvider);

    return complianceAsync.when(
      data: (members) {
        if (members.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.assignment_turned_in_rounded, size: 64, color: AppColors.textGrey.withOpacity(0.2)),
                const SizedBox(height: AppSpacing.md),
                const Text('No members found.', style: TextStyle(color: AppColors.textGrey)),
              ],
            ),
          );
        }

        final filteredMembers = members.where((m) {
          final query = _searchQuery.toLowerCase();
          return m.name.toLowerCase().contains(query) ||
              m.schoolId.toLowerCase().contains(query) ||
              m.program.toLowerCase().contains(query);
        }).toList();

        return Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search input
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search members by name, ID, or program...',
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
              const SizedBox(height: AppSpacing.lg),
              
              // Members list table
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
                              headingRowColor: MaterialStateProperty.all(theme.colorScheme.surfaceVariant.withOpacity(0.3)),
                              columns: const [
                                DataColumn(label: Text('Student ID no.')),
                                DataColumn(label: Text('Name')),
                                DataColumn(label: Text('Program')),
                                DataColumn(label: Text('Year')),
                                DataColumn(label: Text('Event Attended')),
                                DataColumn(label: Text('Sanction Score')),
                              ],
                              rows: filteredMembers.map((member) {
                                final isCompliant = member.sanctionScore == 0;
                                final scoreColor = isCompliant ? AppColors.success : AppColors.error;
                                
                                return DataRow(
                                  onSelectChanged: (_) {
                                    context.pushNamed(
                                      RouteNames.workspaceSanctionProfile,
                                      pathParameters: {'studentId': member.studentId},
                                    );
                                  },
                                  cells: [
                                    DataCell(Text(member.schoolId, style: AppTextStyles.bodyMedium)),
                                    DataCell(Text(member.name, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold))),
                                    DataCell(Text(member.program, style: AppTextStyles.bodyMedium)),
                                    DataCell(Text(_getYearDisplay(member.year), style: AppTextStyles.bodyMedium)),
                                    DataCell(Text('${member.attendedEvents} / ${member.totalMandatoryEvents}', style: AppTextStyles.bodyMedium)),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: scoreColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: scoreColor.withOpacity(0.2)),
                                        ),
                                        child: Text(
                                          member.sanctionScore % 1 == 0
                                              ? member.sanctionScore.toInt().toString()
                                              : member.sanctionScore.toStringAsFixed(1),
                                          style: TextStyle(
                                            color: scoreColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
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

class _SanctionsManagementTab extends StatefulWidget {
  const _SanctionsManagementTab();

  @override
  State<_SanctionsManagementTab> createState() => _SanctionsManagementTabState();
}

class _SanctionsManagementTabState extends State<_SanctionsManagementTab> {
  String _currentView = 'records'; // 'records' or 'rules'

  @override
  Widget build(BuildContext context) {
    return Column(
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
    );
  }
}

class _SanctionRecordsTab extends ConsumerWidget {
  const _SanctionRecordsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sanctionsAsync = ref.watch(workspaceSanctionsProvider);

    return sanctionsAsync.when(
      data: (sanctions) {
        if (sanctions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.gavel_rounded, size: 64, color: AppColors.textGrey.withOpacity(0.2)),
                const SizedBox(height: AppSpacing.md),
                const Text('No sanction records found.', style: TextStyle(color: AppColors.textGrey)),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.xl),
          itemCount: sanctions.length,
          separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) {
            final sanction = sanctions[index];
            return _SanctionRecordCard(sanction: sanction);
          },
        );
      },
      loading: () => const Center(child: FlickrLoader()),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }
}

class _SanctionRecordCard extends ConsumerWidget {
  final SanctionModel sanction;
  const _SanctionRecordCard({required this.sanction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isReceived = sanction.status == 'Item Received';
    final user = ref.watch(userProfileProvider).value;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isReceived ? AppColors.success.withOpacity(0.2) : AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(sanction.studentName ?? 'Unknown Student', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                    Text(
                      '${sanction.totalAbsences % 1 == 0 ? sanction.totalAbsences.toInt().toString() : sanction.totalAbsences.toStringAsFixed(1)} Sanction Score',
                      style: AppTextStyles.labelSmall.copyWith(color: AppColors.textGrey),
                    ),
                  ],
                ),
                _StatusBadge(status: sanction.status),
              ],
            ),
            const Divider(height: AppSpacing.xl),
            Row(
              children: [
                const Icon(Icons.inventory_2_outlined, size: 16, color: AppColors.textGrey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Requirement: ${sanction.requiredItem}',
                    style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            if (isReceived) ...[
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  const Icon(Icons.check_circle_outline_rounded, size: 16, color: AppColors.success),
                  const SizedBox(width: 8),
                  Text(
                    'Received by ${sanction.receivedByName} on ${DateFormat('MMM dd, yyyy').format(sanction.receivedAt!)}',
                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.success),
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () async {
                    if (user == null) return;
                    final messenger = ScaffoldMessenger.of(context);
                    try {
                      await ref.read(sanctionRepositoryProvider).receiveSanctionItem(sanction.id, user.id!);
                      ref.invalidate(workspaceSanctionsProvider);
                      ref.invalidate(workspaceComplianceProvider);
                      messenger.showSnackBar(const SnackBar(content: Text('Sanction marked as received.')));
                    } catch (e) {
                      messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  },
                  icon: const Icon(Icons.how_to_reg_rounded),
                  label: const Text('Mark as Received'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ],
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
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
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
