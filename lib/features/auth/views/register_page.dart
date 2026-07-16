import 'package:flutter/foundation.dart';
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
import '../../../core/widgets/loaders/flickr_loader.dart';
import '../../campuses/providers/campus_provider.dart';
import '../../campuses/models/campus_model.dart';
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
  String? _selectedCampusId;
  String? _selectedFacultyId;
  String? _selectedProgramId;
  String? _selectedYearLevel;
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_onPasswordChanged);
  }

  void _onPasswordChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _passwordController.removeListener(_onPasswordChanged);
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
    final campusesAsync = ref.watch(campusesProvider);
    final facultiesAsync = _selectedCampusId != null
        ? ref.watch(facultiesByCampusProvider(_selectedCampusId!))
        : const AsyncValue<List<FacultyModel>>.data([]);
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
            _buildLabel('Campus'),
            campusesAsync.when(
              data: (campuses) => _buildDropdown<String>(
                hint: 'Select Campus',
                value: _selectedCampusId,
                items: campuses.map((c) => DropdownItem(
                  value: c.id,
                  label: c.name,
                )).toList(),
                onChanged: (val) => setState(() {
                  _selectedCampusId = val;
                  _selectedFacultyId = null;
                  _selectedProgramId = null;
                }),
              ),
              loading: () => _buildDropdownPlaceholder('Loading campuses...'),
              error: (e, _) => _buildDropdownPlaceholder('Error loading campuses'),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildLabel('Faculty'),
            facultiesAsync.when(
              data: (faculties) => _buildDropdown<String>(
                key: ValueKey('faculty_$_selectedCampusId'),
                hint: _selectedCampusId == null ? 'Select Campus first' : 'Select Faculty',
                value: _selectedFacultyId,
                items: faculties.map((f) => DropdownItem(
                  value: f.id,
                  label: f.name,
                )).toList(),
                onChanged: _selectedCampusId == null ? null : (val) => setState(() {
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
                key: ValueKey('program_$_selectedFacultyId'),
                hint: _selectedFacultyId == null ? 'Select Faculty first' : 'Select Program',
                value: _selectedProgramId,
                items: programs.map((p) => DropdownItem(
                  value: p.id,
                  label: p.name,
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
              items: const ['1', '2', '3', '4', '5'].map((y) => DropdownItem(
                value: y,
                label: y,
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
                  return 'Password must be at least 12 characters long';
                }
                if (categoriesMet < 3) {
                  return 'Password must meet at least 3 complexity categories';
                }
                return null;
              },
            ),
            Builder(
              builder: (context) {
                final password = _passwordController.text;
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

                if (isFullyMet) {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 8, left: 4, right: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Password must contain:',
                        style: AppTextStyles.labelSmall.copyWith(color: AppColors.textGrey, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildRequirementItem('Minimum of 12 characters', hasMinLength),
                          const SizedBox(height: 6),
                          _buildRequirementItem('At least 3 of these categories (Current: $categoriesMet/4):', isComplexityMet),
                          Padding(
                            padding: const EdgeInsets.only(left: 20, top: 6),
                            child: Wrap(
                              spacing: AppSpacing.md,
                              runSpacing: AppSpacing.xs,
                              children: [
                                _buildSubRequirementItem('Uppercase', hasUppercase),
                                _buildSubRequirementItem('Lowercase', hasLowercase),
                                _buildSubRequirementItem('Number', hasNumber),
                                _buildSubRequirementItem('Special Character', hasSpecial),
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
                          if (_selectedCampusId == null || _selectedFacultyId == null || _selectedProgramId == null || _selectedYearLevel == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please select campus, faculty, program, and year level')),
                            );
                            return;
                          }

                          ref.read(authControllerProvider.notifier).signUp(
                                email: _emailController.text,
                                password: _passwordController.text,
                                firstName: _firstNameController.text,
                                lastName: _lastNameController.text,
                                schoolId: _schoolIdController.text,
                                campusId: _selectedCampusId ?? '',
                                facultyId: _selectedFacultyId ?? '',
                                programId: _selectedProgramId ?? '',
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
                    ? const FlickrLoader(
                        size: 8,
                        distance: 10,
                      )
                    : Text(
                        'Sign Up',
                        style: AppTextStyles.titleLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
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
                '© ${DateTime.now().year} Vouch SoftTech Services. All rights reserved.',
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
          style: AppTextStyles.labelSmall.copyWith(
            color: isMet ? AppColors.textDark : AppColors.textGrey,
            fontWeight: isMet ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
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
    Key? key,
    required String hint,
    required T? value,
    required List<DropdownItem<T>> items,
    required ValueChanged<T?>? onChanged,
  }) {
    return CustomConnectedDropdown<T>(
      key: key,
      hint: hint,
      value: value,
      items: items,
      onChanged: onChanged,
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
    FormFieldValidator<String>? validator,
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
      validator: validator ?? ((val) => val == null || val.isEmpty ? 'Field required' : null),
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

class DropdownItem<T> {
  final T value;
  final String label;

  const DropdownItem({required this.value, required this.label});
}

class CustomConnectedDropdown<T> extends StatefulWidget {
  final String hint;
  final T? value;
  final List<DropdownItem<T>> items;
  final ValueChanged<T?>? onChanged;

  const CustomConnectedDropdown({
    super.key,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  State<CustomConnectedDropdown<T>> createState() => _CustomConnectedDropdownState<T>();
}

class _CustomConnectedDropdownState<T> extends State<CustomConnectedDropdown<T>> {
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _buttonKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  bool _isDropdownOpen = false;
  ScrollPosition? _scrollPosition;

  void _openDropdown() {
    if (_isDropdownOpen || widget.onChanged == null) return;

    final renderBox = _buttonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final width = renderBox.size.width;

    // Calculate position and available height to prevent overextending past screen bottom
    final position = renderBox.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;
    final availableHeight = screenHeight - position.dy - renderBox.size.height - 16;
    final maxHeight = availableHeight.clamp(80.0, 250.0);

    // Register scroll listener to dismiss dropdown on parent scroll
    final scrollable = Scrollable.maybeOf(context);
    if (scrollable != null) {
      _scrollPosition = scrollable.position;
      _scrollPosition?.addListener(_closeDropdown);
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Translucent tap barrier to close the dropdown on outer clicks
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _closeDropdown,
            child: const SizedBox.expand(),
          ),
          CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            targetAnchor: Alignment.bottomLeft,
            followerAnchor: Alignment.topLeft,
            offset: const Offset(0, -1.5), // Offset to overlap borders seamlessly
            child: Material(
              color: Colors.transparent,
              child: _DropdownMenu<T>(
                items: widget.items,
                selectedValue: widget.value,
                width: width,
                maxHeight: maxHeight,
                onSelected: (val) {
                  _closeDropdown();
                  widget.onChanged?.call(val);
                },
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isDropdownOpen = true;
    });
  }

  void _closeDropdown() {
    if (!_isDropdownOpen) return;
    _overlayEntry?.remove();
    _overlayEntry = null;
    _scrollPosition?.removeListener(_closeDropdown);
    _scrollPosition = null;
    if (mounted) {
      setState(() {
        _isDropdownOpen = false;
      });
    }
  }

  void _toggleDropdown() {
    if (_isDropdownOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  @override
  void dispose() {
    _scrollPosition?.removeListener(_closeDropdown);
    _overlayEntry?.remove();
    _overlayEntry = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onChanged != null;
    final selectedItem = widget.items.cast<DropdownItem<T>?>().firstWhere(
          (item) => item?.value == widget.value,
          orElse: () => null,
        );

    Color borderColor;
    double borderWidth;
    if (!isEnabled) {
      borderColor = AppColors.border.withValues(alpha: 0.5);
      borderWidth = 1.0;
    } else if (_isDropdownOpen) {
      borderColor = AppColors.primary;
      borderWidth = 1.5;
    } else {
      borderColor = AppColors.border;
      borderWidth = 1.0;
    }

    final borderRadius = _isDropdownOpen
        ? const BorderRadius.only(
            topLeft: Radius.circular(AppSpacing.radiusMd),
            topRight: Radius.circular(AppSpacing.radiusMd),
          )
        : BorderRadius.circular(AppSpacing.radiusMd);

    final borderSide = BorderSide(
      color: borderColor,
      width: borderWidth,
    );

    final decoration = InputDecoration(
      hintText: widget.hint,
      suffixIcon: Icon(
        Icons.expand_more_rounded,
        color: isEnabled ? AppColors.primary : AppColors.textGrey,
      ),
      filled: true,
      fillColor: isEnabled ? AppColors.white : Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      border: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: borderSide,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: borderSide,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: borderSide,
      ),
    );

    return CompositedTransformTarget(
      link: _layerLink,
      child: Material(
        key: _buttonKey,
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? _toggleDropdown : null,
          borderRadius: borderRadius,
          child: InputDecorator(
            decoration: decoration,
            isEmpty: selectedItem == null,
            child: selectedItem != null
                ? Text(
                    selectedItem.label,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isEnabled ? AppColors.textDark : AppColors.textGrey,
                    ),
                    overflow: TextOverflow.ellipsis,
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

class _DropdownMenu<T> extends StatefulWidget {
  final List<DropdownItem<T>> items;
  final T? selectedValue;
  final double width;
  final double maxHeight;
  final ValueChanged<T> onSelected;

  const _DropdownMenu({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.width,
    required this.maxHeight,
    required this.onSelected,
  });

  @override
  State<_DropdownMenu<T>> createState() => _DropdownMenuState<T>();
}

class _DropdownMenuState<T> extends State<_DropdownMenu<T>> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _slideAnimation = Tween<double>(begin: -8, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutQuad),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {}, // Consume taps inside the dropdown card
        child: Container(
          width: widget.width,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(AppSpacing.radiusMd),
              bottomRight: Radius.circular(AppSpacing.radiusMd),
            ),
            border: Border.all(
              color: AppColors.primary,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(AppSpacing.radiusMd - 1.5),
              bottomRight: Radius.circular(AppSpacing.radiusMd - 1.5),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: widget.maxHeight),
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: widget.items.length,
                itemBuilder: (context, index) {
                  final item = widget.items[index];
                  final isSelected = item.value == widget.selectedValue;

                  return InkWell(
                    onTap: () => widget.onSelected(item.value),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.md,
                      ),
                      color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : Colors.transparent,
                      child: Text(
                        item.label,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isSelected ? AppColors.primary : AppColors.textDark,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
