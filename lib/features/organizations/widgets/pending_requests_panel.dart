import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class PendingRequestsPanel extends StatelessWidget {
  const PendingRequestsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Pending Requests', style: AppTextStyles.titleLarge),
            TextButton(onPressed: () {}, child: const Text('View All')),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            separatorBuilder: (context, index) => Divider(height: 1, color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
            itemBuilder: (context, index) {
              final titles = ['Google Developer Student Club', 'Vouch Technical Society', 'Junior Marketing Association'];
              final types = ['Organization Registration', 'Adviser Assignment', 'Organization Modification'];
              
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(Icons.description_outlined, color: theme.colorScheme.primary, size: 20),
                ),
                title: Text(titles[index], style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                subtitle: Text(types[index], style: AppTextStyles.bodySmall),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check_circle_outlined, color: Colors.green, size: 20),
                      onPressed: () {},
                      tooltip: 'Approve',
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel_outlined, color: Colors.red, size: 20),
                      onPressed: () {},
                      tooltip: 'Reject',
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
