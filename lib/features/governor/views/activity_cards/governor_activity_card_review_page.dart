import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/layouts/dashboard_layout.dart';
import '../../../activity_cards/models/activity_card_models.dart';
import '../../../activity_cards/providers/activity_card_provider.dart';
import '../../../activity_cards/providers/clearance_provider.dart';
import '../../../activity_cards/widgets/signature_workflow_timeline.dart';
import '../../../activity_cards/widgets/activity_card_events_table.dart';
import '../../../activity_cards/widgets/activity_card_fees_table.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../../../organizations/providers/workspace_provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../academic_structure/providers/term_provider.dart';

class GovernorActivityCardReviewPage extends ConsumerStatefulWidget {
  final String id; // This is the studentId passed from the list

  const GovernorActivityCardReviewPage({
    super.key,
    required this.id,
  });

  @override
  ConsumerState<GovernorActivityCardReviewPage> createState() => _GovernorActivityCardReviewPageState();
}

class _GovernorActivityCardReviewPageState extends ConsumerState<GovernorActivityCardReviewPage> {
  final TextEditingController _notesController = TextEditingController();
  bool _isActionLoading = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSignature(ActivityCard card, String signatureId, bool isReject) async {
    final currentUser = ref.read(userProfileProvider).value;
    final term = ref.read(activeTermProvider).value;
    if (currentUser == null || term == null) return;

    setState(() => _isActionLoading = true);
    try {
      final repo = ref.read(clearanceRepositoryProvider);
      if (isReject) {
        if (_notesController.text.isEmpty) {
          throw Exception('Please provide a reason for rejection in the notes field.');
        }
        await repo.rejectClearance(
          signatureId: signatureId,
          userId: currentUser.id!,
          remarks: _notesController.text,
        );
      } else {
        await repo.signClearance(
          signatureId: signatureId,
          userId: currentUser.id!,
          studentId: card.studentId,
          termId: term.id,
          remarks: _notesController.text,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isReject ? 'Card rejected successfully' : 'Signature applied successfully')),
        );
        ref.invalidate(reviewActivityCardProvider(widget.id));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final activityCardAsync = ref.watch(reviewActivityCardProvider(widget.id));
    final activeRole = ref.watch(workspaceProvider).activeRole;

    return LoadingOverlay(
      isLoading: _isActionLoading,
      child: DashboardLayout(
        title: 'Review Activity Card',
        child: activityCardAsync.when(
          data: (activityCard) {
            if (activityCard == null) {
              return const Center(child: Text('Activity Card not found for this student in your organization.'));
            }

            // Robust signature slot detection based on current viewer's role
            final mySignatureSlot = activityCard.signatures.where((s) {
              final requiredRoleName = s.roleName.toLowerCase().trim();
              final currentViewerRoleName = activeRole?.roleName.toLowerCase().trim();
              
              if (currentViewerRoleName == null) return false;

              // Direct match (e.g. Secretary matches Secretary slot)
              if (requiredRoleName == currentViewerRoleName) return true;
              
              // Governor/President overlap
              if ((currentViewerRoleName == 'governor' || currentViewerRoleName == 'president') && 
                  (requiredRoleName == 'governor' || requiredRoleName == 'president')) {
                return true;
              }

              // Super Admin can sign anything
              if (currentViewerRoleName == 'super admin') return true;

              return false;
            }).firstOrNull;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1400),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStudentInfo(context, activityCard),
                      const SizedBox(height: AppSpacing.xl),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth > 1100;
                          if (isWide) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: ActivityCardEventsTable(events: activityCard.events)),
                                const SizedBox(width: AppSpacing.xl),
                                Expanded(child: ActivityCardFeesTable(fees: activityCard.fees)),
                              ],
                            );
                          } else {
                            return Column(
                              children: [
                                ActivityCardEventsTable(events: activityCard.events),
                                const SizedBox(height: AppSpacing.xxl),
                                ActivityCardFeesTable(fees: activityCard.fees),
                              ],
                            );
                          }
                        },
                      ),
                      if (activityCard.sanctions.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xxl),
                        _buildSanctionsTable(activityCard.sanctions),
                      ],
                      const SizedBox(height: AppSpacing.xxl),
                      Center(
                        child: SignatureWorkflowTimeline(signatures: activityCard.signatures),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      if (mySignatureSlot != null && mySignatureSlot.status == SignatureStatus.pending) ...[
                        _buildOfficerActions(context),
                        const SizedBox(height: AppSpacing.xxl),
                        _buildReviewActions(context, activityCard, mySignatureSlot.id),
                      ] else if (mySignatureSlot != null)
                        Center(
                          child: Text(
                            'You have already ${mySignatureSlot.status == SignatureStatus.signed ? 'signed' : 'rejected'} this card.',
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey, fontStyle: FontStyle.italic),
                          ),
                        ),
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }

  Widget _buildReviewActions(BuildContext context, ActivityCard card, String signatureId) {
    return Center(
      child: Wrap(
        spacing: AppSpacing.md,
        runSpacing: AppSpacing.md,
        alignment: WrapAlignment.center,
        children: [
          SizedBox(
            width: 200,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.close_rounded),
              label: const Text('Reject Card'),
              onPressed: () => _handleSignature(card, signatureId, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
          SizedBox(
            width: 200,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.draw_rounded),
              label: const Text('Apply Signature'),
              onPressed: () => _handleSignature(card, signatureId, false),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentInfo(BuildContext context, ActivityCard card) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 700;
    final name = card.studentName ?? 'Unknown Student';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Flex(
        direction: isCompact ? Axis.vertical : Axis.horizontal,
        crossAxisAlignment: isCompact ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(name[0], style: AppTextStyles.displaySmall.copyWith(color: AppColors.primary)),
          ),
          SizedBox(width: isCompact ? 0 : AppSpacing.lg, height: isCompact ? AppSpacing.md : 0),
          Expanded(
            flex: isCompact ? 0 : 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.headlineLarge.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  '${card.studentProgram ?? 'N/A'} • Student ID: ${widget.id}',
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          SizedBox(height: isCompact ? AppSpacing.lg : 0),
          _buildQuickCompliance(card),
        ],
      ),
    );
  }

  Widget _buildQuickCompliance(ActivityCard card) {
    final completedEvents = card.events.where((e) => e.attendanceStatus == AttendanceStatus.completed).length;
    final totalEvents = card.events.length;
    final isEventsMet = completedEvents == totalEvents && totalEvents > 0;

    final paidFees = card.fees.where((f) => f.isPaid).length;
    final totalFees = card.fees.length;
    final isFeesMet = paidFees == totalFees && totalFees > 0;

    final fulfilledSanctions = card.sanctions.where((s) => s.isFulfilled).length;
    final totalSanctions = card.sanctions.length;
    final isSanctionsMet = fulfilledSanctions == totalSanctions;

    return Row(
      children: [
        _ComplianceItem(
          label: 'Events',
          value: '$completedEvents/$totalEvents',
          isMet: isEventsMet,
        ),
        const SizedBox(width: AppSpacing.lg),
        _ComplianceItem(
          label: 'Fees',
          value: isFeesMet ? 'Paid' : '$paidFees/$totalFees',
          isMet: isFeesMet,
        ),
        if (totalSanctions > 0) ...[
          const SizedBox(width: AppSpacing.lg),
          _ComplianceItem(
            label: 'Sanctions',
            value: isSanctionsMet ? 'Fulfilled' : '$fulfilledSanctions/$totalSanctions',
            isMet: isSanctionsMet,
          ),
        ],
      ],
    );
  }

  Widget _buildSanctionsTable(List<ActivityCardSanction> sanctions) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ABSENCE SANCTIONS', style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold, color: Colors.grey[600], letterSpacing: 1.2)),
            const SizedBox(height: AppSpacing.lg),
            ...sanctions.map((s) => ListTile(
              leading: Icon(s.isFulfilled ? Icons.check_circle_rounded : Icons.pending_actions_rounded, 
                           color: s.isFulfilled ? AppColors.success : AppColors.warning),
              title: Text(s.description, style: const TextStyle(fontWeight: FontWeight.bold)),
              trailing: Text(s.isFulfilled ? 'Fulfilled' : 'Pending', 
                            style: TextStyle(color: s.isFulfilled ? AppColors.success : AppColors.warning, fontWeight: FontWeight.bold)),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildOfficerActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'OFFICER NOTES & REASONS',
            style: AppTextStyles.labelSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Add a note or reason for rejection...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              fillColor: Colors.grey.shade50,
              filled: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _ComplianceItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isMet;

  const _ComplianceItem({
    required this.label,
    required this.value,
    required this.isMet,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.labelSmall.copyWith(color: Colors.grey[600])),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isMet ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(isMet ? Icons.check_circle_rounded : Icons.error_rounded, 
                   size: 12, color: isMet ? Colors.green : Colors.red),
              const SizedBox(width: 4),
              Text(value, style: TextStyle(
                color: isMet ? Colors.green : Colors.red,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              )),
            ],
          ),
        ),
      ],
    );
  }
}
