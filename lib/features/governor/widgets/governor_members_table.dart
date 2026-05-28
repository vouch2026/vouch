import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class GovernorMembersTable extends StatelessWidget {
  const GovernorMembersTable({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Mock data for recommendation
    final List<Map<String, dynamic>> mockMembers = [
      {
        'id': '2022-00123',
        'name': 'John Doe',
        'email': 'john.doe@university.edu.ph',
        'program': 'BSIT',
        'year': '3rd Year',
        'role': 'Governor',
        'joined': 'Aug 15, 2023',
      },
      {
        'id': '2022-00456',
        'name': 'Jane Smith',
        'email': 'jane.smith@university.edu.ph',
        'program': 'BSCS',
        'year': '2nd Year',
        'role': 'Treasurer',
        'joined': 'Sep 02, 2023',
      },
      {
        'id': '2023-00789',
        'name': 'Michael Chen',
        'email': 'm.chen@university.edu.ph',
        'program': 'BSIT',
        'year': '1st Year',
        'role': 'Staff',
        'joined': 'Jan 10, 2024',
      },
      {
        'id': '2021-00321',
        'name': 'Sarah Johnson',
        'email': 's.johnson@university.edu.ph',
        'program': 'BSBA',
        'year': '4th Year',
        'role': 'Officer',
        'joined': 'Aug 20, 2022',
      },
      {
        'id': '2022-00987',
        'name': 'David Wilson',
        'email': 'd.wilson@university.edu.ph',
        'program': 'BSCrim',
        'year': '3rd Year',
        'role': 'Member',
        'joined': 'Oct 12, 2023',
      },
      {
        'id': '2023-01122',
        'name': 'Emily Davis',
        'email': 'e.davis@university.edu.ph',
        'program': 'BSIT',
        'year': '1st Year',
        'role': 'Member',
        'joined': 'Jan 15, 2024',
      },
      {
        'id': '2022-00554',
        'name': 'Robert Brown',
        'email': 'r.brown@university.edu.ph',
        'program': 'BSCS',
        'year': '2nd Year',
        'role': 'Member',
        'joined': 'Aug 28, 2023',
      },
      {
        'id': '2021-00887',
        'name': 'Sophia Garcia',
        'email': 's.garcia@university.edu.ph',
        'program': 'BSBA',
        'year': '4th Year',
        'role': 'Member',
        'joined': 'Aug 18, 2022',
      },
      {
        'id': '2023-01443',
        'name': 'James Miller',
        'email': 'j.miller@university.edu.ph',
        'program': 'BSIT',
        'year': '1st Year',
        'role': 'Member',
        'joined': 'Feb 05, 2024',
      },
      {
        'id': '2022-00667',
        'name': 'Isabella Martinez',
        'email': 'i.martinez@university.edu.ph',
        'program': 'BSCrim',
        'year': '3rd Year',
        'role': 'Member',
        'joined': 'Sep 15, 2023',
      },
    ];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DataTable(
            headingRowColor: MaterialStateProperty.all(theme.colorScheme.surfaceVariant.withOpacity(0.3)),
            columns: const [
              DataColumn(label: Text('Member')),
              DataColumn(label: Text('Student ID')),
              DataColumn(label: Text('Program & Year')),
              DataColumn(label: Text('Joined Date')),
              DataColumn(label: Text('Role')),
              DataColumn(label: Text('Actions')),
            ],
            rows: mockMembers.map((member) {
              return DataRow(
                cells: [
                  DataCell(
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: Text(
                            member['name'][0],
                            style: TextStyle(color: theme.colorScheme.onPrimaryContainer, fontSize: 12),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(member['name'], style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                            Text(member['email'], style: AppTextStyles.labelSmall.copyWith(color: Colors.grey[600])),
                          ],
                        ),
                      ],
                    ),
                  ),
                  DataCell(Text(member['id'], style: AppTextStyles.bodySmall)),
                  DataCell(Text('${member['program']} - ${member['year']}', style: AppTextStyles.bodySmall)),
                  DataCell(Text(member['joined'], style: AppTextStyles.bodySmall)),
                  DataCell(_RoleBadge(role: member['role'])),
                  DataCell(
                    _buildMemberActions(context, member),
                  ),
                ],
              );
            }).toList(),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Showing 10 of 1,248 members',
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
  }

  Widget _buildMemberActions(BuildContext context, Map<String, dynamic> member) {
    final role = member['role'].toString().toLowerCase();
    final isStaff = role == 'staff';
    final isMember = role == 'member';

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

  void _showPromotionDialog(BuildContext context, Map<String, dynamic> member, bool isPromoting) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isPromoting ? 'Promote to Staff' : 'Demote from Staff'),
        content: Text(
          isPromoting
              ? 'Are you sure you want to promote ${member['name']} to Event Staff? They will be able to scan QR codes during organization events.'
              : 'Are you sure you want to demote ${member['name']} from Event Staff? They will no longer have scanning privileges.',
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
                  content: Text('${member['name']} successfully ${isPromoting ? 'promoted' : 'demoted'}.'),
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
    switch (role.toLowerCase()) {
      case 'governor':
        color = AppColors.primary;
        break;
      case 'treasurer':
        color = Colors.orange;
        break;
      case 'officer':
        color = Colors.blue;
        break;
      case 'staff':
        color = Colors.purple;
        break;
      case 'member':
        color = Colors.green;
        break;
      default:
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
