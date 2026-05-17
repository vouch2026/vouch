import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/users_provider.dart';
import '../models/student_profile_model.dart';
import '../../auth/models/user_model.dart';

class StudentsTable extends ConsumerWidget {
  const StudentsTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(studentsProvider);

    return studentsAsync.when(
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
            DataColumn(label: Text('Student ID')),
            DataColumn(label: Text('Full Name')),
            DataColumn(label: Text('Program')),
            DataColumn(label: Text('Year')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Actions')),
          ],
          rows: data.map((item) {
            final user = item['user'] as UserModel;
            final profile = item['profile'] as StudentProfileModel;
            
            return DataRow(
              cells: [
                DataCell(Text(profile.studentNumber, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold))),
                DataCell(Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(user.fullName ?? 'Unknown', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                    Text(user.email, style: AppTextStyles.bodySmall),
                  ],
                )),
                DataCell(Text(profile.programName ?? 'N/A', style: AppTextStyles.bodySmall)),
                DataCell(Text('${profile.yearLevel}', style: AppTextStyles.bodySmall)),
                DataCell(_StatusBadge(status: profile.status)),
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
        final profile = data[index]['profile'] as StudentProfileModel;
        
        return Card(
          child: ListTile(
            title: Text(user.fullName ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${profile.studentNumber} • ${profile.programName}'),
            trailing: _StatusBadge(status: profile.status),
          ),
        );
      },
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
