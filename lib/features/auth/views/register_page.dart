import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../routes/route_paths.dart';
import '../../../routes/route_names.dart';
import '../controllers/auth_controller.dart';
import '../../faculties/providers/faculty_provider.dart';
import '../../programs/providers/program_provider.dart';
import '../../faculties/models/faculty_model.dart';
import '../../programs/models/program_model.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _schoolIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // State
  String? _selectedFacultyId;
  String? _selectedProgramId;
  String? _selectedYearLevel;
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  
  XFile? _idFrontImage;
  XFile? _idBackImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
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
    final facultiesAsync = ref.watch(facultiesProvider);
    final programsAsync = _selectedFacultyId != null 
        ? ref.watch(programsByFacultyProvider(_selectedFacultyId!))
        : const AsyncValue<List<ProgramModel>>.data([]);

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
            facultiesAsync.when(
              data: (faculties) => _buildDropdown<String>(
                hint: 'Select Faculty',
                value: _selectedFacultyId,
                items: faculties.map((f) => DropdownMenuItem(
                  value: f.id,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text(f.name),
                  ),
                )).toList(),
                onChanged: (val) => setState(() {
                  _selectedFacultyId = val;
                  _selectedProgramId = null;
                }),
              ),
              loading: () => _buildDropdownPlaceholder('Loading faculties...'),
              error: (e, _) => _buildDropdownPlaceholder('Error loading faculties'),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildLabel('Program'),
            programsAsync.when(
              data: (programs) => _buildDropdown<String>(
                hint: _selectedFacultyId == null ? 'Select Faculty first' : 'Select Program',
                value: _selectedProgramId,
                items: programs.map((p) => DropdownMenuItem(
                  value: p.id,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text(p.name),
                  ),
                )).toList(),
                onChanged: _selectedFacultyId == null ? null : (val) => setState(() => _selectedProgramId = val),
              ),
              loading: () => _buildDropdownPlaceholder('Loading programs...'),
              error: (e, _) => _buildDropdownPlaceholder('Error loading programs'),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildLabel('Year Level'),
            _buildDropdown<String>(
              hint: 'Select Year Level',
              value: _selectedYearLevel,
              items: const ['1', '2', '3', '4', '5'].map((y) => DropdownMenuItem(
                value: y,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Text(y),
                ),
              )).toList(),
              onChanged: (val) => setState(() => _selectedYearLevel = val),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('First Name'),
                      _buildTextField(
                        controller: _firstNameController,
                        hintText: 'First Name',
                        icon: Icons.person_outline,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Last Name'),
                      _buildTextField(
                        controller: _lastNameController,
                        hintText: 'Last Name',
                        icon: Icons.person_outline,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _buildLabel('ID No.'),
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
            _buildLabel('ID Verification'),
            Row(
              children: [
                Expanded(
                  child: _buildImagePicker(
                    label: 'ID Front',
                    image: _idFrontImage,
                    onTap: () => _pickImage(true),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildImagePicker(
                    label: 'ID Back',
                    image: _idBackImage,
                    onTap: () => _pickImage(false),
                  ),
                ),
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
                          if (_idFrontImage == null || _idBackImage == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please upload both ID front and back pictures')),
                            );
                            return;
                          }
                          if (_selectedFacultyId == null || _selectedProgramId == null || _selectedYearLevel == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please select faculty, program, and year level')),
                            );
                            return;
                          }

                          ref.read(authControllerProvider.notifier).signUp(
                                email: _emailController.text,
                                password: _passwordController.text,
                                firstName: _firstNameController.text,
                                lastName: _lastNameController.text,
                                schoolId: _schoolIdController.text,
                                facultyId: _selectedFacultyId ?? '',
                                programId: _selectedProgramId ?? '',
                                yearLevel: int.tryParse(_selectedYearLevel ?? '') ?? 0,
                                idFront: File(_idFrontImage!.path),
                                idBack: File(_idBackImage!.path),
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

  Widget _buildDropdownPlaceholder(String hint) {
    return _buildDropdown<String>(
      hint: hint,
      value: null,
      items: [],
      onChanged: null,
    );
  }

  Widget _buildDropdown<T>({
    required String hint,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?>? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15), width: 1.5),
        borderRadius: BorderRadius.circular(14),
        color: AppColors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          hint: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              hint,
              style: AppTextStyles.bodySmall.copyWith(color: Colors.grey.shade500),
            ),
          ),
          value: value,
          style: AppTextStyles.bodySmall,
          items: items,
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

  Future<void> _pickImage(bool isFront) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (isFront) {
          _idFrontImage = image;
        } else {
          _idBackImage = image;
        }
      });
    }
  }

  Widget _buildImagePicker({
    required String label,
    required XFile? image,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.15), width: 1.5),
          borderRadius: BorderRadius.circular(14),
          color: AppColors.white,
        ),
        child: image != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(image.path),
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_a_photo_outlined, color: AppColors.primary),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: AppTextStyles.labelSmall.copyWith(color: Colors.grey.shade600),
                  ),
                ],
              ),
      ),
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
