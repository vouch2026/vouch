import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../auth/providers/auth_provider.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../../core/widgets/loaders/flickr_loader.dart';
import '../../../core/utils/validators.dart';
import '../../../routes/route_paths.dart';

class ChangeEmailPage extends ConsumerStatefulWidget {
  const ChangeEmailPage({super.key});

  @override
  ConsumerState<ChangeEmailPage> createState() => _ChangeEmailPageState();
}

class _ChangeEmailPageState extends ConsumerState<ChangeEmailPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  
  bool _codeSent = false;
  Timer? _emailDebounceTimer;
  bool _isCheckingEmail = false;
  bool _isEmailRegistered = false;
  String? _emailValidationError;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onEmailChanged);
    _codeController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    setState(() {});
  }

  void _onEmailChanged() {
    _onFieldChanged();
    _emailDebounceTimer?.cancel();
    
    // Instantly clear the registration error status when typing starts again
    if (_isEmailRegistered || _emailValidationError != null) {
      setState(() {
        _isEmailRegistered = false;
        _emailValidationError = null;
      });
    }

    _emailDebounceTimer = Timer(const Duration(milliseconds: 600), () {
      if (_emailController.text.trim().isNotEmpty) {
        _checkEmailAvailability(_emailController.text);
      }
    });
  }

  Future<void> _checkEmailAvailability(String email) async {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty) {
      setState(() {
        _isEmailRegistered = false;
        _emailValidationError = null;
      });
      return;
    }

    // Step 1: Perform client-side format validation first
    final formatError = Validators.email(trimmedEmail);
    if (formatError != null) {
      setState(() {
        _isEmailRegistered = false;
        _emailValidationError = formatError;
      });
      return;
    }

    setState(() {
      _isCheckingEmail = true;
      _emailValidationError = null;
    });

    try {
      final repository = ref.read(authRepositoryProvider);
      final exists = await repository.isEmailRegistered(trimmedEmail);
      
      if (mounted) {
        setState(() {
          _isEmailRegistered = exists;
          _isCheckingEmail = false;
          if (exists) {
            _emailValidationError = 'This email is already registered';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCheckingEmail = false;
          _emailValidationError = 'Error verifying email. Please try again.';
        });
      }
    }
  }

  @override
  void dispose() {
    _emailDebounceTimer?.cancel();
    _emailController.removeListener(_onEmailChanged);
    _codeController.removeListener(_onFieldChanged);
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    final isEmailValid = Validators.email(_emailController.text) == null &&
        !_isCheckingEmail &&
        !_isEmailRegistered &&
        _emailValidationError == null;

    if (!_codeSent) {
      return isEmailValid;
    }
    return isEmailValid && _codeController.text.trim().length == 8;
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final profileState = ref.watch(profileControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Stack(
          children: [
            _buildBackgroundDecorations(),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: _buildChangeEmailCard(context, user?.email ?? '', profileState.isLoading),
                ),
              ),
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

  Widget _buildChangeEmailCard(BuildContext context, String currentEmail, bool isLoading) {
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
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => context.go(RoutePaths.profile),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary, size: 20),
              ),
            ),
            _buildLogo(size: 44),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Change Email',
              style: AppTextStyles.displaySmall.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              _codeSent
                  ? 'Verify the 8-digit code sent to your new email address.'
                  : 'Enter your new email address to receive an 8-digit verification code.',
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.primary, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Email',
                          style: AppTextStyles.labelSmall.copyWith(color: AppColors.textGrey),
                        ),
                        Text(
                          currentEmail,
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textDark, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            _buildTextField(
              controller: _emailController,
              hintText: 'New email address',
              icon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
              enabled: !_codeSent,
              errorText: _emailValidationError,
              suffixIcon: _isCheckingEmail
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ),
                    )
                  : (_emailController.text.isNotEmpty && Validators.email(_emailController.text) == null)
                      ? _isEmailRegistered
                          ? const Icon(Icons.error_outline, color: AppColors.error)
                          : const Icon(Icons.check_circle_outline, color: AppColors.success)
                      : null,
              validator: (val) {
                final formatError = Validators.email(val);
                if (formatError != null) return formatError;
                if (val?.trim().toLowerCase() == currentEmail.toLowerCase()) {
                  return 'Must be different from current email';
                }
                if (_emailValidationError != null) {
                  return _emailValidationError;
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            if (_codeSent) ...[
              _buildTextField(
                controller: _codeController,
                hintText: '8-digit verification code',
                icon: Icons.verified_outlined,
                keyboardType: TextInputType.number,
                maxLength: 8,
                textAlign: TextAlign.center,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Code is required';
                  if (val.trim().length != 8) return 'Enter the 8-digit code';
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: (isLoading || !_isFormValid)
                    ? null
                    : () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          if (!_codeSent) {
                            final success = await ref
                                .read(profileControllerProvider.notifier)
                                .updateEmail(_emailController.text.trim());
                            if (success && context.mounted) {
                              setState(() => _codeSent = true);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Verification code sent to your new email!'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            } else if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Error sending code. Please try again.'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          } else {
                            final success = await ref
                                .read(profileControllerProvider.notifier)
                                .verifyEmailChange(
                                  newEmail: _emailController.text.trim(),
                                  token: _codeController.text.trim(),
                                );
                            if (success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Email updated successfully!'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                              context.go(RoutePaths.profile);
                            } else if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Verification failed. Please check the code.'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: isLoading
                    ? const FlickrLoader(size: 8, distance: 10)
                    : Text(
                        _codeSent ? 'Verify and Update' : 'Send Verification Code',
                        style: AppTextStyles.titleLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo({double size = 40}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/logos/vouch.webp', width: size, height: size),
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
    TextInputType? keyboardType,
    int? maxLength,
    TextAlign textAlign = TextAlign.start,
    FormFieldValidator<String>? validator,
    bool enabled = true,
    Widget? suffixIcon,
    String? errorText,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      textAlign: textAlign,
      enabled: enabled,
      decoration: InputDecoration(
        hintText: hintText,
        errorText: errorText,
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
      validator: validator ?? ((val) => val == null || val.isEmpty ? 'Field required' : null),
    );
  }
}
