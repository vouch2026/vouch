import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class UserManagementHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> actions;

  const UserManagementHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.headlineMedium.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey[600])),
              ],
            ),
            Wrap(
              spacing: AppSpacing.sm,
              children: actions,
            ),
          ],
        ),
      ],
    );
  }
}

class HeaderActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;

  const HeaderActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isPrimary) {
      return FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
      );
    }
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
    );
  }
}
