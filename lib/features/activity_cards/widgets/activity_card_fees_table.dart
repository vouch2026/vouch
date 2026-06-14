import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/activity_card_models.dart';
import 'package:intl/intl.dart';

class ActivityCardFeesTable extends StatelessWidget {
  final List<ActivityCardFee> fees;

  const ActivityCardFeesTable({
    super.key,
    required this.fees,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Padding(
            padding: const EdgeInsets.only(left: 6.0),
            child: Text(
              'MANDATORY FEES COMPLIANCE',
              style: AppTextStyles.labelSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textGrey,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.grey.shade100),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: constraints.maxWidth,
                      ),
                      child: DataTable(
                        columnSpacing: AppSpacing.lg,
                        headingRowColor: WidgetStateProperty.all(AppColors.primary.withValues(alpha: 0.04)),
                        columns: [
                          DataColumn(
                            label: Text(
                              'FEE', 
                              style: AppTextStyles.labelSmall.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'AMOUNT', 
                              style: AppTextStyles.labelSmall.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'STATUS', 
                              style: AppTextStyles.labelSmall.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'PAID DATE / REF', 
                              style: AppTextStyles.labelSmall.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                        rows: fees.map((fee) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(fee.title, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.textDark)),
                                    Text(fee.category, style: AppTextStyles.labelSmall.copyWith(fontSize: 9, color: AppColors.textGrey)),
                                  ],
                                ),
                              ),
                              DataCell(Text('₱${fee.amount.toStringAsFixed(2)}', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.textDark))),
                              DataCell(_PaymentStatusBadge(isPaid: fee.isPaid)),
                              DataCell(
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      fee.paidAt != null ? DateFormat('MMM d, yyyy').format(fee.paidAt!) : '—',
                                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textDark),
                                    ),
                                    if (fee.referenceNumber != null)
                                      Text(fee.referenceNumber!, style: AppTextStyles.labelSmall.copyWith(fontSize: 9, color: AppColors.textGrey)),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PaymentStatusBadge extends StatelessWidget {
  final bool isPaid;

  const _PaymentStatusBadge({required this.isPaid});

  @override
  Widget build(BuildContext context) {
    final color = isPaid ? AppColors.success : AppColors.warning;
    final icon = isPaid ? Icons.check_circle_outline_rounded : Icons.access_time_rounded;
    final label = isPaid ? 'Paid' : 'Unpaid';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(color: color, fontWeight: FontWeight.bold, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
