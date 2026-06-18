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
import '../models/sanction_model.dart';
import '../repositories/sanction_repository.dart';

class SanctionProfilePage extends ConsumerStatefulWidget {
  final String studentId;
  const SanctionProfilePage({super.key, required this.studentId});

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileAsync = ref.watch(userProfileByIdProvider(widget.studentId));
    final attendanceAsync = ref.watch(studentSanctionsAttendanceProvider(widget.studentId));
    final recordAsync = ref.watch(studentSanctionRecordProvider(widget.studentId));
    final currentUser = ref.watch(userProfileProvider).value;

    final activeRole = ref.watch(workspaceProvider).activeRole;
    final canManageSanctions = activeRole?.hasPermission(AppPermissions.receiveSanctionItems) ?? false;

    return DashboardLayout(
      title: 'Student Sanction Profile',
      onBack: () => context.pop(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: profileAsync.when(
          data: (profile) {
            if (profile == null) {
              return const Center(child: Text('Student profile not found.'));
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                const SizedBox(height: AppSpacing.xl),

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
                                headingRowColor: MaterialStateProperty.all(theme.colorScheme.surfaceVariant.withOpacity(0.3)),
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
                                            color: scoreColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: scoreColor.withOpacity(0.2)),
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
                    if (sanction == null) {
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
                                  color: AppColors.success.withOpacity(0.1),
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
                        side: BorderSide(color: isReceived ? AppColors.success.withOpacity(0.2) : AppColors.border),
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
                                    Text('${sanction.totalAbsences} Absences Triggered', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textGrey)),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: (isReceived ? AppColors.success : AppColors.warning).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: (isReceived ? AppColors.success : AppColors.warning).withOpacity(0.2)),
                                  ),
                                  child: Text(
                                    sanction.status.toUpperCase(),
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
                                  color: AppColors.success.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.success.withOpacity(0.1)),
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
                                  onPressed: () async {
                                    if (currentUser == null) return;
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
