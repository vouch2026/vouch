import 'package:vouch_v2/core/widgets/loaders/flickr_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/layouts/dashboard_layout.dart';
import '../../auth/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/activity_card_models.dart';
import '../providers/activity_card_provider.dart';
import '../widgets/signature_workflow_timeline.dart';
import '../widgets/activity_card_events_table.dart';
import '../widgets/activity_card_fees_table.dart';

import '../../academic_structure/providers/term_provider.dart';
import '../providers/clearance_provider.dart';

class ActivityCardDetailsPage extends ConsumerStatefulWidget {
  final String id;

  const ActivityCardDetailsPage({
    super.key,
    required this.id,
  });

  @override
  ConsumerState<ActivityCardDetailsPage> createState() => _ActivityCardDetailsPageState();
}

class _ActivityCardDetailsPageState extends ConsumerState<ActivityCardDetailsPage> {
  bool _isRequesting = false;

  Future<void> _handleRequestClearance(ActivityCard card) async {
    final term = ref.read(activeTermProvider).value;
    final currentUserProfile = ref.read(userProfileProvider).value;
    if (term == null || currentUserProfile == null) return;

    setState(() => _isRequesting = true);
    try {
      final repo = ref.read(clearanceRepositoryProvider);
      await repo.requestClearance(
        studentId: card.studentId,
        organizationId: card.organizationId,
        scopeId: card.organizationType == 'campus-based' ? currentUserProfile!.campusId! 
                : (card.organizationType == 'faculty-based' ? currentUserProfile!.facultyId! : currentUserProfile!.programId!),
        scopeType: card.organizationType == 'campus-based' ? 'Institutional' 
                  : (card.organizationType == 'faculty-based' ? 'Faculty' : 'Program'),
        termId: term.id,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Clearance request submitted successfully.')));
        ref.invalidate(activityCardDetailsProvider(widget.id));
        ref.invalidate(studentActivityCardsProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isRequesting = false);
    }
  }

  Widget _buildBackgroundDecorations() {
    return Stack(
      children: [
        Positioned(
          top: 60,
          right: -80,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(140),
            ),
          ),
        ),
        Positioned(
          bottom: 120,
          left: -60,
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(120),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final activityCardAsync = ref.watch(activityCardDetailsProvider(widget.id));
    final allCardsAsync = ref.watch(studentActivityCardsProvider);

    return DashboardLayout(
      title: 'Activity Card Details',
      child: activityCardAsync.when(
        data: (activityCard) {
          if (activityCard == null) {
            return const Center(child: Text('Activity Card not found'));
          }

          // Hierarchy Check
          bool isLocked = false;
          String lockReason = '';
          
          if (allCardsAsync.hasValue) {
            final allCards = allCardsAsync.value!;
            if (activityCard.organizationType == 'faculty-based') {
              final programCard = allCards.where((c) => c.organizationType == 'program-based').firstOrNull;
              // Officers are exempt from needing a clearance card for their own level
              if (programCard != null && programCard.status != ActivityCardStatus.cleared && !programCard.isOfficer) {
                isLocked = true;
                lockReason = 'You must clear your Program Activity Card (e.g. ${programCard.organizationName}) first.';
              }
            } else if (activityCard.organizationType == 'campus-based') {
              final facultyCard = allCards.where((c) => c.organizationType == 'faculty-based').firstOrNull;
              // Officers are exempt from needing a clearance card for their own level
              if (facultyCard != null && facultyCard.status != ActivityCardStatus.cleared && !facultyCard.isOfficer) {
                isLocked = true;
                lockReason = 'You must clear your Faculty Activity Card (e.g. ${facultyCard.organizationName}) first.';
              }
            }
          }

          final currentUserProfile = ref.watch(userProfileProvider).value;
          final isCurrentUser = currentUserProfile?.id == activityCard.studentId;
          final studentProfileAsync = isCurrentUser 
            ? AsyncValue.data(currentUserProfile)
            : ref.watch(userProfileByIdProvider(activityCard.studentId));

          final isNotStarted = activityCard.id.startsWith('temp-');
          final isRejected = activityCard.status == ActivityCardStatus.rejected;

          final adjustedSignatures = activityCard.signatures.map((sig) {
            if (isLocked && (sig.roleName.toLowerCase() == 'governor' || 
                             sig.roleName.toLowerCase() == 'president' || 
                             sig.roleName.toLowerCase() == 'adviser' || 
                             sig.roleName.toLowerCase() == 'instructor')) {
              return ActivityCardSignature(
                id: sig.id,
                roleName: sig.roleName,
                signedByUserId: sig.signedByUserId,
                signedByUserName: sig.signedByUserName,
                status: SignatureStatus.locked,
                signedAt: sig.signedAt,
                rejectionReason: sig.rejectionReason,
                order: sig.order,
              );
            }
            return sig;
          }).toList();

          return studentProfileAsync.when(
            data: (studentProfile) {
              return Stack(
                children: [
                  Positioned.fill(child: _buildBackgroundDecorations()),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1400),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isLocked) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                                child: Container(
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  decoration: BoxDecoration(
                                    color: AppColors.error.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.warning_amber_rounded, color: AppColors.error),
                                      const SizedBox(width: AppSpacing.sm),
                                      Expanded(
                                        child: Text(
                                          'Clearance Request Locked: $lockReason',
                                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                            _buildStudentInfo(context, studentProfile, activityCard),
                            const SizedBox(height: AppSpacing.xl),
                            if (isCurrentUser && (isNotStarted || isRejected)) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                                child: Center(
                                  child: SizedBox(
                                    width: 320,
                                    height: 52,
                                    child: ElevatedButton.icon(
                                      onPressed: (_isRequesting || isLocked) ? null : () => _handleRequestClearance(activityCard),
                                      icon: _isRequesting 
                                        ? const SizedBox(width: 18, height: 18, child: FlickrLoader())
                                        : const Icon(Icons.send_rounded),
                                      label: Text(
                                        _isRequesting ? 'Submitting...' : (isRejected ? 'Resubmit Clearance' : 'Request Clearance'),
                                        style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.accent,
                                        foregroundColor: AppColors.primary,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xl),
                            ],
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final isWide = constraints.maxWidth > 1100;
                                if (isWide) {
                                  return Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(child: ActivityCardEventsTable(events: activityCard.events)),
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
                              child: SignatureWorkflowTimeline(signatures: adjustedSignatures),
                            ),
                            const SizedBox(height: AppSpacing.xxl),
                            _buildOrganizationInfo(activityCard),
                            const SizedBox(height: AppSpacing.xxl),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: FlickrLoader()),
            error: (err, _) => Center(child: Text('Error loading student info: $err')),
          );
        },
        loading: () => const Center(child: FlickrLoader()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  String _getYearSuffix(int year) {
    if (year >= 11 && year <= 13) return 'th';
    switch (year % 10) {
      case 1: return 'st';
      case 2: return 'nd';
      case 3: return 'rd';
      default: return 'th';
    }
  }

  Widget _buildStudentInfo(BuildContext context, UserModel? user, ActivityCard card) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 700;
    final name = user?.fullName ?? 'Unknown Student';
    final info = '${user?.programName ?? 'Unknown Program'} • ${user?.yearLevel != null ? '${user!.yearLevel}${_getYearSuffix(user.yearLevel!)} Year' : 'Unknown Year'} • Student ID: ${user?.schoolId ?? 'N/A'}';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
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
                  backgroundImage: user?.avatarUrl != null ? NetworkImage(user!.avatarUrl!) : null,
                  child: user?.avatarUrl == null 
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
                      info,
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey, fontWeight: FontWeight.w500),
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

  Widget _buildOrganizationInfo(ActivityCard card) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 6.0),
            child: Text(
              'ORGANIZATION DETAILS',
              style: AppTextStyles.labelSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textGrey,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.xl),
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
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      width: 1,
                    ),
                  ),
                  child: card.organizationLogo != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            card.organizationLogo!, 
                            width: 44, 
                            height: 44,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.business_rounded, color: AppColors.primary, size: 28),
                          ),
                        )
                      : const Icon(Icons.business_rounded, color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card.organizationName, 
                        style: AppTextStyles.headlineSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.textGrey),
                          const SizedBox(width: 4),
                          Text(
                            '${card.academicYear} • ${card.semester}', 
                            style: AppTextStyles.labelMedium.copyWith(color: AppColors.textGrey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
