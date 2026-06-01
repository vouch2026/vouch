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

class ActivityCardDetailsPage extends ConsumerWidget {
  final String id;

  const ActivityCardDetailsPage({
    super.key,
    required this.id,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityCardAsync = ref.watch(activityCardDetailsProvider(id));

    return DashboardLayout(
      title: 'Activity Card Details',
      child: activityCardAsync.when(
        data: (activityCard) {
          if (activityCard == null) {
            return const Center(child: Text('Activity Card not found'));
          }

          final studentProfileAsync = ref.watch(userProfileByIdProvider(activityCard.studentId));

          return studentProfileAsync.when(
            data: (studentProfile) {
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1400),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStudentInfo(context, studentProfile, activityCard),
                        const SizedBox(height: AppSpacing.xl),
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
                        const SizedBox(height: AppSpacing.xxl),
                        Center(
                          child: SignatureWorkflowTimeline(signatures: activityCard.signatures),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        _buildOrganizationInfo(activityCard),
                        const SizedBox(height: AppSpacing.xxl),
                      ],
                    ),
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error loading student info: $err')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
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
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Flex(
        direction: isCompact ? Axis.vertical : Axis.horizontal,
        crossAxisAlignment: isCompact ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            backgroundImage: user?.avatarUrl != null ? NetworkImage(user!.avatarUrl!) : null,
            child: user?.avatarUrl == null 
              ? Text(name[0], style: AppTextStyles.displaySmall.copyWith(color: AppColors.primary))
              : null,
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
                  info,
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
      ],
    );
  }

  Widget _buildOrganizationInfo(ActivityCard card) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ORGANIZATION DETAILS',
            style: AppTextStyles.labelSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                if (card.organizationLogo != null)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.md),
                    child: Image.network(card.organizationLogo!, width: 40, height: 40),
                  ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(card.organizationName, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                    Text('${card.academicYear} • ${card.semester}', style: AppTextStyles.labelSmall.copyWith(color: Colors.grey[600])),
                  ],
                ),
              ],
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
