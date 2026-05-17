import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'modals/create_election_modal.dart';

class ComselecManagementHeader extends StatelessWidget {
  const ComselecManagementHeader({super.key});

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
                Text('COMSELEC Management', style: AppTextStyles.headlineMedium.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Manage university elections, candidates, voting, and governance operations', 
                    style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey[600])),
              ],
            ),
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                _HeaderAction(
                  icon: Icons.add_rounded, 
                  label: 'Create Election', 
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const CreateElectionModal(),
                    );
                  }, 
                  isPrimary: true,
                ),
                _HeaderAction(icon: Icons.person_add_alt_1_rounded, label: 'Register Candidate', onPressed: () {}),
                _HeaderAction(icon: Icons.publish_rounded, label: 'Publish Results', onPressed: () {}),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _HeaderAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;

  const _HeaderAction({
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
