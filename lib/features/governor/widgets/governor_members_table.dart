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
import '../../auth/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../academic_structure/providers/term_provider.dart';

class GovernorMembersTable extends ConsumerWidget {
  const GovernorMembersTable({super.key});

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
        final filteredMembers = members.where((m) {
          final role = m.role.toLowerCase();
          return role == 'member' || role == 'student';
        }).toList();

        if (filteredMembers.isEmpty) {
          return _buildEmptyState(theme);
        }

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
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
                        headingRowColor: MaterialStateProperty.all(theme.colorScheme.surfaceVariant.withOpacity(0.3)),
                        columns: [
                          const DataColumn(label: Text('Member')),
                          const DataColumn(label: Text('Student ID')),
                          const DataColumn(label: Text('Program & Year')),
                          const DataColumn(label: Text('Joined Date')),
                          const DataColumn(label: Text('Role')),
                          if (canManageMembers) const DataColumn(label: Text('Actions')),
                        ],
                        rows: filteredMembers.map((member) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: theme.colorScheme.primaryContainer,
                                      backgroundImage: member.avatarUrl != null ? NetworkImage(member.avatarUrl!) : null,
                                      child: member.avatarUrl == null
                                          ? Text(
                                              member.fullName[0].toUpperCase(),
                                              style: TextStyle(color: theme.colorScheme.onPrimaryContainer, fontSize: 12),
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(member.fullName, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                                        Text(member.email, style: AppTextStyles.labelSmall.copyWith(color: Colors.grey[600])),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              DataCell(Text(member.schoolId, style: AppTextStyles.bodySmall)),
                              DataCell(Text(
                                '${member.programName ?? 'N/A'} - ${member.yearLevel ?? ''}${member.yearLevel != null ? " Year" : ""}',
                                style: AppTextStyles.bodySmall,
                              )),
                              DataCell(Text(
                                member.joinedAt != null ? DateFormat.yMMMd().format(member.joinedAt!) : 'N/A',
                                style: AppTextStyles.bodySmall,
                              )),
                              DataCell(_RoleBadge(role: member.role)),
                              if (canManageMembers)
                                DataCell(
                                  _buildMemberActions(context, member),
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
                      'Showing ${filteredMembers.length} members',
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
              Text('Error loading members: $error'),
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
        side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          children: [
            Icon(Icons.people_outline_rounded, size: 64, color: theme.colorScheme.primary.withOpacity(0.2)),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No members found',
              style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'This organization doesn\'t have any members yet.',
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberActions(BuildContext context, UserModel member) {
    final role = member.role.toLowerCase();
    final isEligible = role == 'member' || role == 'student' || role == 'staff';

    if (!isEligible) {
      return const SizedBox.shrink();
    }

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded, size: 20),
      onSelected: (value) {
        if (value == 'promote_representative') {
          _showRepresentativeDialog(context, member);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'promote_representative',
          child: Row(
            children: [
              Icon(Icons.trending_up_rounded, size: 18, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Promote to Representative'),
            ],
          ),
        ),
      ],
    );
  }

  void _showRepresentativeDialog(BuildContext context, UserModel member) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _PromoteRepresentativeDialog(member: member),
    );
  }
}

class _PromoteRepresentativeDialog extends ConsumerStatefulWidget {
  final UserModel member;
  const _PromoteRepresentativeDialog({required this.member});

  @override
  ConsumerState<_PromoteRepresentativeDialog> createState() => _PromoteRepresentativeDialogState();
}

class _PromoteRepresentativeDialogState extends ConsumerState<_PromoteRepresentativeDialog> {
  String _durationOption = '24h'; // '24h' or 'permanent'
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final workspace = ref.watch(workspaceProvider);
    final selectedOrg = workspace.selectedOrganization;

    return AlertDialog(
      title: Container(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            const Icon(Icons.trending_up_rounded, color: AppColors.primary),
            const SizedBox(width: AppSpacing.md),
            const Text('Promote to Representative'),
          ],
        ),
      ),
      content: SizedBox(
        width: 450,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to promote ${widget.member.fullName} to Representative?',
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'This will assign them the Representative role, allowing them to view events, scan attendance, and request clearance.',
                style: TextStyle(color: AppColors.textGrey, fontSize: 13),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Role Duration',
                style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.xs),
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: AppColors.border.withOpacity(0.5)),
                ),
                child: Column(
                  children: [
                    RadioListTile<String>(
                      title: const Text('Temporary (24 Hours)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      subtitle: const Text('Automatically demotes back to Member after 24 hours', style: TextStyle(fontSize: 12)),
                      value: '24h',
                      groupValue: _durationOption,
                      activeColor: AppColors.primary,
                      onChanged: _isSubmitting ? null : (val) => setState(() => _durationOption = val!),
                    ),
                    const Divider(height: 1),
                    RadioListTile<String>(
                      title: const Text('Permanent Duration', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      subtitle: const Text('Active for the duration of the Academic Term', style: TextStyle(fontSize: 12)),
                      value: 'permanent',
                      groupValue: _durationOption,
                      activeColor: AppColors.primary,
                      onChanged: _isSubmitting ? null : (val) => setState(() => _durationOption = val!),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSubmitting 
              ? null 
              : () => _handlePromotion(selectedOrg),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Confirm Promotion'),
        ),
      ],
    );
  }

  Future<void> _handlePromotion(dynamic selectedOrg) async {
    if (selectedOrg == null) {
      _showError('No organization selected.');
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isSubmitting = true);

    try {
      final activeTerm = await ref.read(activeTermProvider.future);
      if (activeTerm == null) {
        _showError('No active academic term found. Please contact the administrator.');
        return;
      }

      final roles = await ref.read(availableRolesProvider.future);
      final repRole = roles.firstWhere(
        (r) => r['name'].toString().toLowerCase() == 'representative',
        orElse: () => {},
      );
      if (repRole.isEmpty) {
        _showError('Representative role not found in database.');
        return;
      }

      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null) {
        _showError('Authentication error. Please log in again.');
        return;
      }

      final expiredAt = _durationOption == '24h'
          ? DateTime.now().add(const Duration(hours: 24))
          : null;

      await ref.read(organizationRepositoryProvider).assignOfficer(
        userId: widget.member.id!,
        orgId: selectedOrg.id,
        roleId: repRole['id'],
        termId: activeTerm.id,
        assignedBy: currentUser.id,
        workspaceType: selectedOrg.type,
        expiredAt: expiredAt,
      );

      ref.invalidate(organizationMembersProvider(selectedOrg.id));
      ref.invalidate(organizationOfficersProvider(selectedOrg.id));

      if (mounted) {
        Navigator.pop(context);
        messenger.showSnackBar(
          SnackBar(
            content: Text('${widget.member.fullName} successfully promoted to Representative.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e, stack) {
      debugPrint('Promotion error: $e\n$stack');
      if (mounted) {
        _showError('Error promoting user: $e');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        role.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
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
