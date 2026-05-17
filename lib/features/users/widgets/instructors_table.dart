import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/users_provider.dart';
import '../models/instructor_profile_model.dart';
import '../../auth/models/user_model.dart';

class InstructorsTable extends ConsumerWidget {
  const InstructorsTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final instructorsAsync = ref.watch(instructorsProvider);

    return instructorsAsync.when(
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
            DataColumn(label: Text('Instructor ID')),
            DataColumn(label: Text('Full Name')),
            DataColumn(label: Text('Faculty')),
            DataColumn(label: Text('Position')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Actions')),
          ],
          rows: data.map((item) {
            final user = item['user'] as UserModel;
            final profile = item['profile'] as InstructorProfileModel;
            
            return DataRow(
              cells: [
                DataCell(Text(profile.instructorId, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold))),
                DataCell(Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(user.fullName ?? 'Unknown', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                    Text(user.email, style: AppTextStyles.bodySmall),
                  ],
                )),
                DataCell(Text(profile.facultyName ?? 'N/A', style: AppTextStyles.bodySmall)),
                DataCell(_PositionBadge(position: profile.position)),
                DataCell(_StatusBadge(status: profile.status)),
                DataCell(PopupMenuButton(
                  icon: const Icon(Icons.more_vert_rounded, size: 20),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'view', child: Text('View Profile')),
                    const PopupMenuItem(value: 'assign', child: Text('Assign Leadership')),
                    const PopupMenuItem(value: 'orgs', child: Text('Manage Orgs')),
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
        final profile = data[index]['profile'] as InstructorProfileModel;
        
        return Card(
          child: ListTile(
            title: Text(user.fullName ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${profile.instructorId} • ${profile.position.toUpperCase()}'),
            trailing: _StatusBadge(status: profile.status),
          ),
        );
      },
    );
  }
}

class _PositionBadge extends StatelessWidget {
  final String position;
  const _PositionBadge({required this.position});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (position.toLowerCase()) {
      case 'dean':
        color = Colors.indigo;
        break;
      case 'program_head':
        color = Colors.teal;
        break;
      case 'adviser':
        color = Colors.amber.shade800;
        break;
      default:
        color = Colors.blueGrey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        position.replaceAll('_', ' ').toUpperCase(),
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
    final color = status == 'active' ? Colors.green : Colors.red;
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
