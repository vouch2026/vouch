import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../routes/route_paths.dart';
import '../controllers/auth_controller.dart';
import '../../../core/widgets/loaders/flickr_loader.dart';
import '../../../core/utils/validators.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _codeSent = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onFieldChanged);
    _codeController.addListener(_onFieldChanged);
    _newPasswordController.addListener(_onFieldChanged);
    _confirmPasswordController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isPasswordComplexityMet(String password) {
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasNumber = password.contains(RegExp(r'[0-9]'));
    final hasSpecial = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    
    int categoriesMet = 0;
    if (hasUppercase) categoriesMet++;
    if (hasLowercase) categoriesMet++;
    if (hasNumber) categoriesMet++;
    if (hasSpecial) categoriesMet++;
    
    return categoriesMet >= 3;
  }

  bool get _isFormValid {
    final isEmailValid = Validators.email(_emailController.text) == null;
    if (!_codeSent) {
      return isEmailValid;
    }
    
    final isCodeValid = _codeController.text.trim().length == 8;
    final isNewPasswordValid = _newPasswordController.text.length >= 12 &&
        _isPasswordComplexityMet(_newPasswordController.text);
    final isConfirmPasswordValid = _newPasswordController.text == _confirmPasswordController.text;
    
    return isEmailValid && isCodeValid && isNewPasswordValid && isConfirmPasswordValid;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(
      authControllerProvider,
      (previous, next) {
        next.whenOrNull(
          error: (error, stackTrace) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(error.toString())),
            );
          },
        );
      },
    );

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
      child: Form(
        key: _formKey,
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
              _codeSent
                  ? 'Verify your OTP code and set your new password'
                  : 'Get an 8-digit code to set your new password',
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            _buildTextField(
              controller: _emailController,
              hintText: 'Enter your email',
              icon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
              enabled: !_codeSent,
              validator: Validators.email,
            ),
            const SizedBox(height: AppSpacing.md),
            if (!_codeSent)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: (authState.isLoading || !_isFormValid)
                      ? null
                      : () {
                          if (_formKey.currentState?.validate() ?? false) {
                            ref
                                .read(authControllerProvider.notifier)
                                .sendPasswordReset(_emailController.text)
                                .then((success) {
                              if (success && context.mounted) {
                                setState(() => _codeSent = true);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Verification code sent to your email.'),
                                  ),
                                );
                              }
                            });
                          }
                        },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.primary.withValues(alpha: 0.25)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: authState.isLoading
                      ? const FlickrLoader(size: 6, distance: 8)
                      : const Text('Send Code'),
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
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Code is required';
                  if (val.trim().length != 8) return 'Enter the 8-digit code';
                  return null;
                },
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
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Field required';
                  final hasUppercase = val.contains(RegExp(r'[A-Z]'));
                  final hasLowercase = val.contains(RegExp(r'[a-z]'));
                  final hasNumber = val.contains(RegExp(r'[0-9]'));
                  final hasSpecial = val.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
                  final hasMinLength = val.length >= 12;

                  int categoriesMet = 0;
                  if (hasUppercase) categoriesMet++;
                  if (hasLowercase) categoriesMet++;
                  if (hasNumber) categoriesMet++;
                  if (hasSpecial) categoriesMet++;

                  if (!hasMinLength) {
                    return 'Password must be at least 12 characters';
                  }
                  if (categoriesMet < 3) {
                    return 'Password must include uppercase, lowercase, numbers, or symbols';
                  }
                  return null;
                },
              ),
              Builder(
                builder: (context) {
                  final password = _newPasswordController.text;
                  final hasUppercase = password.contains(RegExp(r'[A-Z]'));
                  final hasLowercase = password.contains(RegExp(r'[a-z]'));
                  final hasNumber = password.contains(RegExp(r'[0-9]'));
                  final hasSpecial = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
                  final hasMinLength = password.length >= 12;

                  int categoriesMet = 0;
                  if (hasUppercase) categoriesMet++;
                  if (hasLowercase) categoriesMet++;
                  if (hasNumber) categoriesMet++;
                  if (hasSpecial) categoriesMet++;

                  final isComplexityMet = categoriesMet >= 3;
                  final isFullyMet = hasMinLength && isComplexityMet;

                  if (isFullyMet || password.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return Padding(
                    padding: const EdgeInsets.only(top: 8, left: 4, right: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Password Requirements:',
                          style: AppTextStyles.labelSmall.copyWith(color: AppColors.textGrey, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildRequirementItem('At least 12 characters', hasMinLength),
                            const SizedBox(height: 6),
                            _buildRequirementItem('Include at least 3 of the following:', isComplexityMet),
                            Padding(
                              padding: const EdgeInsets.only(left: 20, top: 6),
                              child: Wrap(
                                spacing: AppSpacing.md,
                                runSpacing: AppSpacing.xs,
                                children: [
                                  _buildSubRequirementItem('Uppercase', hasUppercase),
                                  _buildSubRequirementItem('Lowercase', hasLowercase),
                                  _buildSubRequirementItem('Number', hasNumber),
                                  _buildSubRequirementItem('Special Symbol', hasSpecial),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }
              ),
              const SizedBox(height: AppSpacing.md),
              _buildTextField(
                controller: _confirmPasswordController,
                hintText: 'Retype new password',
                icon: Icons.lock_outline,
                obscureText: !_showConfirmPassword,
                errorText: (_confirmPasswordController.text.isNotEmpty &&
                        _confirmPasswordController.text != _newPasswordController.text)
                    ? 'Passwords do not match'
                    : null,
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
                  icon: Icon(_showConfirmPassword ? Icons.visibility : Icons.visibility_off, color: Colors.grey.shade600, size: 20),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Field required';
                  if (val != _newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: (authState.isLoading || !_isFormValid)
                      ? null
                      : () {
                          if (_formKey.currentState?.validate() ?? false) {
                            ref
                                .read(authControllerProvider.notifier)
                                .resetPassword(
                                  email: _emailController.text,
                                  token: _codeController.text,
                                  newPassword: _newPasswordController.text,
                                )
                                .then((success) {
                              if (success && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Password updated successfully! Please login.'),
                                  ),
                                );
                                context.go(RoutePaths.login);
                              }
                            });
                          }
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

  Widget _buildRequirementItem(String text, bool isMet) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isMet ? Icons.check_circle_rounded : Icons.circle_outlined,
          color: isMet ? AppColors.success : AppColors.textGrey.withValues(alpha: 0.4),
          size: 14,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: AppTextStyles.labelMedium.copyWith(
            color: isMet ? AppColors.textDark : AppColors.textGrey,
            fontWeight: isMet ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildSubRequirementItem(String text, bool isMet) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isMet ? Icons.check : Icons.circle_outlined,
          color: isMet ? AppColors.success : AppColors.textGrey.withValues(alpha: 0.4),
          size: 11,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: AppTextStyles.bodySmall.copyWith(
            color: isMet ? AppColors.textDark : AppColors.textGrey,
            fontWeight: isMet ? FontWeight.bold : FontWeight.normal,
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
    FormFieldValidator<String>? validator,
    bool enabled = true,
    String? errorText,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
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
