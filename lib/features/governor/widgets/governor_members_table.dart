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

class GovernorMembersTable extends ConsumerWidget {
  const GovernorMembersTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final workspace = ref.watch(workspaceProvider);
    final selectedOrg = workspace.selectedOrganization;
    final activeRoleName = workspace.activeRole?.roleName.toLowerCase() ?? '';
    final canManageMembers = activeRoleName.contains('governor') || 
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
      builder: (context) => AlertDialog(
        title: const Text('Promote to Representative'),
        content: Text(
          'Are you sure you want to promote ${member.fullName} to Organization Representative?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${member.fullName} successfully promoted as Representative.'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm Promotion'),
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
