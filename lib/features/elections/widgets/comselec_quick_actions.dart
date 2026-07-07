import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import 'comselec_creation_modal.dart';

class ComselecQuickActions extends StatelessWidget {
  const ComselecQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.sm,
      children: [
        _ActionButton(
          icon: Icons.add_moderator_rounded,
          label: 'Create COMSELEC Branch',
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => const ComselecCreationModal(),
            );
          },
          isPrimary: true,
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
