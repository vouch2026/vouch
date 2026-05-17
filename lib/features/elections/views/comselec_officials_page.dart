import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/layouts/dashboard_layout.dart';

class ComselecOfficialsPage extends StatelessWidget {
  const ComselecOfficialsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DashboardLayout(
      title: 'COMSELEC Officials',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('COMSELEC Official Management', style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
                    Text('Manage election officials, commissioners, and staff roles', 
                        style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey[600])),
                  ],
                ),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.person_add_rounded, size: 18),
                  label: const Text('Assign Official'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
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
                separatorBuilder: (c, i) => const Divider(height: 1),
                itemBuilder: (c, i) {
                  final names = ['Dr. John Doe', 'Prof. Jane Smith', 'Mr. Robert Fox'];
                  final roles = ['COMSELEC Chairman', 'COMSELEC Commissioner', 'Election Staff'];
                  final statuses = ['active', 'active', 'inactive'];
                  
                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person_outline_rounded)),
                    title: Text(names[i], style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                    subtitle: Text(roles[i], style: AppTextStyles.bodySmall),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _StatusBadge(status: statuses[i]),
                        IconButton(icon: const Icon(Icons.settings_outlined, size: 20), onPressed: () {}),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = status == 'active' ? Colors.green : Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
