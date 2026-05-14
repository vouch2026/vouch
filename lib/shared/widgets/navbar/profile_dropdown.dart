import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/auth/providers/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
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
      barrierColor: Colors.black.withValues(alpha: 0.4),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Stack(
          children: [
            Positioned(
              top: isMobile ? 0 : 64, // Just below the app bar
              right: isMobile ? 0 : 16,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: isMobile ? size.width : 380,
                  height: isMobile ? size.height : null,
                  constraints: isMobile 
                      ? null 
                      : BoxConstraints(maxHeight: size.height - 100),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(isMobile ? 0 : 24),
                    boxShadow: isMobile ? null : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    border: isMobile ? null : Border.all(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      width: 1,
                    ),
                  ),
                  child: SafeArea(
                    top: isMobile,
                    bottom: isMobile,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: ProfileMenuContent(isModal: !isMobile),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curve,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: isMobile ? const Offset(0, 0.1) : const Offset(0.05, 0),
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
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: InkWell(
            onTap: () => _showProfileMenu(context),
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  width: 2,
                ),
              ),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                    ? NetworkImage(avatarUrl)
                    : const AssetImage('assets/images/my_profile.png') as ImageProvider,
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
