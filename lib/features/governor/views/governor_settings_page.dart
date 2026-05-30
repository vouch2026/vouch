import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../../users/widgets/user_management_header.dart';

class GovernorSettingsPage extends ConsumerWidget {
  const GovernorSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DashboardLayout(
      title: 'Organization Settings',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const UserManagementHeader(
              title: 'Settings',
              subtitle: 'Configure your organization profile and preferences',
              actions: [],
            ),
            const SizedBox(height: AppSpacing.xl),
            
            _buildSettingsSection(
              title: 'General Information',
              icon: Icons.info_outline_rounded,
              children: [
                _buildSettingTile(
                  label: 'Organization Profile',
                  subtitle: 'Update name, code, and description',
                  onTap: () {},
                ),
                _buildSettingTile(
                  label: 'Branding',
                  subtitle: 'Change logos and banners',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            
            _buildSettingsSection(
              title: 'Workspace Management',
              icon: Icons.workspaces_outline,
              children: [
                _buildSettingTile(
                  label: 'Membership Rules',
                  subtitle: 'Configure join requirements',
                  onTap: () {},
                ),
                _buildSettingTile(
                  label: 'Role Permissions',
                  subtitle: 'Fine-tune what officers can do',
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.blueGrey),
            const SizedBox(width: AppSpacing.sm),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile({
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
