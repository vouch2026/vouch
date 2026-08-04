import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/config/supabase_config.dart';
import '../../models/organization_model.dart';
import '../../providers/organization_provider.dart';
import '../../controllers/organization_controller.dart';
import '../../../auth/providers/auth_provider.dart';
import './org_details_analytics_cards.dart';

class OrgDetailsHeader extends ConsumerWidget {
  final OrganizationModel org;

  const OrgDetailsHeader({super.key, required this.org});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider).value;
    final isSuperAdmin = userProfile?.role == 'super_admin';
    final eventsAsync = ref.watch(orgEventsProvider(org));

    final upcomingCount = eventsAsync.valueOrNull?.where((e) {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      // Event is today or in the future
      return e.eventDate.isAfter(todayStart) || 
             e.eventDate.year == todayStart.year && 
             e.eventDate.month == todayStart.month && 
             e.eventDate.day == todayStart.day;
    }).length ?? 0;
    
    return Column(
      children: [
        // Banner and Logo Section
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              color: AppColors.primary,
              child: org.bannerUrl != null && org.bannerUrl!.isNotEmpty
                  ? Image.network(
                      org.bannerUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Opacity(
                        opacity: 0.1,
                        child: Icon(Icons.image, size: 100, color: Colors.white),
                      ),
                    )
                  : const Opacity(
                      opacity: 0.1,
                      child: Icon(Icons.image, size: 100, color: Colors.white),
                    ),
            ),
            // Logo overlay
            Positioned(
              bottom: -40,
              left: AppSpacing.lg,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.background,
                  backgroundImage: org.logoUrl != null ? NetworkImage(org.logoUrl!) : null,
                  child: org.logoUrl == null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.asset(
                            'assets/logos/vouch.webp',
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Text(
                              org.code[0],
                              style: AppTextStyles.headlineLarge.copyWith(color: AppColors.primary),
                            ),
                          ),
                        )
                      : null,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 50),
        // Title and Info Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          org.name,
                          style: AppTextStyles.headlineMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        _buildStatusBadge(org.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${org.code} • ${org.facultyProgram ?? "General"} • ${org.type.replaceAll('-', ' ').toUpperCase()}',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.sm,
                      children: [
                        _buildInfoChip(Icons.person_outline_rounded, 'Adviser: ${org.adviserName ?? "Not Assigned"}'),
                        _buildInfoChip(Icons.event_available_rounded, '$upcomingCount Upcoming Events'),
                      ],
                    ),
                  ],
                ),
              ),
              // Action Buttons
              _buildActionButtons(context, ref, isSuperAdmin),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status.toUpperCase(),
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textGrey),
          const SizedBox(width: 6),
          Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, bool isSuperAdmin) {
    if (!isSuperAdmin) return const SizedBox.shrink();

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_horiz_rounded),
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: (value) async {
        if (value == 'edit') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Use the Settings tab below to modify organization details.'),
            ),
          );
        } else if (value == 'suspend') {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Suspend Organization', style: TextStyle(fontWeight: FontWeight.bold)),
              content: Text('Are you sure you want to suspend ${org.name}?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                  child: const Text('Confirm'),
                ),
              ],
            ),
          );
          if (confirm == true) {
            try {
              await SupabaseConfig.client
                  .from('organizations')
                  .update({'status': 'suspended'})
                  .eq('id', org.id);
              ref.invalidate(organizationProvider(org.id));
              ref.invalidate(organizationsProvider);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Organization suspended successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to suspend: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          }
        } else if (value == 'activate') {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Activate Organization', style: TextStyle(fontWeight: FontWeight.bold)),
              content: Text('Are you sure you want to activate ${org.name}?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                  child: const Text('Confirm'),
                ),
              ],
            ),
          );
          if (confirm == true) {
            try {
              await SupabaseConfig.client
                  .from('organizations')
                  .update({'status': 'active'})
                  .eq('id', org.id);
              ref.invalidate(organizationProvider(org.id));
              ref.invalidate(organizationsProvider);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Organization activated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to activate: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          }
        } else if (value == 'delete') {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Delete Organization', style: TextStyle(fontWeight: FontWeight.bold)),
              content: Text('Are you sure you want to delete ${org.name}? This action cannot be undone.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: FilledButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Delete'),
                ),
              ],
            ),
          );
          if (confirm == true) {
            final success = await ref.read(organizationControllerProvider.notifier).deleteOrganization(org.id);
            if (context.mounted) {
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Organization deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
                context.go('/organizations');
              } else {
                final error = ref.read(organizationControllerProvider).error;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete: ${error?.toString() ?? 'Unknown error'}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          }
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Text('Edit', style: TextStyle(fontSize: 13)),
        ),
        if (org.status.toLowerCase() == 'suspended')
          const PopupMenuItem(
            value: 'activate',
            child: Text('Activate', style: TextStyle(fontSize: 13)),
          )
        else
          const PopupMenuItem(
            value: 'suspend',
            child: Text('Suspend', style: TextStyle(fontSize: 13)),
          ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'delete',
          child: Text('Delete', style: TextStyle(color: Colors.red, fontSize: 13)),
        ),
      ],
    );
  }
}
