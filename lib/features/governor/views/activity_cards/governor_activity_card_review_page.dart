import 'package:vouch_v2/core/widgets/loaders/flickr_loader.dart';
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
import '../../../auth/models/user_model.dart';
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
    final studentProfileAsync = ref.watch(userProfileByIdProvider(widget.id));
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

            return studentProfileAsync.when(
              data: (studentProfile) {
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1400),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStudentInfo(context, activityCard, studentProfile),
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
              loading: () => const Center(child: FlickrLoader()),
              error: (err, _) => Center(child: Text('Error loading student profile: $err')),
            );
          },
          loading: () => const Center(child: FlickrLoader()),
          error: (err, _) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }

  Widget _buildReviewActions(BuildContext context, ActivityCard card, String signatureId) {
    return Center(
      child: Wrap(
        spacing: AppSpacing.xl,
        runSpacing: AppSpacing.md,
        alignment: WrapAlignment.center,
        children: [
          SizedBox(
            width: 220,
            height: 52,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.close_rounded),
              label: Text(
                'Reject Card',
                style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.error),
              ),
              onPressed: () => _handleSignature(card, signatureId, true),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          SizedBox(
            width: 220,
            height: 52,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.draw_rounded),
              label: Text(
                'Apply Signature',
                style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              onPressed: () => _handleSignature(card, signatureId, false),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentInfo(BuildContext context, ActivityCard card, UserModel? studentProfile) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 700;
    final name = studentProfile?.fullName ?? card.studentName ?? 'Unknown Student';
    final programInfo = studentProfile?.programName ?? card.studentProgram ?? 'N/A';
    final yearDisplay = studentProfile?.yearLevel != null ? ' • ${studentProfile!.yearLevelDisplay} Year' : '';

    return Container(
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
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.white,
                AppColors.primary.withValues(alpha: 0.02),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Flex(
            direction: isCompact ? Axis.vertical : Axis.horizontal,
            crossAxisAlignment: isCompact ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.accent,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  backgroundImage: studentProfile?.avatarUrl != null ? NetworkImage(studentProfile!.avatarUrl!) : null,
                  child: studentProfile?.avatarUrl == null 
                    ? Text(name[0], style: AppTextStyles.displaySmall.copyWith(color: AppColors.primary))
                    : null,
                ),
              ),
              SizedBox(width: isCompact ? 0 : AppSpacing.xl, height: isCompact ? AppSpacing.md : 0),
              Expanded(
                flex: isCompact ? 0 : 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name, 
                      style: AppTextStyles.headlineLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$programInfo$yearDisplay',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: AppSpacing.md,
                      runSpacing: AppSpacing.xs,
                      children: [
                        Text(
                          'Student ID: ${studentProfile?.schoolId ?? 'N/A'}',
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'User ID (Sanctions Basis): ${studentProfile?.id ?? widget.id}',
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: isCompact ? AppSpacing.lg : 0),
              _buildQuickCompliance(card),
            ],
          ),
        ),
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

    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.sm,
      children: [
        _ComplianceItem(
          label: 'Events',
          value: '$completedEvents/$totalEvents',
          isMet: isEventsMet,
        ),
        _ComplianceItem(
          label: 'Fees',
          value: isFeesMet ? 'Paid' : '$paidFees/$totalFees',
          isMet: isFeesMet,
        ),
        if (totalSanctions > 0)
          _ComplianceItem(
            label: 'Sanctions',
            value: isSanctionsMet ? 'Fulfilled' : '$fulfilledSanctions/$totalSanctions',
            isMet: isSanctionsMet,
          ),
      ],
    );
  }

  Widget _buildSanctionsTable(List<ActivityCardSanction> sanctions) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 6.0),
            child: Text(
              'ABSENCE SANCTIONS', 
              style: AppTextStyles.labelSmall.copyWith(
                fontWeight: FontWeight.bold, 
                color: AppColors.textGrey, 
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
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
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: sanctions.map((s) {
                final statusColor = s.isFulfilled ? AppColors.success : AppColors.warning;
                return Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: statusColor.withValues(alpha: 0.1), width: 1),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
                    leading: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        s.isFulfilled ? Icons.check_circle_rounded : Icons.pending_actions_rounded, 
                        color: statusColor,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      s.description, 
                      style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.textDark),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        s.isFulfilled ? 'Fulfilled' : 'Pending', 
                        style: AppTextStyles.labelSmall.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfficerActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 6.0),
            child: Text(
              'OFFICER NOTES & REASONS',
              style: AppTextStyles.labelSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textGrey,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
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
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: TextField(
              controller: _notesController,
              maxLines: 3,
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Add a note or reason for rejection...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey.withValues(alpha: 0.6)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.15)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.15)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
                fillColor: AppColors.background,
                filled: true,
              ),
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
    final statusColor = isMet ? AppColors.success : AppColors.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textGrey,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isMet ? Icons.check_circle_rounded : Icons.warning_amber_rounded, 
                  size: 14, 
                  color: statusColor,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                value,
                style: AppTextStyles.titleSmall.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
