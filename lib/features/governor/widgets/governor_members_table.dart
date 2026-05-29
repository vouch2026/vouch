import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../organizations/providers/workspace_provider.dart';
import '../../organizations/providers/organization_provider.dart';
import '../../auth/models/user_model.dart';

class GovernorMembersTable extends ConsumerWidget {
  const GovernorMembersTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final workspace = ref.watch(workspaceProvider);
    final selectedOrg = workspace.selectedOrganization;

    if (selectedOrg == null) {
      return const Center(child: Text('Please select an organization.'));
    }

    final membersAsync = ref.watch(organizationMembersProvider(selectedOrg.id));

    return membersAsync.when(
      data: (members) {
        if (members.isEmpty) {
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
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(theme.colorScheme.surfaceVariant.withOpacity(0.3)),
                  columns: const [
                    DataColumn(label: Text('Member')),
                    DataColumn(label: Text('Student ID')),
                    DataColumn(label: Text('Program & Year')),
                    DataColumn(label: Text('Joined Date')),
                    DataColumn(label: Text('Role')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: members.map((member) {
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
                        DataCell(
                          _buildMemberActions(context, member),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Showing ${members.length} members',
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
          child: CircularProgressIndicator(),
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
    final isStaff = role == 'staff';
    final isMember = role == 'member' || role == 'student';

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded, size: 20),
      onSelected: (value) {
        if (value == 'promote_staff') {
          _showPromotionDialog(context, member, true);
        } else if (value == 'demote_staff') {
          _showPromotionDialog(context, member, false);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'view',
          child: Row(
            children: [
              Icon(Icons.visibility_outlined, size: 18),
              SizedBox(width: 8),
              Text('View Profile'),
            ],
          ),
        ),
        if (isMember)
          const PopupMenuItem(
            value: 'promote_staff',
            child: Row(
              children: [
                Icon(Icons.admin_panel_settings_outlined, size: 18, color: AppColors.primary),
                SizedBox(width: 8),
                Text('Promote to Staff'),
              ],
            ),
          ),
        if (isStaff)
          const PopupMenuItem(
            value: 'demote_staff',
            child: Row(
              children: [
                Icon(Icons.person_remove_outlined, size: 18, color: Colors.red),
                SizedBox(width: 8),
                Text('Demote from Staff'),
              ],
            ),
          ),
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 18),
              SizedBox(width: 8),
              Text('Edit Details'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'remove',
          child: Row(
            children: [
              Icon(Icons.person_off_outlined, size: 18, color: Colors.red),
              SizedBox(width: 8),
              Text('Remove from Org', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  void _showPromotionDialog(BuildContext context, UserModel member, bool isPromoting) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isPromoting ? 'Promote to Staff' : 'Demote from Staff'),
        content: Text(
          isPromoting
              ? 'Are you sure you want to promote ${member.fullName} to Event Staff? They will be able to scan QR codes during organization events.'
              : 'Are you sure you want to demote ${member.fullName} from Event Staff? They will no longer have scanning privileges.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implementation would update the state/provider
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${member.fullName} successfully ${isPromoting ? 'promoted' : 'demoted'}.'),
                  backgroundColor: isPromoting ? Colors.green : Colors.blue,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isPromoting ? AppColors.primary : Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(isPromoting ? 'Confirm Promotion' : 'Confirm Demotion'),
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
    } else if (lowerRole.contains('officer') || lowerRole.contains('dean') || lowerRole.contains('head')) {
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
