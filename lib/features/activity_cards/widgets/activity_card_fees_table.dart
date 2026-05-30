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
          child: Text(
            'MANDATORY FEES COMPLIANCE',
            style: AppTextStyles.labelSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
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
                      headingRowColor: MaterialStateProperty.all(Colors.grey.shade50),
                columns: const [
                  DataColumn(label: Text('FEE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('AMOUNT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('STATUS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('PAID DATE / REF', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                ],
                rows: fees.map((fee) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(fee.title, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)),
                            Text(fee.category, style: AppTextStyles.labelSmall.copyWith(fontSize: 9)),
                          ],
                        ),
                      ),
                      DataCell(Text('₱${fee.amount.toStringAsFixed(2)}', style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold))),
                      DataCell(_PaymentStatusBadge(isPaid: fee.isPaid)),
                      DataCell(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              fee.paidAt != null ? DateFormat('MMM d, yyyy').format(fee.paidAt!) : '—',
                              style: AppTextStyles.labelSmall,
                            ),
                            if (fee.referenceNumber != null)
                              Text(fee.referenceNumber!, style: AppTextStyles.labelSmall.copyWith(fontSize: 9, color: Colors.grey)),
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
      ],
    );
  }
}

class _PaymentStatusBadge extends StatelessWidget {
  final bool isPaid;

  const _PaymentStatusBadge({required this.isPaid});

  @override
  Widget build(BuildContext context) {
    final color = isPaid ? Colors.green : Colors.orange;
    final icon = isPaid ? Icons.check_circle_outline_rounded : Icons.access_time_rounded;
    final label = isPaid ? 'Paid' : 'Unpaid';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
