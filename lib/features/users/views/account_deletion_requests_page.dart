import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/loaders/flickr_loader.dart';
import '../../../../shared/layouts/dashboard_layout.dart';
import '../../profile/providers/account_deletion_provider.dart';
import '../../profile/controllers/account_deletion_controller.dart';
import '../../profile/models/account_deletion_request.dart';
import '../widgets/user_management_header.dart';

class AccountDeletionRequestsPage extends ConsumerWidget {
  const AccountDeletionRequestsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(accountDeletionRequestsProvider);

    return DashboardLayout(
      title: 'Deletion Requests',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserManagementHeader(
              title: 'Account Deletion Requests',
              subtitle: 'Review and process student requests to permanently purge accounts and clear institutional records.',
              actions: [
                HeaderActionButton(
                  icon: Icons.refresh_rounded,
                  label: 'Refresh',
                  onPressed: () {
                    ref.invalidate(accountDeletionRequestsProvider);
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            
            // KPI Summary Card
            _buildKpiCard(context, requestsAsync),
            const SizedBox(height: AppSpacing.xl),
            
            // Requests List/Table
            requestsAsync.when(
              data: (requests) {
                if (requests.isEmpty) {
                  return _buildEmptyState(context);
                }
                return LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 900) {
                      return _buildCardList(context, ref, requests);
                    }
                    return _buildDataTable(context, ref, requests);
                  },
                );
              },
              loading: () => const Center(child: FlickrLoader()),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Text('Error loading requests: $err', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard(BuildContext context, AsyncValue<List<AccountDeletionRequest>> requestsAsync) {
    final theme = Theme.of(context);
    final count = requestsAsync.value?.length ?? 0;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(LucideIcons.userX, color: AppColors.error, size: 28),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Pending Deletion Requests',
                    style: AppTextStyles.bodyMedium.copyWith(color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    requestsAsync.isLoading ? '...' : '$count Requests',
                    style: AppTextStyles.headlineMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Awaiting clearance check and administrator review before final purge.',
                    style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl * 2),
        child: Column(
          children: [
            Icon(LucideIcons.shieldCheck, size: 64, color: AppColors.success.withOpacity(0.8)),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No Deletion Requests',
              style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'All student accounts are active, and no deletion requests are currently pending review.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTable(BuildContext context, WidgetRef ref, List<AccountDeletionRequest> requests) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(theme.colorScheme.surfaceVariant.withOpacity(0.3)),
          columns: const [
            DataColumn(label: Text('Student Info')),
            DataColumn(label: Text('Student ID')),
            DataColumn(label: Text('Clearance Ack')),
            DataColumn(label: Text('Data Loss Ack')),
            DataColumn(label: Text('Submitted At')),
            DataColumn(label: Text('Actions')),
          ],
          rows: requests.map((request) {
            return DataRow(
              cells: [
                DataCell(
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(request.fullName, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                        Text(request.email, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey)),
                      ],
                    ),
                  ),
                ),
                DataCell(Text(request.studentIdNumber, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold))),
                DataCell(_buildAckBadge(request.acknowledgedClearance)),
                DataCell(_buildAckBadge(request.acknowledgedDataLoss)),
                DataCell(
                  Text(
                    request.createdAt != null
                        ? DateFormat('yyyy-MM-dd HH:mm').format(request.createdAt!.toLocal())
                        : 'N/A',
                    style: AppTextStyles.bodySmall,
                  ),
                ),
                DataCell(
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded, size: 20),
                    onSelected: (value) {
                      if (value == 'delete') {
                        _showDeleteConfirmDialog(context, ref, request);
                      } else if (value == 'reject') {
                        _showRejectConfirmDialog(context, ref, request);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(LucideIcons.userX, color: AppColors.error, size: 16),
                            const SizedBox(width: 8),
                            Text('Approve & Delete Account', style: TextStyle(color: AppColors.error)),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'reject',
                        child: Row(
                          children: [
                            const Icon(LucideIcons.xCircle, color: AppColors.textGrey, size: 16),
                            const SizedBox(width: 8),
                            const Text('Reject/Dismiss Request'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCardList(BuildContext context, WidgetRef ref, List<AccountDeletionRequest> requests) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: requests.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final request = requests[index];
        final dateStr = request.createdAt != null
            ? DateFormat('yyyy-MM-dd HH:mm').format(request.createdAt!.toLocal())
            : 'N/A';

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(request.fullName, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert_rounded, size: 20),
                      onSelected: (value) {
                        if (value == 'delete') {
                          _showDeleteConfirmDialog(context, ref, request);
                        } else if (value == 'reject') {
                          _showRejectConfirmDialog(context, ref, request);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              const Icon(LucideIcons.userX, color: AppColors.error, size: 16),
                              const SizedBox(width: 8),
                              Text('Approve & Delete Account', style: TextStyle(color: AppColors.error)),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'reject',
                          child: Row(
                            children: [
                              const Icon(LucideIcons.xCircle, color: AppColors.textGrey, size: 16),
                              const SizedBox(width: 8),
                              const Text('Reject/Dismiss Request'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Text('Email: ${request.email}', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey)),
                Text('Student ID: ${request.studentIdNumber}', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey)),
                Text('Submitted At: $dateStr', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey)),
                const Divider(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Text('Clearance Ack: ', style: TextStyle(fontSize: 11, color: AppColors.textGrey)),
                          _buildAckBadge(request.acknowledgedClearance),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          const Text('Data Loss Ack: ', style: TextStyle(fontSize: 11, color: AppColors.textGrey)),
                          _buildAckBadge(request.acknowledgedDataLoss),
                        ],
                      ),
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

  Widget _buildAckBadge(bool acknowledged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (acknowledged ? AppColors.success : AppColors.error).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        acknowledged ? 'Yes' : 'No',
        style: AppTextStyles.labelSmall.copyWith(
          color: acknowledged ? AppColors.success : AppColors.error,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmDialog(BuildContext context, WidgetRef ref, AccountDeletionRequest request) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(LucideIcons.alertTriangle, color: AppColors.error),
            const SizedBox(width: AppSpacing.sm),
            const Text('Approve & Purge User'),
          ],
        ),
        content: Text(
          'Are you sure you want to permanently delete the account of ${request.fullName} (${request.studentIdNumber})? '
          'This action is irreversible and will delete all student records and data across all tables.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref
                  .read(accountDeletionControllerProvider.notifier)
                  .deleteRequestAndUser(userId: request.userId);

              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Account permanently deleted.'), backgroundColor: AppColors.success),
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to delete account.'), backgroundColor: AppColors.error),
                );
              }
            },
            child: const Text('Purge Account'),
          ),
        ],
      ),
    );
  }

  Future<void> _showRejectConfirmDialog(BuildContext context, WidgetRef ref, AccountDeletionRequest request) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Deletion Request'),
        content: Text(
          'Are you sure you want to reject the deletion request for ${request.fullName} (${request.studentIdNumber})? '
          'This will delete the request record, and the student\'s account will remain active.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref
                  .read(accountDeletionControllerProvider.notifier)
                  .rejectRequest(request.id);

              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Deletion request rejected.'), backgroundColor: AppColors.success),
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to reject request.'), backgroundColor: AppColors.error),
                );
              }
            },
            child: const Text('Reject Request'),
          ),
        ],
      ),
    );
  }
}
