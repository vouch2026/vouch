import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/users_provider.dart';
import '../models/student_profile_model.dart';
import '../models/instructor_profile_model.dart';
import '../../auth/models/user_model.dart';

class UsersTable extends ConsumerWidget {
  const UsersTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(allUsersProvider);

    return usersAsync.when(
      data: (data) => LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 800) {
            return _buildCardList(data);
          }
          return _buildDataTable(context, data);
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildDataTable(BuildContext context, List<Map<String, dynamic>> data) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(theme.colorScheme.surfaceVariant.withOpacity(0.3)),
          columns: const [
            DataColumn(label: Text('ID / Number')),
            DataColumn(label: Text('Full Name')),
            DataColumn(label: Text('Role')),
            DataColumn(label: Text('Faculty / Program')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Actions')),
          ],
          rows: data.map((item) {
            final user = item['user'] as UserModel;
            final profile = item['profile'];
            
            String idNumber = 'N/A';
            String secondaryInfo = 'N/A';
            String roleLabel = user.roleDisplay;
            
            if (profile is StudentProfileModel) {
              idNumber = profile.studentNumber;
              secondaryInfo = profile.programName ?? profile.facultyName ?? 'N/A';
            } else if (profile is InstructorProfileModel) {
              idNumber = profile.instructorId;
              secondaryInfo = profile.facultyName ?? 'N/A';
              roleLabel = profile.position.replaceAll('_', ' ').toUpperCase();
            }
            
            return DataRow(
              cells: [
                DataCell(Text(idNumber, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold))),
                DataCell(Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(user.fullName, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                    Text(user.email, style: AppTextStyles.bodySmall),
                  ],
                )),
                DataCell(_RoleBadge(role: user.role, label: roleLabel)),
                DataCell(Text(secondaryInfo, style: AppTextStyles.bodySmall)),
                DataCell(_StatusBadge(status: (profile as dynamic).status)),
                DataCell(PopupMenuButton(
                  icon: const Icon(Icons.more_vert_rounded, size: 20),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'view', child: Text('View Profile')),
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'status', child: Text('Change Status')),
                    const PopupMenuItem(value: 'suspend', child: Text('Suspend')),
                  ],
                )),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCardList(List<Map<String, dynamic>> data) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: data.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final user = data[index]['user'] as UserModel;
        final profile = data[index]['profile'];
        
        String idNumber = 'N/A';
        if (profile is StudentProfileModel) {
          idNumber = profile.studentNumber;
        } else if (profile is InstructorProfileModel) {
          idNumber = profile.instructorId;
        }
        
        return Card(
          child: ListTile(
            title: Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('$idNumber • ${user.roleDisplay}'),
            trailing: _StatusBadge(status: (profile as dynamic).status),
          ),
        );
      },
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String role;
  final String label;
  const _RoleBadge({required this.role, required this.label});

  @override
  Widget build(BuildContext context) {
    Color color;
    if (role == 'student') {
      color = Colors.blue;
    } else {
      color = Colors.indigo;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status.toLowerCase()) {
      case 'active':
        color = Colors.green;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'suspended':
        color = Colors.red;
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
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
