import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class TopOrganizationsLeaderboard extends StatelessWidget {
  const TopOrganizationsLeaderboard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Top Organizations', style: AppTextStyles.titleLarge),
        const SizedBox(height: AppSpacing.md),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              separatorBuilder: (context, index) => Divider(height: 1, color: theme.colorScheme.outlineVariant.withOpacity(0.3)),
              itemBuilder: (context, index) {
                final names = [
                  'Google Developer Student Club',
                  'Vouch Technical Society',
                  'Junior Marketing Association',
                  'Supreme Student Government',
                  'Code Masters'
                ];
                final scores = ['98.5%', '97.2%', '95.8%', '94.5%', '93.0%'];
                final ranks = ['#1', '#2', '#3', '#4', '#5'];
                final colors = [Colors.amber, Colors.grey.shade400, Colors.orange.shade700, Colors.blue, Colors.blue];

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: colors[index].withOpacity(0.1),
                    child: Text(ranks[index], style: TextStyle(color: colors[index], fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                  title: Text(names[index], style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                  subtitle: Text('Score: ${scores[index]}', style: AppTextStyles.bodySmall),
                  trailing: const Icon(Icons.analytics_outlined, size: 20),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
