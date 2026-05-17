import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/auth/providers/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import 'profile_menu_content.dart';

class ProfileDropdown extends ConsumerWidget {
  const ProfileDropdown({super.key});

  void _showProfileMenu(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Profile Menu',
      barrierColor: Colors.black.withValues(alpha: 0.35),
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Stack(
          children: [
            Positioned(
              top: isMobile ? 0 : 80,
              right: isMobile ? 0 : 20,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: isMobile ? size.width : 380,
                  height: isMobile ? size.height : null,
                  constraints: isMobile 
                      ? null 
                      : BoxConstraints(maxHeight: size.height - 120),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(isMobile ? 0 : 24),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.1), width: 1.2),
                    boxShadow: isMobile ? null : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(isMobile ? 0 : 24),
                    child: Stack(
                      children: [
                        // Background Decorations (Matching Login/Signup)
                        Positioned(
                          top: -40,
                          right: -40,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -30,
                          left: -30,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.06),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        
                        SafeArea(
                          top: isMobile,
                          bottom: isMobile,
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: ProfileMenuContent(isModal: !isMobile),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: isMobile ? const Offset(0, 0.1) : const Offset(0.05, 0.02),
              end: Offset.zero,
            ).animate(curve),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);

    return userProfile.when(
      data: (profile) {
        final avatarUrl = profile?.avatarUrl;

        return Padding(
          padding: const EdgeInsets.only(right: AppSpacing.md),
          child: InkWell(
            onTap: () => _showProfileMenu(context),
            borderRadius: BorderRadius.circular(30),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: AppColors.accent.withValues(alpha: 0.15),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.grey.shade100,
                      backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                          ? NetworkImage(avatarUrl)
                          : const AssetImage('assets/images/my_profile.png') as ImageProvider,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.expand_more_rounded, size: 18, color: AppColors.primary),
                  const SizedBox(width: 2),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (_, __) => const Icon(Icons.error_outline),
    );
  }
}
