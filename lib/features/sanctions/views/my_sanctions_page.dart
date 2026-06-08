import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../providers/sanction_provider.dart';
import 'package:intl/intl.dart';

class MySanctionsPage extends ConsumerWidget {
  const MySanctionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sanctionsAsync = ref.watch(mySanctionsProvider);

    return DashboardLayout(
      title: 'My Sanctions',
      child: sanctionsAsync.when(
        data: (sanctions) {
          if (sanctions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.gavel_rounded, size: 64, color: AppColors.textGrey.withOpacity(0.2)),
                  const SizedBox(height: AppSpacing.md),
                  const Text('Great job! You have no sanctions.', style: TextStyle(color: AppColors.textGrey)),
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
              final isReceived = sanction.status == 'Item Received';

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
                              Text('${sanction.totalAbsences} Absences', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                              Text('Workspace: ${sanction.scopeType}', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textGrey)),
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
                              'Cleared by ${sanction.receivedByName} on ${DateFormat('MMM dd, yyyy').format(sanction.receivedAt!)}',
                              style: AppTextStyles.labelSmall.copyWith(color: AppColors.success),
                            ),
                          ],
                        ),
                      ] else ...[
                        const SizedBox(height: AppSpacing.md),
                        const Text(
                          'Please donate the required item to an officer to clear this sanction.',
                          style: TextStyle(color: AppColors.warning, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
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
