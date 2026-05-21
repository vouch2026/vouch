import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../campuses/providers/campus_provider.dart';
import '../../../faculties/providers/faculty_provider.dart';
import '../../../programs/providers/program_provider.dart';
import '../../controllers/organization_controller.dart';

class OrganizationCreationModal extends ConsumerStatefulWidget {
  const OrganizationCreationModal({super.key});

  @override
  ConsumerState<OrganizationCreationModal> createState() => _OrganizationCreationModalState();
}

class _OrganizationCreationModalState extends ConsumerState<OrganizationCreationModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedType = 'campus-based';
  String? _selectedCampusId;
  String? _selectedFacultyId;
  final List<String> _selectedProgramIds = [];

  XFile? _logoImage;
  XFile? _bannerImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isLogo) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (isLogo) {
          _logoImage = image;
        } else {
          _bannerImage = image;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(
      organizationControllerProvider,
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

    final campusesAsync = ref.watch(campusesProvider);
    final facultiesAsync = _selectedCampusId != null 
        ? ref.watch(facultiesByCampusProvider(_selectedCampusId!))
        : const AsyncValue<List<dynamic>>.data([]);
    final programsAsync = _selectedFacultyId != null
        ? ref.watch(programsByFacultyProvider(_selectedFacultyId!))
        : const AsyncValue<List<dynamic>>.data([]);
    final organizationState = ref.watch(organizationControllerProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Create New Organization', style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                
                _buildFieldLabel('Organization Type'),
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  items: [
                    {'value': 'campus-based', 'label': 'Campus-based'},
                    {'value': 'faculty-based', 'label': 'Faculty-based'},
                    {'value': 'program-based', 'label': 'Program-based'},
                  ].map((e) => DropdownMenuItem<String>(
                    value: e['value'], 
                    child: Text(e['label']!)
                  )).toList(),
                  onChanged: (val) => setState(() {
                    _selectedType = val!;
                    _selectedFacultyId = null;
                    _selectedProgramIds.clear();
                  }),
                ),
                const SizedBox(height: AppSpacing.md),

                _buildFieldLabel('Organization Name'),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(hintText: 'Enter full organization name'),
                  validator: (val) => val == null || val.isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                
                _buildFieldLabel('Organization Code'),
                TextFormField(
                  controller: _codeController,
                  decoration: const InputDecoration(hintText: 'e.g. GDSC-VOUCH'),
                  validator: (val) => val == null || val.isEmpty ? 'Code is required' : null,
                ),
                const SizedBox(height: AppSpacing.md),

                // Dynamic Fields based on Type
                _buildFieldLabel('Campus'),
                campusesAsync.when(
                  data: (campuses) => DropdownButtonFormField<String>(
                    value: _selectedCampusId,
                    items: campuses.map((c) => DropdownMenuItem<String>(value: c.id, child: Text(c.name))).toList(),
                    onChanged: (val) => setState(() {
                      _selectedCampusId = val;
                      _selectedFacultyId = null;
                      _selectedProgramIds.clear();
                    }),
                    validator: (val) => val == null ? 'Campus is required' : null,
                    decoration: const InputDecoration(hintText: 'Select Campus'),
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const Text('Error loading campuses'),
                ),

                if (_selectedType == 'faculty-based' || _selectedType == 'program-based') ...[
                  const SizedBox(height: AppSpacing.md),
                  _buildFieldLabel('Faculty'),
                  facultiesAsync.when(
                    data: (faculties) => DropdownButtonFormField<String>(
                      value: _selectedFacultyId,
                      items: faculties.map((f) => DropdownMenuItem<String>(value: f.id, child: Text(f.name))).toList(),
                      onChanged: (val) => setState(() {
                        _selectedFacultyId = val;
                        _selectedProgramIds.clear();
                      }),
                      validator: (val) => val == null ? 'Faculty is required' : null,
                      decoration: const InputDecoration(hintText: 'Select Faculty'),
                      disabledHint: const Text('Select a Campus first'),
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const Text('Error loading faculties'),
                  ),
                ],

                if (_selectedType == 'program-based') ...[
                  const SizedBox(height: AppSpacing.md),
                  _buildFieldLabel('Programs'),
                  programsAsync.when(
                    data: (programs) => Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: programs.map((p) => CheckboxListTile(
                          title: Text(p.name, style: AppTextStyles.bodySmall),
                          value: _selectedProgramIds.contains(p.id),
                          onChanged: (val) => setState(() {
                            if (val == true) {
                              _selectedProgramIds.add(p.id!);
                            } else {
                              _selectedProgramIds.remove(p.id);
                            }
                          }),
                          controlAffinity: ListTileControlAffinity.leading,
                          dense: true,
                        )).toList(),
                      ),
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const Text('Error loading programs'),
                  ),
                  if (_selectedProgramIds.isEmpty && _selectedFacultyId != null)
                    const Padding(
                      padding: EdgeInsets.only(top: 4, left: 12),
                      child: Text('Select at least one program', style: TextStyle(color: Colors.red, fontSize: 12)),
                    ),
                ],
                
                const SizedBox(height: AppSpacing.md),
                _buildFieldLabel('Description'),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(hintText: 'Describe the organization\'s purpose'),
                ),
                const SizedBox(height: AppSpacing.xl),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildUploadButton(
                        Icons.image_outlined, 
                        _logoImage != null ? 'Logo Selected' : 'Upload Logo',
                        isLogo: true,
                        isSelected: _logoImage != null,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _buildUploadButton(
                        Icons.add_photo_alternate_outlined, 
                        _bannerImage != null ? 'Banner Selected' : 'Upload Banner',
                        isLogo: false,
                        isSelected: _bannerImage != null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: organizationState.isLoading
                      ? null
                      : _handleSubmit,
                    child: organizationState.isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Create Organization'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedType == 'program-based' && _selectedProgramIds.isEmpty) {
        return;
      }
      
      final success = await ref.read(organizationControllerProvider.notifier).createOrganization(
        name: _nameController.text.trim(),
        code: _codeController.text.trim(),
        description: _descriptionController.text.trim(),
        type: _selectedType,
        campusId: _selectedCampusId,
        facultyId: _selectedFacultyId,
        programIds: _selectedProgramIds,
        logo: _logoImage != null ? File(_logoImage!.path) : null,
        banner: _bannerImage != null ? File(_bannerImage!.path) : null,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Organization created successfully with members.')),
        );
        Navigator.pop(context);
      }
    }
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(label, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildUploadButton(IconData icon, String label, {required bool isLogo, bool isSelected = false}) {
    final theme = Theme.of(context);
    return OutlinedButton.icon(
      onPressed: () => _pickImage(isLogo),
      icon: Icon(isSelected ? Icons.check_circle_rounded : icon, size: 20, color: isSelected ? Colors.green : null),
      label: Text(label, style: TextStyle(color: isSelected ? Colors.green : null)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        side: BorderSide(color: isSelected ? Colors.green : theme.colorScheme.outlineVariant),
      ),
    );
  }
}
