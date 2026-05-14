import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/organization_provider.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/layouts/dashboard_layout.dart';

class OrganizationsPage extends ConsumerWidget {
  const OrganizationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final organizations = ref.watch(organizationsProvider);

    return DashboardLayout(
      title: 'Organizations',
      child: organizations.when(
        data: (orgs) => ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: orgs.length,
          separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) {
            final org = orgs[index];
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: org.logoUrl != null ? NetworkImage(org.logoUrl!) : null,
                  child: org.logoUrl == null ? Text(org.code[0]) : null,
                ),
                title: Text(org.name, style: AppTextStyles.titleLarge),
                subtitle: Text(org.code, style: AppTextStyles.bodySmall),
                onTap: () {
                  // TODO: Navigate to details
                },
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
