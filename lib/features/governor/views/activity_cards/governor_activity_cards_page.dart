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
import '../../widgets/activity_cards/compliance_analytics_dashboard.dart';
import 'package:go_router/go_router.dart';
import '../../../../routes/route_paths.dart';

class GovernorActivityCardsPage extends ConsumerStatefulWidget {
  const GovernorActivityCardsPage({super.key});

  @override
  ConsumerState<GovernorActivityCardsPage> createState() => _GovernorActivityCardsPageState();
}

class _GovernorActivityCardsPageState extends ConsumerState<GovernorActivityCardsPage> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'All';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(() {
      setState(() {});
    });
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
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;
    final padding = EdgeInsets.symmetric(
      horizontal: isMobile ? AppSpacing.lg : AppSpacing.xl,
      vertical: isMobile ? AppSpacing.lg : AppSpacing.xl,
    );

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
                    actions: [
                      HeaderActionButton(
                        icon: Icons.file_download_rounded,
                        label: 'Export Compliance',
                        onPressed: () {},
                      ),
                    ],
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
                        Tab(text: 'Student Clearances'),
                        Tab(text: 'Compliance Analytics'),
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
  
                    final matchesSearch = card.studentName?.toLowerCase().contains(query) ?? false;
                    final matchesStatus = _selectedStatus == 'All' || 
                        card.status.name.toLowerCase() == _selectedStatus.toLowerCase().replaceAll(' ', '');
                    return matchesSearch && matchesStatus;
                  }).toList();
                  
                  return _buildClearanceList(context, filteredCards);
                },
                loading: () => const Center(child: FlickrLoader()),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
              cardsAsync.when(
                data: (cards) => ComplianceAnalyticsDashboard(cards: cards),
                loading: () => const Center(child: FlickrLoader()),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClearanceList(BuildContext context, List<ActivityCard> cards) {
    return Column(
      children: [
        _buildFilters(),
        const SizedBox(height: AppSpacing.lg),
        Expanded(child: _buildStudentsTable(cards)),
      ],
    );
  }

  Widget _buildFilters() {
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
              child: _buildStatusDropdown(),
            ),
          ],
        );
      },
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

  Widget _buildStudentsTable(List<ActivityCard> cards) {
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
                    DataColumn(label: Text('STUDENT', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('PROGRAM', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('EVENTS', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('FEES', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('COMPLETION', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('STATUS', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('ACTIONS', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: cards.map((card) => _buildDataRow(card)).toList(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  DataRow _buildDataRow(ActivityCard card) {
    final name = card.studentName ?? 'Unknown Student';
    final program = card.studentProgram ?? 'N/A';
    
    final totalEvents = card.events.length;
    final completedEvents = card.events.where((e) => e.attendanceStatus == AttendanceStatus.completed || e.attendanceStatus == AttendanceStatus.excused || e.attendanceStatus == AttendanceStatus.sanctionCleared).length;
    final eventsDisplay = '$completedEvents/$totalEvents';
    
    final totalFees = card.fees.length;
    final paidFees = card.fees.where((f) => f.isPaid).length;
    final feesDisplay = '$paidFees/$totalFees';

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
        DataCell(_buildStatusBadge(card.status)),
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

  Widget _buildStatusBadge(ActivityCardStatus status) {
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
        label = 'GOVERNOR REVIEW';
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
