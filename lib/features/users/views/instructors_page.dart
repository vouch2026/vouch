import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../widgets/user_management_header.dart';
import '../widgets/user_kpi_cards.dart';
import '../widgets/advanced_user_filter_panel.dart';
import '../widgets/instructors_table.dart';
import '../widgets/modals/create_instructor_modal.dart';

class InstructorsPage extends StatelessWidget {
  const InstructorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      title: 'Instructor Management',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserManagementHeader(
              title: 'Instructors',
              subtitle: 'Manage faculty staff, deans, program heads, and academic assignments',
              actions: [
                HeaderActionButton(
                  icon: Icons.add_rounded,
                  label: 'Add Instructor',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const CreateInstructorModal(),
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
                  label: 'Position',
                  key: 'position',
                  options: [
                    FilterValue(label: 'Dean', value: 'dean'),
                    FilterValue(label: 'Program Head', value: 'program_head'),
                    FilterValue(label: 'Adviser', value: 'adviser'),
                    FilterValue(label: 'Instructor', value: 'instructor'),
                  ],
                ),
                FilterOption(
                  label: 'Status',
                  key: 'status',
                  options: [
                    FilterValue(label: 'Active', value: 'active'),
                    FilterValue(label: 'Suspended', value: 'suspended'),
                  ],
                ),
              ],
              onSearchChanged: (query) {},
              onFiltersChanged: (filters) {},
            ),
            const SizedBox(height: AppSpacing.lg),
            
            const InstructorsTable(),
          ],
        ),
      ),
    );
  }
}
