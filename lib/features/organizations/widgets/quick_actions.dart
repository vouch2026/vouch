import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/role_mapper.dart';
import '../providers/workspace_provider.dart';
import 'modals/organization_creation_modal.dart';
import 'details/assign_adviser_dialog.dart';
import '../../auth/providers/auth_provider.dart';

class QuickActions extends ConsumerWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider).value;
    final isSuperAdmin = userProfile?.role == 'super_admin';
    
    // Only Super Admins can see these quick actions
    if (!isSuperAdmin) {
      return const SizedBox.shrink();
    }
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.sm,
      children: [
        _ActionButton(
          icon: Icons.add_business_rounded,
          label: 'Create Organization',
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => const OrganizationCreationModal(),
            );
          },
          isPrimary: true,
        ),
        _ActionButton(
          icon: Icons.person_add_alt_1_rounded,
          label: 'Assign Adviser',
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => const AssignAdviserDialog(),
            );
          },
        ),
        _ActionButton(
          icon: Icons.analytics_rounded,
          label: 'Generate Reports',
          onPressed: () {},
        ),
        _ActionButton(
          icon: Icons.file_download_rounded,
          label: 'Export Data',
          onPressed: () {},
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (isPrimary) {
      return FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(label),
      );
    }

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: theme.colorScheme.onSurface,
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
    );
  }
}
