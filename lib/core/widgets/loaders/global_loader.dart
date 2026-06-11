import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import 'package:skeletonizer/skeletonizer.dart';

class GlobalLoader extends StatelessWidget {
  final bool isSkeleton;
  final Widget? child;

  const GlobalLoader({
    super.key,
    this.isSkeleton = false,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (isSkeleton && child != null) {
      return Skeletonizer(
        enabled: true,
        child: child!,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          _buildBackgroundDecorations(),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                  tag: 'app_logo',
                  child: Image.asset(
                    'assets/logos/vouch.png',
                    width: 150,
                    height: 150,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundDecorations() {
    return Stack(
      children: [
        Positioned(
          top: 70,
          right: -50,
          child: Container(
            width: 210,
            height: 210,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(120),
            ),
          ),
        ),
        Positioned(
          bottom: 170,
          left: -30,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(90),
            ),
          ),
        ),
      ],
    );
  }
}
