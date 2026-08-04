import 'package:flutter/material.dart';
import 'package:vouch_v2/core/theme/app_colors.dart';
import 'package:vouch_v2/core/theme/app_text_styles.dart';
import 'package:vouch_v2/core/theme/app_spacing.dart';

class OfflineStateView extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final VoidCallback? onGoBack;
  final bool showActionButton;

  static bool isOfflineError(dynamic error) {
    if (error == null) return false;
    final errorStr = error.toString().toLowerCase();
    return errorStr.contains('socketexception') ||
        errorStr.contains('failed host lookup') ||
        errorStr.contains('clientexception') ||
        errorStr.contains('network') ||
        errorStr.contains('connection') ||
        errorStr.contains('no address associated with hostname');
  }

  const OfflineStateView({
    super.key,
    this.title = "You're Offline",
    this.message = "This feature requires an active internet connection. Please reconnect to access this screen.",
    this.onRetry,
    this.onGoBack,
    this.showActionButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Mascot illustration container
            Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.05),
              ),
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Image.asset(
                'assets/images/mascot-sleep.webp',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback icon if image asset is not loaded
                  return const Icon(
                    Icons.cloud_off_rounded,
                    size: 80,
                    color: AppColors.primary,
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            
            // Offline Headline
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.displaySmall.copyWith(
                color: AppColors.textDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            
            // Offline Subtext/Message
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textGrey,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            
            // Buttons Section
            if (showActionButton) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onGoBack != null) ...[
                    OutlinedButton.icon(
                      onPressed: onGoBack,
                      icon: const Icon(Icons.arrow_back_rounded, size: 16),
                      label: const Text('Go Back'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary, width: 1.5),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                  ],
                  ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
