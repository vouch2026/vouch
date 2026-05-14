import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../routes/route_paths.dart';
import '../../../routes/route_names.dart';
import '../controllers/auth_controller.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _nameController = TextEditingController();
  final _schoolIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // State
  String? _selectedFaculty;
  String? _selectedProgram;
  String? _selectedYearLevel;
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  // Mock data (as in sample)
  final List<String> _faculties = ['Faculty of Engineering', 'Faculty of Arts', 'Faculty of Science'];
  final Map<String, List<String>> _programs = {
    'Faculty of Engineering': ['BS Civil Engineering', 'BS Electrical Engineering'],
    'Faculty of Arts': ['BA Communication', 'BA Literature'],
    'Faculty of Science': ['BS Biology', 'BS Chemistry'],
  };

  @override
  void dispose() {
    _nameController.dispose();
    _schoolIdController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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
                if (constraints.maxWidth >= 1024) {
                  return _buildDesktopLayout(context);
                } else if (constraints.maxWidth >= 768) {
                  return _buildTabletLayout(context);
                } else {
                  return _buildMobileLayout(context);
                }
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

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xl),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: _buildRegisterFormCard(context, isDesktop: false),
        ),
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: _buildRegisterFormCard(context, isDesktop: false),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xxxl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLogo(size: 110),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Join Vouch and simplify your campus organization management.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xxxl),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: _buildRegisterFormCard(context, isDesktop: true),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogo({double size = 40}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/logos/vouch.png',
          width: size,
          height: size,
        ),
        const SizedBox(width: AppSpacing.sm),
        RichText(
          text: TextSpan(
            style: GoogleFonts.poppins(
              fontSize: size,
              fontWeight: FontWeight.w700,
            ),
            children: const [
              TextSpan(
                text: 'Vou',
                style: TextStyle(color: AppColors.primary),
              ),
              TextSpan(
                text: 'ch',
                style: TextStyle(color: AppColors.accent),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterFormCard(BuildContext context, {required bool isDesktop}) {
    final authState = ref.watch(authControllerProvider);
    final availablePrograms = _selectedFaculty == null ? <String>[] : (_programs[_selectedFaculty] ?? []);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1), width: 1.2),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isDesktop)
              Center(
                child: Column(
                  children: [
                    Text(
                      'Create your account',
                      style: AppTextStyles.displaySmall.copyWith(color: AppColors.primary),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Please fill in your details to get started',
                      style: AppTextStyles.bodyMedium.copyWith(color: Colors.black54),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: [
                  _buildLogo(size: 50),
                  const SizedBox(height: AppSpacing.xs),
                  Center(
                    child: Text(
                      'Create your account',
                      style: AppTextStyles.bodySmall.copyWith(color: Colors.black54),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: AppSpacing.xl),
            _buildLabel('Faculty'),
            _buildDropdown(
              hint: 'Select Faculty',
              value: _selectedFaculty,
              items: _faculties,
              onChanged: (val) => setState(() {
                _selectedFaculty = val;
                _selectedProgram = null;
              }),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildLabel('Program'),
            _buildDropdown(
              hint: _selectedFaculty == null ? 'Select Faculty first' : 'Select Program',
              value: _selectedProgram,
              items: availablePrograms,
              onChanged: availablePrograms.isEmpty ? null : (val) => setState(() => _selectedProgram = val),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildLabel('Year Level'),
            _buildDropdown(
              hint: 'Select Year Level',
              value: _selectedYearLevel,
              items: const ['1', '2', '3', '4', '5'],
              onChanged: (val) => setState(() => _selectedYearLevel = val),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildLabel('Full Name'),
            _buildTextField(
              controller: _nameController,
              hintText: 'Enter Full Name',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildLabel('School ID No.'),
            _buildTextField(
              controller: _schoolIdController,
              hintText: 'XXXX-XXXX',
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                _SchoolIdFormatter(),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _buildLabel('Email'),
            _buildTextField(
              controller: _emailController,
              hintText: 'Enter Email',
              icon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildLabel('Password'),
            _buildTextField(
              controller: _passwordController,
              hintText: 'Enter Password',
              icon: Icons.lock_outline,
              obscureText: !_showPassword,
              suffixIcon: IconButton(
                onPressed: () => setState(() => _showPassword = !_showPassword),
                icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off, color: AppColors.primary, size: 20),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildLabel('Confirm Password'),
            _buildTextField(
              controller: _confirmPasswordController,
              hintText: 'Re-enter Password',
              icon: Icons.lock_outline,
              obscureText: !_showConfirmPassword,
              suffixIcon: IconButton(
                onPressed: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
                icon: Icon(_showConfirmPassword ? Icons.visibility : Icons.visibility_off, color: AppColors.primary, size: 20),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: authState.isLoading
                    ? null
                    : () {
                        if (_formKey.currentState?.validate() ?? false) {
                          if (_passwordController.text != _confirmPasswordController.text) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Passwords do not match')),
                            );
                            return;
                          }
                          ref.read(authControllerProvider.notifier).signUp(
                                email: _emailController.text,
                                password: _passwordController.text,
                                fullName: _nameController.text,
                                schoolId: _schoolIdController.text,
                                faculty: _selectedFaculty ?? '',
                                program: _selectedProgram ?? '',
                                yearLevel: int.tryParse(_selectedYearLevel ?? '') ?? 0,
                              ).then((success) {
                                if (success && mounted) {
                                  context.goNamed(
                                    RouteNames.emailVerification,
                                    queryParameters: {'email': _emailController.text},
                                  );
                                }
                              });
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: authState.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      )
                    : Text(
                        'Sign Up',
                        style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Already have an account? ',
                    style: AppTextStyles.bodySmall.copyWith(color: Colors.black87),
                  ),
                  GestureDetector(
                    onTap: () => context.go(RoutePaths.login),
                    child: Text(
                      'Sign In',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: Text(
                '© ${DateTime.now().year} Vouch. All rights reserved.',
                style: AppTextStyles.labelSmall.copyWith(color: Colors.grey.shade400),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?>? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15), width: 1.5),
        borderRadius: BorderRadius.circular(14),
        color: AppColors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              hint,
              style: AppTextStyles.bodySmall.copyWith(color: Colors.grey.shade500),
            ),
          ),
          value: value,
          style: AppTextStyles.bodySmall,
          items: items.map((item) => DropdownMenuItem(value: item, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 14), child: Text(item)))).toList(),
          onChanged: onChanged,
          isExpanded: true,
          icon: const Padding(padding: EdgeInsets.only(right: 10), child: Icon(Icons.expand_more_rounded, color: AppColors.primary)),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    IconData? icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: icon == null ? null : Padding(
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
      validator: (val) => val == null || val.isEmpty ? 'Field required' : null,
    );
  }
}

class _SchoolIdFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final trimmed = digits.length > 8 ? digits.substring(0, 8) : digits;
    final formatted = trimmed.length <= 4 ? trimmed : '${trimmed.substring(0, 4)}-${trimmed.substring(4)}';
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
