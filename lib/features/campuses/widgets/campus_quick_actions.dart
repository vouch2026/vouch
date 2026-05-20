import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../academic_structure/widgets/modals/create_campus_modal.dart';
import '../../academic_structure/widgets/modals/create_faculty_modal.dart';
import '../../academic_structure/widgets/modals/create_program_modal.dart';

class CampusQuickActions extends StatelessWidget {
  const CampusQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.sm,
      children: [
        _ActionButton(
          icon: Icons.add_business_rounded,
          label: 'Add Campus',
          onPressed: () => showDialog(context: context, builder: (c) => const CreateCampusModal()),
          isPrimary: true,
        ),
        _ActionButton(
          icon: Icons.account_balance_rounded,
          label: 'Add Faculty',
          onPressed: () => showDialog(context: context, builder: (c) => const CreateFacultyModal()),
        ),
        _ActionButton(
          icon: Icons.school_rounded,
          label: 'Add Program',
          onPressed: () => showDialog(context: context, builder: (c) => const CreateProgramModal()),
        ),
        _ActionButton(
          icon: Icons.person_add_alt_1_rounded,
          label: 'Assign Dean',
          onPressed: () {},
        ),
        _ActionButton(
          icon: Icons.person_add_rounded,
          label: 'Assign Program Head',
          onPressed: () {},
        ),
        _ActionButton(
          icon: Icons.file_download_rounded,
          label: 'Export Structure',
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
