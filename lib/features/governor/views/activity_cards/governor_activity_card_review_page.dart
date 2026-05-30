import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/layouts/dashboard_layout.dart';
import '../../../activity_cards/models/activity_card_models.dart';
import '../../../activity_cards/models/activity_card_mock_data.dart';
import '../../../activity_cards/widgets/signature_workflow_timeline.dart';
import '../../../activity_cards/widgets/activity_card_events_table.dart';
import '../../../activity_cards/widgets/activity_card_fees_table.dart';

class GovernorActivityCardReviewPage extends StatelessWidget {
  final String id;

  const GovernorActivityCardReviewPage({
    super.key,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    // For mock, we'll use the same student activity card
    final activityCard = ActivityCardMockData.studentActivityCards.firstWhere(
      (c) => c.id == id,
      orElse: () => ActivityCardMockData.studentActivityCards[0],
    );
    final studentName = 'Juan Dela Cruz';

    return DashboardLayout(
      title: 'Review Activity Card',
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStudentInfo(context, studentName, activityCard),
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
                _buildReviewActions(context),
                const SizedBox(height: AppSpacing.xxl),
                _buildOfficerActions(context),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReviewActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Center(
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
                onPressed: () {},
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
                onPressed: () {},
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
      ),
    );
  }

  Widget _buildStudentInfo(BuildContext context, String name, ActivityCard card) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 700;

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
                  'BSIT • 4th Year • Student ID: 2022-0001',
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
    final paidFees = card.fees.where((f) => f.isPaid).length;
    final totalFees = card.fees.length;
    final isFeesMet = paidFees == totalFees && totalFees > 0;

    return Row(
      children: [
        _ComplianceItem(
          label: 'Events',
          value: '${card.events.where((e) => e.attendanceStatus == AttendanceStatus.completed).length}/${card.events.length}',
          isMet: card.events.every((e) => e.attendanceStatus == AttendanceStatus.completed),
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

class HeaderActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;

  const HeaderActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? AppColors.primary : Colors.white,
        foregroundColor: isPrimary ? Colors.white : AppColors.primary,
        side: isPrimary ? null : const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
    );
  }
}
