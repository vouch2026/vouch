import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../../organizations/providers/workspace_provider.dart';
import '../../academic_structure/providers/term_provider.dart';
import '../providers/sanction_provider.dart';
import 'sanction_rules_page.dart';
import '../models/sanction_model.dart';
import '../../auth/providers/auth_provider.dart';
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
      title: 'Sanctions Management',
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Sanction Records'),
              Tab(text: 'Sanction Rules'),
            ],
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textGrey,
            indicatorColor: AppColors.primary,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                const _SanctionRecordsTab(),
                const SanctionRulesPage(),
              ],
            ),
          ),
        ],
      ),
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
      loading: () => const Center(child: CircularProgressIndicator()),
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
                    Text('${sanction.totalAbsences} Absences', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textGrey)),
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
                    try {
                      await ref.read(sanctionRepositoryProvider).receiveSanctionItem(sanction.id, user.id!);
                      ref.invalidate(workspaceSanctionsProvider);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sanction marked as received.')));
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
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
