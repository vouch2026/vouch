import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../schools/models/school_model.dart';
import '../../../schools/providers/school_provider.dart';
import '../../../../core/providers/storage_provider.dart';

class CreateSchoolModal extends ConsumerStatefulWidget {
  const CreateSchoolModal({super.key});

  @override
  ConsumerState<CreateSchoolModal> createState() => _CreateSchoolModalState();
}

class _CreateSchoolModalState extends ConsumerState<CreateSchoolModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;
  XFile? _logoImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _logoImage = image;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      String? logoUrl;
      if (_logoImage != null) {
        logoUrl = await ref.read(storageServiceProvider).uploadAcademicAsset(
          code: _codeController.text.trim(),
          file: _logoImage!,
          type: 'school',
        );
      }

      final school = SchoolModel(
        id: '',
        name: _nameController.text.trim(),
        code: _codeController.text.trim(),
        description: _descriptionController.text.trim(),
        logoUrl: logoUrl,
      );

      await ref.read(schoolsProvider.notifier).addSchool(school);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('School created successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating school: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Add New School / University', style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              
              Text('School Name', style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSpacing.xs),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(hintText: 'e.g. Davao Oriental State University', border: OutlineInputBorder()),
                validator: (val) => val == null || val.trim().isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: AppSpacing.md),

              Text('School Code', style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSpacing.xs),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(hintText: 'e.g. DORSU', border: OutlineInputBorder()),
                validator: (val) => val == null || val.trim().isEmpty ? 'Code is required' : null,
              ),
              const SizedBox(height: AppSpacing.md),

              Text('Description (Optional)', style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSpacing.xs),
              TextFormField(
                controller: _descriptionController,
                maxLines: 2,
                decoration: const InputDecoration(hintText: 'Brief description of the university', border: OutlineInputBorder()),
              ),
              const SizedBox(height: AppSpacing.lg),

              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.upload_file_rounded),
                    label: Text(_logoImage != null ? 'Logo Selected' : 'Upload Logo'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: _isLoading ? null : _submit,
                  style: FilledButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: _isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text('Create School', style: AppTextStyles.labelLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
