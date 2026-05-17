import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../widgets/user_management_header.dart';
import '../widgets/user_kpi_cards.dart';
import '../widgets/advanced_user_filter_panel.dart';
import '../widgets/students_table.dart';
import '../widgets/modals/create_student_modal.dart';

class StudentsPage extends StatelessWidget {
  const StudentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      title: 'Student Management',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserManagementHeader(
              title: 'Students',
              subtitle: 'Manage student accounts, academic records, and memberships',
              actions: [
                HeaderActionButton(
                  icon: Icons.add_rounded,
                  label: 'Add Student',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const CreateStudentModal(),
                    );
                  },
                  isPrimary: true,
                ),
                HeaderActionButton(
                  icon: Icons.file_upload_outlined,
                  label: 'Import',
                  onPressed: () {},
                ),
                HeaderActionButton(
                  icon: Icons.file_download_outlined,
                  label: 'Export',
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            const UserKpiCards(),
            const SizedBox(height: AppSpacing.xl),
            
            AdvancedUserFilterPanel(
              filters: const [
                FilterOption(
                  label: 'Campus',
                  key: 'campusId',
                  options: [
                    FilterValue(label: 'Main Campus', value: 'main'),
                    FilterValue(label: 'Banaybanay', value: 'banay'),
                  ],
                ),
                FilterOption(
                  label: 'Faculty',
                  key: 'facultyId',
                  options: [
                    FilterValue(label: 'FCET', value: 'fcet'),
                    FilterValue(label: 'FTE', value: 'fte'),
                  ],
                ),
                FilterOption(
                  label: 'Year Level',
                  key: 'yearLevel',
                  options: [
                    FilterValue(label: '1st Year', value: 1),
                    FilterValue(label: '2nd Year', value: 2),
                    FilterValue(label: '3rd Year', value: 3),
                    FilterValue(label: '4th Year', value: 4),
                  ],
                ),
                FilterOption(
                  label: 'Status',
                  key: 'status',
                  options: [
                    FilterValue(label: 'Active', value: 'active'),
                    FilterValue(label: 'Pending', value: 'pending'),
                    FilterValue(label: 'Suspended', value: 'suspended'),
                  ],
                ),
              ],
              onSearchChanged: (query) {},
              onFiltersChanged: (filters) {},
            ),
            const SizedBox(height: AppSpacing.lg),
            
            const StudentsTable(),
          ],
        ),
      ),
    );
  }
}
