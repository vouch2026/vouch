import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../widgets/user_management_header.dart';
import '../widgets/user_kpi_cards.dart';
import '../widgets/advanced_user_filter_panel.dart';
import '../widgets/users_table.dart';
import '../widgets/modals/create_student_modal.dart';
import '../widgets/modals/create_instructor_modal.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      title: 'User Management',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserManagementHeader(
              title: 'Users',
              subtitle: 'Manage all university accounts, including students and instructors',
              actions: [
                HeaderActionButton(
                  icon: Icons.person_add_rounded,
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
                  icon: Icons.school_rounded,
                  label: 'Add Instructor',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const CreateInstructorModal(),
                    );
                  },
                  isPrimary: false,
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
                  label: 'Role',
                  key: 'role',
                  options: [
                    FilterValue(label: 'Student', value: 'student'),
                    FilterValue(label: 'Instructor', value: 'instructor'),
                    FilterValue(label: 'Adviser', value: 'adviser'),
                  ],
                ),
                FilterOption(
                  label: 'Campus',
                  key: 'campusId',
                  options: [
                    FilterValue(label: 'Main Campus', value: 'main'),
                    FilterValue(label: 'Banaybanay', value: 'banay'),
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
            
            const UsersTable(),
          ],
        ),
      ),
    );
  }
}
