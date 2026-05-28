import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../../users/widgets/user_management_header.dart';
import '../models/governor_finance_mock_data.dart';
import 'governor_create_fee_page.dart';

class GovernorCreatedFeesPage extends ConsumerWidget {
  const GovernorCreatedFeesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final fees = GovernorFinanceMockData.createdFees;

    return DashboardLayout(
      title: 'Created Fees',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserManagementHeader(
              title: 'Manage Fees',
              subtitle: 'View and edit the payment requirements you have created.',
              actions: [
                HeaderActionButton(
                  icon: Icons.add_rounded,
                  label: 'Create Fee',
                  onPressed: () => _navigateToCreate(context),
                  isPrimary: true,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            
            if (fees.isEmpty)
              _buildEmptyState()
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: fees.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) {
                  final fee = fees[index];
                  return _buildFeeCard(context, fee);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeeCard(BuildContext context, Map<String, dynamic> fee) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fee['title'] ?? '',
                        style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        fee['isMandatory'] ? 'OBLIGATORY' : 'NON-OBLIGATORY',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '₱${(fee['amount'] as double).toStringAsFixed(2)}',
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                PopupMenuButton<String>(
                  onSelected: (val) {
                    if (val == 'edit') _navigateToEdit(context, fee);
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit Fee')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete Fee')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              fee['description'] ?? '',
              style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[700], height: 1.4),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.lg),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Icon(Icons.person_outline_rounded, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Receiver: ${fee['receiverName']}',
                  style: AppTextStyles.labelSmall.copyWith(color: Colors.grey[600]),
                ),
                const Spacer(),
                FilledButton.tonal(
                  onPressed: () {},
                  child: const Text('View Paid Students'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: AppSpacing.md),
          const Text('No fees created yet', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        ],
      ),
    );
  }

  void _navigateToCreate(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const GovernorCreateFeePage()));
  }

  void _navigateToEdit(BuildContext context, Map<String, dynamic> fee) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => GovernorCreateFeePage(initialData: fee)));
  }
}
