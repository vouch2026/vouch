import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/layouts/dashboard_layout.dart';
import '../models/activity_card_models.dart';
import '../models/activity_card_mock_data.dart';
import '../widgets/signature_workflow_timeline.dart';
import '../widgets/activity_card_events_table.dart';
import '../widgets/activity_card_fees_table.dart';

class ActivityCardDetailsPage extends StatelessWidget {
  final String id;

  const ActivityCardDetailsPage({
    super.key,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    final activityCard = ActivityCardMockData.studentActivityCards.firstWhere(
      (c) => c.id == id,
      orElse: () => ActivityCardMockData.studentActivityCards.first,
    );

    return DashboardLayout(
      title: '${activityCard.organizationName} Activity Card',
      actions: [
        IconButton(
          icon: const Icon(Icons.download_rounded),
          onPressed: () {},
          tooltip: 'Download PDF',
        ),
      ],
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, activityCard),
                const SizedBox(height: AppSpacing.xl),
                _buildProgressSection(context, activityCard),
                const SizedBox(height: AppSpacing.xxl),
                ActivityCardEventsTable(events: activityCard.events),
                const SizedBox(height: AppSpacing.xxl),
                ActivityCardFeesTable(fees: activityCard.fees),
                const SizedBox(height: AppSpacing.xxl),
                Center(
                  child: SignatureWorkflowTimeline(signatures: activityCard.signatures),
                ),
                const SizedBox(height: AppSpacing.xxl),
                _buildAuditLogsSection(),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ActivityCard card) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 600;

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
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                card.organizationName[0],
                style: AppTextStyles.displaySmall.copyWith(color: AppColors.primary),
              ),
            ),
          ),
          SizedBox(width: isCompact ? 0 : AppSpacing.lg, height: isCompact ? AppSpacing.md : 0),
          Expanded(
            flex: isCompact ? 0 : 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: AppSpacing.md,
                  children: [
                    Text(
                      card.organizationName,
                      style: AppTextStyles.headlineLarge.copyWith(fontWeight: FontWeight.bold),
                    ),
                    _StatusBadge(status: card.status),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${card.academicYear} • ${card.semester}',
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(BuildContext context, ActivityCard card) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 900;
          
          if (isCompact) {
            return Column(
              children: [
                _ProgressWidget(
                  label: 'Overall Completion',
                  value: '${(card.completionPercentage * 100).toInt()}%',
                  percentage: card.completionPercentage,
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppSpacing.lg),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: constraints.maxWidth < 600 ? 1 : 3,
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.md,
                  childAspectRatio: 3,
                  children: [
                    _StatWidget(
                      label: 'Mandatory Events',
                      value: '${card.events.where((e) => e.attendanceStatus == AttendanceStatus.completed).length}/${card.events.length}',
                      icon: Icons.event_available_rounded,
                    ),
                    _StatWidget(
                      label: 'Mandatory Fees',
                      value: '${card.fees.where((f) => f.isPaid).length}/${card.fees.length}',
                      icon: Icons.payments_rounded,
                    ),
                    _StatWidget(
                      label: 'Signatures',
                      value: '${card.signatures.where((s) => s.status == SignatureStatus.signed).length}/${card.signatures.length}',
                      icon: Icons.draw_rounded,
                    ),
                  ],
                ),
              ],
            );
          }

          return Row(
            children: [
              _ProgressWidget(
                label: 'Overall Completion',
                value: '${(card.completionPercentage * 100).toInt()}%',
                percentage: card.completionPercentage,
                color: AppColors.primary,
              ),
              const Spacer(),
              _StatWidget(
                label: 'Mandatory Events',
                value: '${card.events.where((e) => e.attendanceStatus == AttendanceStatus.completed).length}/${card.events.length}',
                icon: Icons.event_available_rounded,
              ),
              const SizedBox(width: AppSpacing.xl),
              _StatWidget(
                label: 'Mandatory Fees',
                value: '${card.fees.where((f) => f.isPaid).length}/${card.fees.length}',
                icon: Icons.payments_rounded,
              ),
              const SizedBox(width: AppSpacing.xl),
              _StatWidget(
                label: 'Signatures',
                value: '${card.signatures.where((s) => s.status == SignatureStatus.signed).length}/${card.signatures.length}',
                icon: Icons.draw_rounded,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAuditLogsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(
            'CLEARANCE AUDIT LOGS',
            style: AppTextStyles.labelSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              _AuditLogRow(
                action: 'Treasurer Signature Applied',
                user: 'Juan Dela Cruz',
                date: 'Nov 26, 2025 • 10:15 AM',
              ),
              const Divider(height: 24),
              _AuditLogRow(
                action: 'Secretary Signature Applied',
                user: 'Maria Santos',
                date: 'Nov 25, 2025 • 02:30 PM',
              ),
              const Divider(height: 24),
              _AuditLogRow(
                action: 'Attendance Verified: Community Outreach',
                user: 'Maria Santos',
                date: 'Nov 20, 2025 • 04:00 PM',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final ActivityCardStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case ActivityCardStatus.cleared:
        color = Colors.green;
        label = 'CLEARED';
        break;
      case ActivityCardStatus.partiallySigned:
        color = AppColors.primary;
        label = 'PARTIALLY SIGNED';
        break;
      case ActivityCardStatus.rejected:
        color = Colors.red;
        label = 'REJECTED';
        break;
      default:
        color = Colors.orange;
        label = 'PENDING';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _ProgressWidget extends StatelessWidget {
  final String label;
  final String value;
  final double percentage;
  final Color color;

  const _ProgressWidget({
    required this.label,
    required this.value,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 48,
          height: 48,
          child: CircularProgressIndicator(
            value: percentage,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            strokeWidth: 6,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold)),
            Text(label, style: AppTextStyles.labelSmall.copyWith(color: Colors.grey[600])),
          ],
        ),
      ],
    );
  }
}

class _StatWidget extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatWidget({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: Colors.grey[700]),
        ),
        const SizedBox(width: AppSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold)),
            Text(label, style: AppTextStyles.labelSmall.copyWith(color: Colors.grey[600])),
          ],
        ),
      ],
    );
  }
}

class _AuditLogRow extends StatelessWidget {
  final String action;
  final String user;
  final String date;

  const _AuditLogRow({
    required this.action,
    required this.user,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(action, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text('By $user • $date', style: AppTextStyles.labelSmall.copyWith(fontSize: 9, color: Colors.grey[500])),
            ],
          ),
        ),
      ],
    );
  }
}
