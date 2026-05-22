import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../campuses/providers/campus_provider.dart';
import '../../../campuses/models/campus_model.dart';
import '../../../faculties/providers/faculty_provider.dart';
import '../../../faculties/models/faculty_model.dart';
import '../../../programs/providers/program_provider.dart';
import '../../../programs/models/program_model.dart';
import '../../controllers/user_controller.dart';

class CreateUserModal extends ConsumerStatefulWidget {
  const CreateUserModal({super.key});

  @override
  ConsumerState<CreateUserModal> createState() => _CreateUserModalState();
}

class _CreateUserModalState extends ConsumerState<CreateUserModal> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _idController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  String _selectedRole = 'student';
  String? _selectedCampusId;
  String? _selectedFacultyId;
  String? _selectedProgramId;
  String? _selectedYearLevel;
  String _position = 'instructor';
  
  XFile? _idFrontImage;
  XFile? _idBackImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _idController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final campusesAsync = ref.watch(campusesProvider);
    final facultiesAsync = _selectedCampusId != null
        ? ref.watch(facultiesByCampusProvider(_selectedCampusId!))
        : const AsyncValue<List<FacultyModel>>.data([]);
    final programsAsync = _selectedFacultyId != null 
        ? ref.watch(programsByFacultyProvider(_selectedFacultyId!))
        : const AsyncValue<List<ProgramModel>>.data([]);
    final userController = ref.watch(userControllerProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 700,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: AppSpacing.xl),
              
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRoleSelector(),
                      const SizedBox(height: AppSpacing.lg),
                      
                      const Divider(),
                      const SizedBox(height: AppSpacing.lg),

                      _buildPersonalInfo(),
                      const SizedBox(height: AppSpacing.md),
                      
                      _buildContactInfo(),
                      const SizedBox(height: AppSpacing.md),
                      
                      _buildPasswordInfo(),
                      const SizedBox(height: AppSpacing.md),
                      
                      _buildCampusField(campusesAsync),
                      const SizedBox(height: AppSpacing.md),
                      
                      if (_selectedRole == 'student') _buildStudentFields(facultiesAsync, programsAsync),
                      if (_selectedRole != 'student') _buildFacultyFields(facultiesAsync, programsAsync),
                      
                      const SizedBox(height: AppSpacing.lg),
                      _buildIdVerification(),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: AppSpacing.xl),
              _buildActionButtons(userController.isLoading),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCampusField(AsyncValue<List<CampusModel>> campusesAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Campus'),
        campusesAsync.when(
          data: (campuses) => DropdownButtonFormField<String>(
            value: _selectedCampusId,
            isExpanded: true,
            items: campuses.map((c) => DropdownMenuItem(
              value: c.id, 
              child: Text(c.name, overflow: TextOverflow.ellipsis),
            )).toList(),
            onChanged: (v) => setState(() {
              _selectedCampusId = v;
              _selectedFacultyId = null;
              _selectedProgramId = null;
            }),
            decoration: const InputDecoration(hintText: 'Select Campus'),
            validator: (v) => v == null ? 'Required' : null,
          ),
          loading: () => const LinearProgressIndicator(),
          error: (_, __) => const Text('Error loading campuses'),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Create New User', style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
            Text('Register and automatically activate a new account', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey)),
          ],
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close_rounded),
        ),
      ],
    );
  }

  Widget _buildRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('User Role'),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'student', label: Text('Student'), icon: Icon(Icons.person_outline)),
            ButtonSegment(value: 'faculty', label: Text('Faculty/Staff'), icon: Icon(Icons.school_outlined)),
            ButtonSegment(value: 'super_admin', label: Text('Admin'), icon: Icon(Icons.admin_panel_settings_outlined)),
          ],
          selected: {_selectedRole},
          onSelectionChanged: (Set<String> newSelection) {
            setState(() {
              _selectedRole = newSelection.first;
              if (_selectedRole != 'student') {
                _selectedProgramId = null;
                _selectedYearLevel = null;
              }
            });
          },
        ),
      ],
    );
  }

  Widget _buildPersonalInfo() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('First Name'),
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(hintText: 'e.g. Juan'),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
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
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(hintText: 'e.g. Dela Cruz'),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactInfo() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Institutional Email'),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(hintText: 'e.g. name@dorsu.edu.ph'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v?.isEmpty ?? true) return 'Required';
                  if (!v!.contains('@')) return 'Invalid email';
                  return null;
                },
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel(_selectedRole == 'student' ? 'Student ID' : 'Employee ID'),
              TextFormField(
                controller: _idController,
                decoration: InputDecoration(hintText: _selectedRole == 'student' ? '2022-00123' : 'INS-123'),
                inputFormatters: _selectedRole == 'student' ? [_SchoolIdFormatter()] : [],
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Initial Password'),
        TextFormField(
          controller: _passwordController,
          decoration: const InputDecoration(
            hintText: 'Set a temporary password',
            prefixIcon: Icon(Icons.lock_outline, size: 18),
          ),
          obscureText: true,
          validator: (v) => (v?.length ?? 0) < 6 ? 'Min 6 characters' : null,
        ),
      ],
    );
  }

  Widget _buildStudentFields(AsyncValue<List<FacultyModel>> facultiesAsync, AsyncValue<List<ProgramModel>> programsAsync) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Faculty'),
                  facultiesAsync.when(
                    data: (faculties) => DropdownButtonFormField<String>(
                      value: _selectedFacultyId,
                      isExpanded: true,
                      items: faculties.map((f) => DropdownMenuItem(
                        value: f.id, 
                        child: Text(f.name, overflow: TextOverflow.ellipsis),
                      )).toList(),
                      onChanged: _selectedCampusId == null ? null : (v) => setState(() {
                        _selectedFacultyId = v;
                        _selectedProgramId = null;
                      }),
                      decoration: const InputDecoration(hintText: 'Select Faculty'),
                      validator: (v) => v == null ? 'Required' : null,
                      disabledHint: const Text('Select a Campus first'),
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const Text('Error loading faculties'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Year Level'),
                  DropdownButtonFormField<String>(
                    value: _selectedYearLevel,
                    isExpanded: true,
                    items: ['1', '2', '3', '4', '5'].map((y) => DropdownMenuItem(
                      value: y, 
                      child: Text('$y Year', overflow: TextOverflow.ellipsis),
                    )).toList(),
                    onChanged: (val) => setState(() => _selectedYearLevel = val),
                    decoration: const InputDecoration(hintText: 'Select'),
                    validator: (v) => v == null ? 'Required' : null,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _buildLabel('Program'),
        programsAsync.when(
          data: (programs) => DropdownButtonFormField<String>(
            value: _selectedProgramId,
            isExpanded: true,
            items: programs.map((p) => DropdownMenuItem(
              value: p.id!, 
              child: Text(p.name, overflow: TextOverflow.ellipsis),
            )).toList(),
            onChanged: (v) => setState(() => _selectedProgramId = v),
            decoration: const InputDecoration(hintText: 'Select Program'),
            validator: (v) => v == null ? 'Required' : null,
            disabledHint: const Text('Select a Faculty first'),
          ),
          loading: () => const LinearProgressIndicator(),
          error: (_, __) => const Text('Error loading programs'),
        ),
      ],
    );
  }

  Widget _buildFacultyFields(AsyncValue<List<FacultyModel>> facultiesAsync, AsyncValue<List<ProgramModel>> programsAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Faculty Assignment'),
                  facultiesAsync.when(
                    data: (faculties) => DropdownButtonFormField<String>(
                      value: _selectedFacultyId,
                      isExpanded: true,
                      items: faculties.map((f) => DropdownMenuItem(
                        value: f.id, 
                        child: Text(f.name, overflow: TextOverflow.ellipsis),
                      )).toList(),
                      onChanged: _selectedCampusId == null ? null : (v) => setState(() {
                        _selectedFacultyId = v;
                        _selectedProgramId = null;
                      }),
                      decoration: const InputDecoration(hintText: 'Select Faculty'),
                      validator: (v) => v == null ? 'Required' : null,
                      disabledHint: const Text('Select a Campus first'),
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const Text('Error loading faculties'),
                  ),
                ],
              ),
            ),
            if (_selectedRole == 'faculty') ...[
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Position'),
                    DropdownButtonFormField<String>(
                      value: _position,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: 'instructor', child: Text('Instructor', overflow: TextOverflow.ellipsis)),
                        DropdownMenuItem(value: 'dean', child: Text('Dean', overflow: TextOverflow.ellipsis)),
                        DropdownMenuItem(value: 'program_head', child: Text('Program Head', overflow: TextOverflow.ellipsis)),
                      ],
                      onChanged: (val) => setState(() {
                        _position = val!;
                        if (_position == 'dean') {
                          _selectedProgramId = null;
                        }
                      }),
                      decoration: const InputDecoration(hintText: 'Select Position'),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        if (_selectedRole == 'faculty' && _position != 'dean') ...[
          const SizedBox(height: AppSpacing.md),
          _buildLabel('Program Assignment'),
          programsAsync.when(
            data: (programs) => DropdownButtonFormField<String>(
              value: _selectedProgramId,
              isExpanded: true,
              items: programs.map((p) => DropdownMenuItem(
                value: p.id!, 
                child: Text(p.name, overflow: TextOverflow.ellipsis),
              )).toList(),
              onChanged: (v) => setState(() => _selectedProgramId = v),
              decoration: const InputDecoration(hintText: 'Select Program'),
              validator: (v) => v == null ? 'Required' : null,
              disabledHint: const Text('Select a Faculty first'),
            ),
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const Text('Error loading programs'),
          ),
        ],
      ],
    );
  }

  Widget _buildIdVerification() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('ID Verification (Optional for Admin-added)'),
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
      ],
    );
  }

  Widget _buildImagePicker({
    required String label,
    required XFile? image,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border, width: 1.5),
          borderRadius: BorderRadius.circular(12),
          color: AppColors.background,
        ),
        child: image != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: Image.file(
                  File(image.path),
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_a_photo_outlined, color: AppColors.textGrey),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.textGrey),
                  ),
                ],
              ),
      ),
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

  Widget _buildActionButtons(bool isLoading) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: AppSpacing.md),
        FilledButton.icon(
          onPressed: isLoading ? null : _handleCreate,
          icon: isLoading 
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.check_rounded, size: 18),
          label: Text(isLoading ? 'Creating...' : 'Create & Activate'),
        ),
      ],
    );
  }

  Future<void> _handleCreate() async {
    if (_formKey.currentState!.validate()) {
      final success = await ref.read(userControllerProvider.notifier).createUser(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        schoolId: _idController.text.trim(),
        campusId: _selectedCampusId,
        facultyId: _selectedFacultyId,
        programId: _selectedProgramId,
        yearLevel: int.tryParse(_selectedYearLevel ?? '') ?? 0,
        role: _selectedRole,
        position: _selectedRole == 'faculty' ? _position : null,
        idFront: _idFrontImage != null ? File(_idFrontImage!.path) : null,
        idBack: _idBackImage != null ? File(_idBackImage!.path) : null,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User created and activated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
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
