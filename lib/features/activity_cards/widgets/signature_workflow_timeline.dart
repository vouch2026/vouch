import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/activity_card_models.dart';
import 'package:intl/intl.dart';

class SignatureWorkflowTimeline extends StatelessWidget {
  final List<ActivityCardSignature> signatures;

  const SignatureWorkflowTimeline({
    super.key,
    required this.signatures,
  });

  @override
  Widget build(BuildContext context) {
    // Sort signatures by order
    final sortedSignatures = [...signatures]..sort((a, b) => a.order.compareTo(b.order));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(
            'CLEARANCE WORKFLOW',
            style: AppTextStyles.labelSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Center(
          child: SizedBox(
            height: 180,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(sortedSignatures.length * 2 - 1, (index) {
                  if (index.isEven) {
                    return _SignatureCard(signature: sortedSignatures[index ~/ 2]);
                  }
                  final signatureIndex = index ~/ 2;
                  return _WorkflowConnector(
                    isCompleted: sortedSignatures[signatureIndex].status == SignatureStatus.signed &&
                        (signatureIndex + 1 < sortedSignatures.length && 
                         (sortedSignatures[signatureIndex + 1].status == SignatureStatus.signed || 
                          sortedSignatures[signatureIndex + 1].status == SignatureStatus.pending)),
                  );
                }),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SignatureCard extends StatelessWidget {
  final ActivityCardSignature signature;

  const _SignatureCard({required this.signature});

  @override
  Widget build(BuildContext context) {
    final isSigned = signature.status == SignatureStatus.signed;
    final isLocked = signature.status == SignatureStatus.locked;
    final isPending = signature.status == SignatureStatus.pending;
    final isRejected = signature.status == SignatureStatus.rejected;

    Color statusColor;
    IconData statusIcon;
    String statusLabel;

    if (isSigned) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle_rounded;
      statusLabel = 'Signed';
    } else if (isLocked) {
      statusColor = Colors.grey;
      statusIcon = Icons.lock_outline_rounded;
      statusLabel = 'Locked';
    } else if (isRejected) {
      statusColor = Colors.red;
      statusIcon = Icons.cancel_rounded;
      statusLabel = 'Rejected';
    } else {
      statusColor = Colors.orange;
      statusIcon = Icons.pending_rounded;
      statusLabel = 'Pending Signature';
    }

    return Container(
      width: 180,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSigned ? Colors.green.withOpacity(0.3) : (isPending ? AppColors.primary.withOpacity(0.3) : Colors.grey.shade200),
          width: isSigned || isPending ? 1.5 : 1,
        ),
        boxShadow: isPending ? [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ] : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            signature.roleName.toUpperCase(),
            style: AppTextStyles.labelSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: isLocked ? Colors.grey : AppColors.primary,
              fontSize: 9,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            signature.signedByUserName ?? 'Not yet signed',
            style: AppTextStyles.titleSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: isLocked ? Colors.grey : AppColors.textDark,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, size: 12, color: statusColor),
                const SizedBox(width: 4),
                Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (isSigned && signature.signedAt != null) ...[
            const SizedBox(height: 4),
            Text(
              DateFormat('MMM d, yyyy').format(signature.signedAt!),
              style: AppTextStyles.labelSmall.copyWith(fontSize: 9, color: Colors.grey[500]),
            ),
          ],
        ],
      ),
    );
  }
}

class _WorkflowConnector extends StatelessWidget {
  final bool isCompleted;

  const _WorkflowConnector({required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      alignment: Alignment.center,
      child: Container(
        height: 2,
        color: isCompleted ? Colors.green : Colors.grey.shade200,
      ),
    );
  }
}
