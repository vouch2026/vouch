import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../features/auth/controllers/auth_controller.dart';
import '../../../../features/auth/providers/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../routes/route_paths.dart';

class ProfileMenuContent extends ConsumerWidget {
  final bool isModal;

  const ProfileMenuContent({
    super.key,
    this.isModal = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);

    return userProfile.when(
      data: (profile) {
        final avatarUrl = profile?.avatarUrl;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Close Button (Matching Auth Vibe)
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.sm, AppSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Profile',
                    style: AppTextStyles.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, size: 22, color: AppColors.primary),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.accent.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),

            // Profile Card Section
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          width: 2.5,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 32,
                        backgroundColor: Colors.grey.shade100,
                        backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                            ? NetworkImage(avatarUrl)
                            : const AssetImage('assets/images/my_profile.png') as ImageProvider,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      profile?.fullName ?? 'User',
                      style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      profile?.email ?? '',
                      style: AppTextStyles.bodySmall.copyWith(color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        profile?.role?.toUpperCase() ?? 'STUDENT',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Divider(height: 1, indent: AppSpacing.lg, endIndent: AppSpacing.lg),

            // Navigation Links (Matching Textfield Prefix Icon Style)
            _buildMenuItem(
              context,
              icon: Icons.person_outline_rounded,
              label: 'Manage Account',
              onTap: () {
                Navigator.of(context).pop();
                context.push(RoutePaths.profile);
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.settings_outlined,
              label: 'App Settings',
              onTap: () {
                Navigator.of(context).pop();
                context.push(RoutePaths.settings);
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.help_outline_rounded,
              label: 'Support Center',
              onTap: () {},
            ),

            const SizedBox(height: AppSpacing.md),
            
            // Sign Out Button (Matching Auth Button Style)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    ref.read(authControllerProvider.notifier).signOut();
                  },
                  icon: const Icon(Icons.logout_rounded, size: 20),
                  label: Text(
                    'Sign Out',
                    style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
            
            if (!isModal) const SizedBox(height: AppSpacing.xl),
          ],
        );
      },
      loading: () => const SizedBox(
        height: 300,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: AppColors.primary),
      ),
      title: Text(
        label,
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: Colors.black26),
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: 2),
      onTap: onTap,
    );
  }
}
