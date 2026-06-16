import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../routes/route_paths.dart';
import '../controllers/auth_controller.dart';
import '../../../core/widgets/loaders/flickr_loader.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _codeSent = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Stack(
          children: [
            _buildBackgroundDecorations(),
            LayoutBuilder(
              builder: (context, constraints) {
                return Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: _buildForgotPasswordCard(context),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
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

  Widget _buildForgotPasswordCard(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => context.go(RoutePaths.login),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary, size: 20),
            ),
          ),
          _buildLogo(size: 44),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Forgot password',
            style: AppTextStyles.displaySmall.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Get an 8-digit code and set your new password',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.black54),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildTextField(
            controller: _emailController,
            hintText: 'Enter your email',
            icon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: AppSpacing.md),
          if (!_codeSent)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: authState.isLoading ? null : () {
                  setState(() => _codeSent = true);
                  // TODO: Implement send code logic
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.primary.withValues(alpha: 0.25)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Send Code'),
              ),
            )
          else ...[
            _buildTextField(
              controller: _codeController,
              hintText: '8-digit code',
              icon: Icons.verified_outlined,
              keyboardType: TextInputType.number,
              maxLength: 8,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildTextField(
              controller: _newPasswordController,
              hintText: 'New password',
              icon: Icons.lock_outline,
              obscureText: !_showNewPassword,
              suffixIcon: IconButton(
                onPressed: () => setState(() => _showNewPassword = !_showNewPassword),
                icon: Icon(_showNewPassword ? Icons.visibility : Icons.visibility_off, color: Colors.grey.shade600, size: 20),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildTextField(
              controller: _confirmPasswordController,
              hintText: 'Retype new password',
              icon: Icons.lock_outline,
              obscureText: !_showConfirmPassword,
              suffixIcon: IconButton(
                onPressed: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
                icon: Icon(_showConfirmPassword ? Icons.visibility : Icons.visibility_off, color: Colors.grey.shade600, size: 20),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: authState.isLoading ? null : () {
                  // TODO: Implement reset password logic
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: authState.isLoading
                    ? const FlickrLoader(
                        size: 8,
                        distance: 10,
                      )
                    : Text(
                        'Reset Password',
                        style: AppTextStyles.titleLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLogo({double size = 40}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/logos/vouch.png', width: size, height: size),
        const SizedBox(width: AppSpacing.sm),
        RichText(
          text: TextSpan(
            style: GoogleFonts.poppins(fontSize: 30, fontWeight: FontWeight.w700),
            children: const [
              TextSpan(text: 'Vou', style: TextStyle(color: AppColors.primary)),
              TextSpan(text: 'ch', style: TextStyle(color: AppColors.accent)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    int? maxLength,
    TextAlign textAlign = TextAlign.start,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLength: maxLength,
      textAlign: textAlign,
      decoration: InputDecoration(
        hintText: hintText,
        counterText: '',
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 10, right: 8),
          child: Center(
            widthFactor: 1,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 18),
            ),
          ),
        ),
        suffixIcon: suffixIcon,
      ),
      style: AppTextStyles.bodyMedium,
    );
  }
}
