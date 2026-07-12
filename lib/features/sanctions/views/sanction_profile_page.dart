import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../../../core/widgets/loaders/flickr_loader.dart';
import '../../../core/permissions/app_permissions.dart';
import '../../organizations/providers/workspace_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/sanction_provider.dart';

class SanctionProfilePage extends ConsumerStatefulWidget {
  final String studentId;
  final bool isPersonalView;
  const SanctionProfilePage({
    super.key,
    required this.studentId,
    this.isPersonalView = false,
  });

  @override
  ConsumerState<SanctionProfilePage> createState() => _SanctionProfilePageState();
}

class _SanctionProfilePageState extends ConsumerState<SanctionProfilePage> {
  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  String _formatTime(String? timeStr) {
    if (timeStr == null) return 'Missing';
    try {
      final date = DateTime.parse(timeStr);
      return DateFormat('hh:mm a').format(date.toLocal());
    } catch (_) {
      return timeStr;
    }
  }

  String _getYearDisplay(int? year) {
    if (year == null) return 'N/A';
    switch (year) {
      case 1:
        return '1st Year';
      case 2:
        return '2nd Year';
      case 3:
        return '3rd Year';
      case 4:
        return '4th Year';
      default:
        return '$year\'th Year';
    }
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
    Widget? suffix,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textGrey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        value,
                        style: AppTextStyles.headlineMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      if (suffix != null) ...[
                        const SizedBox(width: AppSpacing.sm),
                        suffix,
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileAsync = ref.watch(userProfileByIdProvider(widget.studentId));
    final attendanceAsync = ref.watch(studentSanctionsAttendanceProvider(widget.studentId));
    final recordAsync = ref.watch(studentSanctionRecordProvider(widget.studentId));
    final rulesAsync = ref.watch(sanctionRulesProvider);
    final currentUser = ref.watch(userProfileProvider).value;

    final activeRole = ref.watch(workspaceProvider).activeRole;
    final canManageSanctions = activeRole?.hasPermission(AppPermissions.receiveSanctionItems) ?? false;

    final attendanceEvents = attendanceAsync.value ?? [];
    final double totalSanctionScore = attendanceEvents.fold<double>(
      0.0,
      (sum, event) => sum + (event['sanction_score'] as num).toDouble(),
    );

    Widget? statusBadge;
    if (recordAsync.hasValue && rulesAsync.hasValue) {
      final sanction = recordAsync.value;
      final rules = rulesAsync.value ?? [];
      final isRulesNotSet = rules.isEmpty;

      final isComplied = sanction == null || sanction.status == 'Item Received' || totalSanctionScore == 0.0;
      final String statusLabel;
      final Color badgeColor;

      if (isRulesNotSet) {
        statusLabel = 'RULES NOT SET';
        badgeColor = AppColors.textGrey;
      } else {
        statusLabel = isComplied ? 'CLEARED' : 'PENDING';
        badgeColor = isComplied ? AppColors.success : AppColors.warning;
      }

      statusBadge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: badgeColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: badgeColor.withValues(alpha: 0.2)),
        ),
        child: Text(
          statusLabel,
          style: AppTextStyles.labelSmall.copyWith(
            color: badgeColor,
            fontWeight: FontWeight.bold,
            fontSize: 9,
            letterSpacing: 0.5,
          ),
        ),
      );
    }

    return DashboardLayout(
      title: widget.isPersonalView ? 'My Sanctions' : 'Student Sanction Profile',
      onBack: widget.isPersonalView ? null : () => context.pop(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: profileAsync.when(
          data: (profile) {
            if (profile == null) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.gavel_rounded, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: widget.isPersonalView ? null : () => context.pop(),
                        child: Text(
                          'Sanctions',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: widget.isPersonalView ? AppColors.primary : Colors.grey[600],
                            fontWeight: widget.isPersonalView ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                      ),
                      if (!widget.isPersonalView) ...[
                        const SizedBox(width: 8),
                        Icon(Icons.chevron_right_rounded, size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Student Sanction Profile',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Center(child: Text('Student profile not found.')),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.gavel_rounded, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: widget.isPersonalView ? null : () => context.pop(),
                      child: Text(
                        'Sanctions',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: widget.isPersonalView ? AppColors.primary : Colors.grey[600],
                          fontWeight: widget.isPersonalView ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ),
                    if (!widget.isPersonalView) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.chevron_right_rounded, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Student Sanction Profile',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                // 1. Student Information Card
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: theme.colorScheme.primaryContainer,
                          backgroundImage: profile.avatarUrl != null ? NetworkImage(profile.avatarUrl!) : null,
                          child: profile.avatarUrl == null
                              ? Text(
                                  profile.fullName.isNotEmpty ? profile.fullName[0].toUpperCase() : '?',
                                  style: TextStyle(color: theme.colorScheme.onPrimaryContainer, fontSize: 28, fontWeight: FontWeight.bold),
                                )
                              : null,
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(profile.fullName, style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text('Student ID: ${profile.schoolId}', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 2),
                              Text('${profile.programName ?? 'N/A'} — ${_getYearDisplay(profile.yearLevel)}', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey)),
                              const SizedBox(height: 2),
                              Text(profile.email, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Stats cards Row
                if (attendanceAsync.hasValue) ...[
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: 'Total Sanction Score',
                          value: totalSanctionScore % 1 == 0
                              ? totalSanctionScore.toInt().toString()
                              : totalSanctionScore.toStringAsFixed(1),
                          color: totalSanctionScore == 0.0 ? AppColors.success : AppColors.error,
                          icon: Icons.gavel_rounded,
                          suffix: statusBadge,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _buildStatCard(
                          title: 'Mandatory Events',
                          value: attendanceEvents.length.toString(),
                          color: AppColors.primary,
                          icon: Icons.event_note_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],

                // 2. Attendance & Event Contribution Section
                Text('Attendance History & Contributions', style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSpacing.md),
                attendanceAsync.when(
                  data: (events) {
                    if (events.isEmpty) {
                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: AppColors.border),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(AppSpacing.xl),
                          child: Center(
                            child: Text('No mandatory events recorded for this organization in this term.', style: TextStyle(color: AppColors.textGrey)),
                          ),
                        ),
                      );
                    }

                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(minWidth: constraints.maxWidth),
                              child: DataTable(
                                columnSpacing: AppSpacing.lg,
                                headingRowColor: WidgetStateProperty.all(theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)),
                                columns: const [
                                  DataColumn(label: Text('Date')),
                                  DataColumn(label: Text('Event Name')),
                                  DataColumn(label: Text('Time In')),
                                  DataColumn(label: Text('Time Out')),
                                  DataColumn(label: Text('Sanction Score')),
                                ],
                                rows: events.map((event) {
                                  final double eventScore = (event['sanction_score'] as num).toDouble();
                                  final isMissingIn = event['time_in'] == null;
                                  final isMissingOut = event['time_out'] == null;
                                  final isCompliant = eventScore == 0.0;
                                  final scoreColor = isCompliant ? AppColors.success : AppColors.error;

                                  return DataRow(
                                    cells: [
                                      DataCell(Text(_formatDate(event['date']), style: AppTextStyles.bodyMedium)),
                                      DataCell(Text(event['name'] ?? 'Unknown', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold))),
                                      DataCell(
                                        Text(
                                          _formatTime(event['time_in']),
                                          style: AppTextStyles.bodyMedium.copyWith(
                                            color: isMissingIn ? AppColors.error : AppColors.textDark,
                                            fontWeight: isMissingIn ? FontWeight.bold : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          _formatTime(event['time_out']),
                                          style: AppTextStyles.bodyMedium.copyWith(
                                            color: isMissingOut ? AppColors.error : AppColors.textDark,
                                            fontWeight: isMissingOut ? FontWeight.bold : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: scoreColor.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: scoreColor.withValues(alpha: 0.2)),
                                          ),
                                          child: Text(
                                            eventScore % 1 == 0 ? eventScore.toInt().toString() : eventScore.toStringAsFixed(1),
                                            style: TextStyle(
                                              color: scoreColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
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
                    );
                  },
                  loading: () => const Center(child: FlickrLoader()),
                  error: (err, _) => Center(child: Text('Error loading events: $err')),
                ),
                const SizedBox(height: AppSpacing.xl),

                // 3. Assigned Sanctions Section
                Text('Assigned Sanction Details', style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSpacing.md),
                recordAsync.when(
                  data: (sanction) {
                    return rulesAsync.when(
                      data: (rules) {
                        final isRulesNotSet = rules.isEmpty;
                        if (sanction == null) {
                          if (isRulesNotSet) {
                            return Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: const BorderSide(color: AppColors.border),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(AppSpacing.xl),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(AppSpacing.md),
                                      decoration: BoxDecoration(
                                        color: AppColors.textGrey.withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.rule_rounded, color: AppColors.textGrey, size: 32),
                                    ),
                                    const SizedBox(width: AppSpacing.lg),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Rules Not Set', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                          SizedBox(height: 4),
                                          Text(
                                            'Sanction rules have not been configured by the officers yet for this term.',
                                            style: TextStyle(color: AppColors.textGrey),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          return Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: const BorderSide(color: AppColors.border),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.xl),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(AppSpacing.md),
                                    decoration: BoxDecoration(
                                      color: AppColors.success.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 32),
                                  ),
                                  const SizedBox(width: AppSpacing.lg),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Fully Compliant', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        SizedBox(height: 4),
                                        Text(
                                          'This student has no outstanding sanctions in the current term.',
                                          style: TextStyle(color: AppColors.textGrey),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        final isReceived = sanction.status == 'Item Received';

                        return Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: isReceived ? AppColors.success.withValues(alpha: 0.2) : AppColors.border),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Requirement Details', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                                        Text(
                                          '${sanction.totalAbsences % 1 == 0 ? sanction.totalAbsences.toInt().toString() : sanction.totalAbsences.toStringAsFixed(1)} Sanction Score Triggered',
                                          style: AppTextStyles.labelSmall.copyWith(color: AppColors.textGrey),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: (isReceived ? AppColors.success : AppColors.warning).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: (isReceived ? AppColors.success : AppColors.warning).withValues(alpha: 0.2)),
                                      ),
                                      child: Text(
                                        isReceived ? 'CLEARED' : 'PENDING',
                                        style: TextStyle(
                                          color: isReceived ? AppColors.success : AppColors.warning,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: AppSpacing.xl),
                                Row(
                                  children: [
                                    const Icon(Icons.inventory_2_outlined, size: 20, color: AppColors.textGrey),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Text(
                                        'Item: ${sanction.requiredItem}',
                                        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, fontSize: 15),
                                      ),
                                    ),
                                  ],
                                ),
                                if (isReceived) ...[
                                  const SizedBox(height: AppSpacing.md),
                                  Container(
                                    padding: const EdgeInsets.all(AppSpacing.md),
                                    decoration: BoxDecoration(
                                      color: AppColors.success.withValues(alpha: 0.05),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: AppColors.success.withValues(alpha: 0.1)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.check_circle_outline_rounded, color: AppColors.success, size: 20),
                                        const SizedBox(width: AppSpacing.md),
                                        Expanded(
                                          child: Text(
                                            'Marked as received by ${sanction.receivedByName} on ${DateFormat('MMM dd, yyyy').format(sanction.receivedAt!)}',
                                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.success, fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ] else if (canManageSanctions) ...[
                                  const SizedBox(height: AppSpacing.xl),
                                  SizedBox(
                                    width: double.infinity,
                                    child: FilledButton.icon(
                                      onPressed: () {
                                        if (currentUser == null) return;
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                            title: Text(
                                              'Confirm Sanction Receipt',
                                              style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
                                            ),
                                            content: Text(
                                              'Are you sure you want to mark this sanction as received?\n\n'
                                              'Required Item:\n"${sanction.requiredItem}"\n\n'
                                              'This action will mark the student\'s sanction as settled.',
                                              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context),
                                                child: Text('Cancel', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)),
                                              ),
                                              FilledButton(
                                                style: FilledButton.styleFrom(
                                                  backgroundColor: AppColors.success,
                                                  foregroundColor: Colors.white,
                                                ),
                                                onPressed: () async {
                                                  Navigator.pop(context);
                                                  final messenger = ScaffoldMessenger.of(context);
                                                  try {
                                                    await ref.read(sanctionRepositoryProvider).receiveSanctionItem(sanction.id, currentUser.id!);
                                                    ref.invalidate(studentSanctionRecordProvider(widget.studentId));
                                                    ref.invalidate(workspaceSanctionsProvider);
                                                    ref.invalidate(workspaceComplianceProvider);
                                                    messenger.showSnackBar(const SnackBar(content: Text('Sanction marked as received.')));
                                                  } catch (e) {
                                                    messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
                                                  }
                                                },
                                                child: const Text('Confirm', style: TextStyle(fontWeight: FontWeight.bold)),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.how_to_reg_rounded),
                                      label: const Text('Mark as Received'),
                                      style: FilledButton.styleFrom(
                                        backgroundColor: AppColors.success,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                      loading: () => const Center(child: FlickrLoader()),
                      error: (err, _) => Center(child: Text('Error loading rules: $err')),
                    );
                  },
                  loading: () => const Center(child: FlickrLoader()),
                  error: (err, _) => Center(child: Text('Error loading sanction details: $err')),
                ),
              ],
            );
          },
          loading: () => const Center(child: FlickrLoader()),
          error: (err, _) => Center(child: Text('Error loading profile: $err')),
        ),
      ),
    );
  }
}
