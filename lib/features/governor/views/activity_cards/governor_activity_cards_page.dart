import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/layouts/dashboard_layout.dart';
import '../../../users/widgets/user_management_header.dart';
import '../../../activity_cards/models/activity_card_models.dart';
import '../../widgets/activity_cards/compliance_analytics_dashboard.dart';
import 'package:go_router/go_router.dart';
import '../../../../routes/route_paths.dart';

class GovernorActivityCardsPage extends StatefulWidget {
  const GovernorActivityCardsPage({super.key});

  @override
  State<GovernorActivityCardsPage> createState() => _GovernorActivityCardsPageState();
}

class _GovernorActivityCardsPageState extends State<GovernorActivityCardsPage> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'All';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DashboardLayout(
      title: 'Organization Activity Cards',
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: UserManagementHeader(
                    title: 'Activity Cards',
                    subtitle: 'Manage student clearances, signatures, and compliance',
                    actions: [
                      HeaderActionButton(
                        icon: Icons.file_download_rounded,
                        label: 'Export Compliance',
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
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
                        Tab(text: 'Student Clearances'),
                        Tab(text: 'Compliance Analytics'),
                      ],
                    ),
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
            _buildClearanceList(context),
            const ComplianceAnalyticsDashboard(),
          ],
        ),
      ),
    );
  }

  Widget _buildClearanceList(BuildContext context) {
    return Column(
      children: [
        _buildFilters(),
        const SizedBox(height: AppSpacing.lg),
        Expanded(child: _buildStudentsTable()),
      ],
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: LayoutBuilder(
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
                child: _buildStatusDropdown(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedStatus,
          items: ['All', 'Cleared', 'Partially Signed', 'Pending', 'Rejected']
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: (val) => setState(() => _selectedStatus = val!),
        ),
      ),
    );
  }

  Widget _buildStudentsTable() {
    return Card(
      margin: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 800),
            child: DataTable(
              columnSpacing: AppSpacing.lg,
              headingRowColor: MaterialStateProperty.all(Colors.grey.shade50),
              columns: const [
                DataColumn(label: Text('STUDENT', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('PROGRAM', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('EVENTS', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('FEES', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('COMPLETION', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('STATUS', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('ACTIONS', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: [
                _buildDataRow('Juan Dela Cruz', 'BSIT', '2/3', '2/2', 0.75, ActivityCardStatus.partiallySigned),
                _buildDataRow('Maria Santos', 'BSCS', '3/3', '2/2', 1.0, ActivityCardStatus.cleared),
                _buildDataRow('Michael Chen', 'BSIT', '1/3', '0/1', 0.40, ActivityCardStatus.pending),
                _buildDataRow('Sarah Johnson', 'BSCS', '3/3', '1/1', 0.90, ActivityCardStatus.partiallySigned),
              ],
            ),
          ),
        ),
      ),
    );
  }

  DataRow _buildDataRow(String name, String program, String events, String fees, double completion, ActivityCardStatus status) {
    return DataRow(
      cells: [
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
        DataCell(Text(program)),
        DataCell(
          Row(
            children: [
              const Icon(Icons.event_available_rounded, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(events, style: const TextStyle(fontSize: 11)),
            ],
          ),
        ),
        DataCell(
          Row(
            children: [
              const Icon(Icons.payments_rounded, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(fees, style: const TextStyle(fontSize: 11)),
            ],
          ),
        ),
        DataCell(
          Row(
            children: [
              SizedBox(
                width: 60,
                child: LinearProgressIndicator(
                  value: completion,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(_getCompletionColor(completion)),
                  minHeight: 4,
                ),
              ),
              const SizedBox(width: 8),
              Text('${(completion * 100).toInt()}%', style: TextStyle(fontSize: 11, color: _getCompletionColor(completion), fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        DataCell(_buildStatusBadge(status)),
        DataCell(
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            onPressed: () => context.push('${RoutePaths.workspaceActivityCards}/student-123'),
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

  Widget _buildStatusBadge(ActivityCardStatus status) {
    Color color;
    String label;

    switch (status) {
      case ActivityCardStatus.cleared:
        color = Colors.green;
        label = 'CLEARED';
        break;
      case ActivityCardStatus.partiallySigned:
        color = AppColors.primary;
        label = 'PARTIALLY';
        break;
      case ActivityCardStatus.rejected:
        color = Colors.red;
        label = 'REJECTED';
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
