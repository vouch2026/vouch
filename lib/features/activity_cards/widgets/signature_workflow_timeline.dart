import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/activity_card_models.dart';
import '../../organizations/providers/organization_provider.dart';
import '../../organizations/models/organization_membership_model.dart';
import '../../academic_structure/providers/term_provider.dart';
import 'package:intl/intl.dart';

class SignatureWorkflowTimeline extends ConsumerWidget {
  final List<ActivityCardSignature> signatures;
  final String? organizationId;
  final bool useHorizontalPadding;

  const SignatureWorkflowTimeline({
    super.key,
    required this.signatures,
    this.organizationId,
    this.useHorizontalPadding = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (signatures.isEmpty) {
      return const SizedBox.shrink();
    }
    // Sort signatures by order
    final sortedSignatures = [...signatures]..sort((a, b) => a.order.compareTo(b.order));

    final activeTerm = ref.watch(activeTermProvider).valueOrNull;
    final officers = organizationId != null 
        ? (ref.watch(organizationOfficersProvider(organizationId!)).valueOrNull ?? [])
        : const <OrganizationMembershipModel>[];
    final currentTermOfficers = officers.where((o) => 
      o.status == 'active' && 
      (activeTerm == null || o.academicTermId == activeTerm.id)
    ).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: useHorizontalPadding ? AppSpacing.lg : 0),
          child: const Padding(
            padding: EdgeInsets.only(left: 6.0),
            child: Text(
              'CLEARANCE WORKFLOW',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.textGrey,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Center(
          child: SizedBox(
            height: 180,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: useHorizontalPadding ? AppSpacing.lg : 0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(sortedSignatures.length * 2 - 1, (index) {
                  if (index.isEven) {
                    final sig = sortedSignatures[index ~/ 2];
                    String? resolvedOfficerName;
                    
                    if (sig.signedByUserName == null || sig.signedByUserName!.trim().isEmpty) {
                      final role = sig.roleName.toLowerCase().trim();
                      if (role == 'treasurer' || role == 'secretary' || role == 'president' || role == 'governor') {
                        final matchingOfficer = currentTermOfficers.where((o) {
                          final oRole = (o.roleName ?? '').toLowerCase().trim();
                          if (oRole == role) return true;
                          if ((role == 'governor' || role == 'president') && 
                              (oRole == 'governor' || oRole == 'president')) {
                            return true;
                          }
                          return false;
                        }).firstOrNull;
                        resolvedOfficerName = matchingOfficer?.user?.fullName;
                      }
                    }

                    return _SignatureCard(
                      signature: sig,
                      resolvedOfficerName: resolvedOfficerName,
                    );
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
  final String? resolvedOfficerName;

  const _SignatureCard({
    required this.signature,
    this.resolvedOfficerName,
  });

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
      statusColor = AppColors.success;
      statusIcon = Icons.check_circle_rounded;
      statusLabel = 'Signed';
    } else if (isLocked) {
      statusColor = AppColors.textGrey;
      statusIcon = Icons.lock_outline_rounded;
      statusLabel = 'Locked';
    } else if (isRejected) {
      statusColor = AppColors.error;
      statusIcon = Icons.cancel_rounded;
      statusLabel = 'Rejected';
    } else {
      statusColor = AppColors.warning;
      statusIcon = Icons.pending_rounded;
      statusLabel = 'Pending';
    }

    final hasRejectionReason = isRejected && signature.rejectionReason != null && signature.rejectionReason!.trim().isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: hasRejectionReason
            ? () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded, color: AppColors.error),
                        const SizedBox(width: 8),
                        Text('Rejection Reason - ${signature.roleName}'),
                      ],
                    ),
                    content: Text(signature.rejectionReason!),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              }
            : null,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 180,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isPending 
                  ? AppColors.accent.withValues(alpha: 0.8) 
                  : (isSigned ? AppColors.success.withValues(alpha: 0.4) : AppColors.border),
              width: isSigned || isPending ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isPending 
                    ? AppColors.accent.withValues(alpha: 0.12)
                    : Colors.black.withValues(alpha: 0.04),
                blurRadius: isPending ? 12 : 8,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                signature.roleName.toUpperCase(),
                style: AppTextStyles.labelSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isLocked ? AppColors.textGrey : AppColors.primary,
                  fontSize: 9,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                signature.signedByUserName ?? resolvedOfficerName ?? 'Not yet signed',
                style: AppTextStyles.titleSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isLocked ? AppColors.textGrey : AppColors.textDark,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              if (hasRejectionReason) ...[
                Text(
                  'Reason: ${signature.rejectionReason}',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.error,
                    fontSize: 9,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
              ],
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withValues(alpha: 0.15), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 12, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      statusLabel,
                      style: AppTextStyles.labelSmall.copyWith(
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
                  style: AppTextStyles.labelSmall.copyWith(fontSize: 9, color: AppColors.textGrey),
                ),
              ],
            ],
          ),
        ),
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
        height: 3,
        decoration: BoxDecoration(
          color: isCompleted ? AppColors.success : AppColors.border,
          borderRadius: BorderRadius.circular(1.5),
        ),
      ),
    );
  }
}
