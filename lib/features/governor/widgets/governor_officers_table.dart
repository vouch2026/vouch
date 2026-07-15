import 'dart:async';
import 'package:vouch_v2/core/widgets/loaders/flickr_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../organizations/providers/workspace_provider.dart';
import '../../organizations/providers/organization_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/models/user_model.dart';

class GovernorOfficersTable extends ConsumerWidget {
  const GovernorOfficersTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final workspace = ref.watch(workspaceProvider);
    final selectedOrg = workspace.selectedOrganization;
    final activeRoleName = workspace.activeRole?.roleName.toLowerCase() ?? '';
    final userProfile = ref.watch(userProfileProvider).value;
    final isSuperAdmin = userProfile?.role == 'super_admin';
    final canManageMembers = isSuperAdmin || 
                            activeRoleName.contains('governor') || 
                            activeRoleName.contains('president') ||
                            activeRoleName.contains('vice governor') ||
                            activeRoleName.contains('vice president');

    if (selectedOrg == null) {
      return const Center(child: Text('Please select an organization.'));
    }

    final membersAsync = ref.watch(organizationMembersProvider(selectedOrg.id));

    return membersAsync.when(
      data: (members) {
        final officers = members.where((m) {
          final role = m.role.toLowerCase();
          return role != 'member' && role != 'student';
        }).toList();

        if (officers.isEmpty) {
          return _buildEmptyState(theme);
        }

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: constraints.maxWidth),
                      child: DataTable(
                        columnSpacing: AppSpacing.lg,
                        headingRowColor: WidgetStateProperty.all(theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)),
                        columns: [
                          const DataColumn(label: Text('Officer')),
                          const DataColumn(label: Text('Student ID')),
                          const DataColumn(label: Text('Program & Year')),
                          const DataColumn(label: Text('Joined Date')),
                          const DataColumn(label: Text('Role')),
                          const DataColumn(label: Text('Duration')),
                          if (canManageMembers) const DataColumn(label: Text('Actions')),
                        ],
                        rows: officers.map((officer) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: theme.colorScheme.primaryContainer,
                                      backgroundImage: officer.avatarUrl != null ? NetworkImage(officer.avatarUrl!) : null,
                                      child: officer.avatarUrl == null
                                          ? Text(
                                              officer.fullName[0].toUpperCase(),
                                              style: TextStyle(color: theme.colorScheme.onPrimaryContainer, fontSize: 12),
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(officer.fullName, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                                        Text(officer.email, style: AppTextStyles.labelSmall.copyWith(color: Colors.grey[600])),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              DataCell(Text(officer.schoolId, style: AppTextStyles.bodySmall)),
                              DataCell(Text(
                                '${officer.programName ?? 'N/A'} - ${officer.yearLevel ?? ''}${officer.yearLevel != null ? " Year" : ""}',
                                style: AppTextStyles.bodySmall,
                              )),
                              DataCell(Text(
                                officer.joinedAt != null ? DateFormat.yMMMd().format(officer.joinedAt!) : 'N/A',
                                style: AppTextStyles.bodySmall,
                              )),
                              DataCell(_RoleBadge(role: officer.role)),
                              DataCell(
                                officer.expiredAt != null
                                    ? _CountdownTimerText(expiredAt: officer.expiredAt!)
                                    : Text('Academic Year', style: AppTextStyles.bodySmall),
                              ),
                              if (canManageMembers)
                                DataCell(
                                  _buildOfficerActions(context, ref, officer, selectedOrg),
                                ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Showing ${officers.length} officers',
                      style: AppTextStyles.labelSmall.copyWith(color: Colors.grey[600]),
                    ),
                    Row(
                      children: [
                        TextButton(onPressed: () {}, child: const Text('Previous')),
                        const SizedBox(width: AppSpacing.sm),
                        TextButton(onPressed: () {}, child: const Text('Next')),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: FlickrLoader(),
        ),
      ),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: AppSpacing.md),
              Text('Error loading officers: $error'),
              TextButton(
                onPressed: () => ref.refresh(organizationMembersProvider(selectedOrg.id)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          children: [
            Icon(Icons.badge_outlined, size: 64, color: theme.colorScheme.primary.withValues(alpha: 0.2)),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No officers found',
              style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'This organization doesn\'t have any officers assigned yet.',
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfficerActions(BuildContext context, WidgetRef ref, UserModel officer, dynamic selectedOrg) {
    final role = officer.role.toLowerCase();
    
    // Only representatives can be actioned (demoted)
    if (role != 'representative') {
      return const SizedBox.shrink();
    }

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded, size: 20),
      offset: const Offset(0, 30),
      onSelected: (value) {
        if (value == 'demote_representative') {
          _showDemoteDialog(context, ref, officer, selectedOrg);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'demote_representative',
          child: Row(
            children: [
              Icon(Icons.trending_down_rounded, size: 18, color: AppColors.error),
              SizedBox(width: 8),
              Text('Demote to Member', style: TextStyle(color: AppColors.error)),
            ],
          ),
        ),
      ],
    );
  }

  void _showDemoteDialog(BuildContext context, WidgetRef ref, UserModel officer, dynamic selectedOrg) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Demote Representative'),
        content: Text(
          'Are you sure you want to demote ${officer.fullName} back to a standard Member? This action takes effect immediately.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await ref.read(organizationRepositoryProvider).demoteOfficer(
                  userId: officer.id!,
                  orgId: selectedOrg.id,
                  roleName: 'Representative',
                  workspaceType: selectedOrg.type,
                );
                
                ref.invalidate(organizationMembersProvider(selectedOrg.id));
                ref.invalidate(organizationOfficersProvider(selectedOrg.id));
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Successfully demoted ${officer.fullName} to Member.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error demoting user: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm Demotion'),
          ),
        ],
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String role;
  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    Color color;
    final lowerRole = role.toLowerCase();
    
    if (lowerRole.contains('governor')) {
      color = AppColors.primary;
    } else if (lowerRole.contains('treasurer')) {
      color = Colors.orange;
    } else if (lowerRole.contains('officer') || lowerRole.contains('dean') || lowerRole.contains('head') || lowerRole.contains('representative')) {
      color = Colors.blue;
    } else if (lowerRole.contains('staff')) {
      color = Colors.purple;
    } else if (lowerRole.contains('student') || lowerRole.contains('member')) {
      color = Colors.green;
    } else {
      color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        role,
        style: AppTextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _CountdownTimerText extends StatefulWidget {
  final DateTime expiredAt;
  const _CountdownTimerText({required this.expiredAt});

  @override
  State<_CountdownTimerText> createState() => _CountdownTimerTextState();
}

class _CountdownTimerTextState extends State<_CountdownTimerText> {
  Timer? _timer;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _calculateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _calculateRemaining();
        });
      }
    });
  }

  void _calculateRemaining() {
    final now = DateTime.now();
    _remaining = widget.expiredAt.difference(now);
    if (_remaining.isNegative) {
      _remaining = Duration.zero;
      _timer?.cancel();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_remaining == Duration.zero) {
      return Text(
        'Expired',
        style: TextStyle(
          color: Colors.red[600],
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      );
    }

    final hours = _remaining.inHours.toString().padLeft(2, '0');
    final minutes = (_remaining.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (_remaining.inSeconds % 60).toString().padLeft(2, '0');

    return Text(
      '$hours:$minutes:$seconds remaining',
      style: TextStyle(
        color: Colors.orange[800],
        fontWeight: FontWeight.bold,
        fontSize: 11,
      ),
    );
  }
}
