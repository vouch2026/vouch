import 'package:vouch_v2/core/widgets/loaders/flickr_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../campuses/models/campus_model.dart';
import '../../../campuses/providers/campus_provider.dart';

import 'package:image_picker/image_picker.dart';
import '../../../../core/providers/storage_provider.dart';

class EditCampusModal extends ConsumerStatefulWidget {
  final CampusModel campus;
  const EditCampusModal({super.key, required this.campus});

  @override
  ConsumerState<EditCampusModal> createState() => _EditCampusModalState();
}

class _EditCampusModalState extends ConsumerState<EditCampusModal> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _locationController;
  late final TextEditingController _descriptionController;
  bool _isLoading = false;
  XFile? _logoImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.campus.name);
    _locationController = TextEditingController(text: widget.campus.location);
    _descriptionController = TextEditingController(text: widget.campus.description);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
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
      String? logoUrl = widget.campus.logoUrl;
      if (_logoImage != null) {
        logoUrl = await ref.read(storageServiceProvider).uploadAcademicAsset(
          code: _nameController.text.trim(),
          file: _logoImage!,
          type: 'campus',
        );
      }

      final updatedCampus = widget.campus.copyWith(
        name: _nameController.text.trim(),
        location: _locationController.text.trim(),
        description: _descriptionController.text.trim(),
        logoUrl: logoUrl,
      );

      await ref.read(campusesProvider.notifier).updateCampus(updatedCampus);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Campus updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating campus: $e')),
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
                  Text(
                    'Edit Campus',
                    style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Campus Name',
                style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.xs),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'e.g. DORSU Main Campus',
                ),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                enabled: !_isLoading,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Location',
                style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.xs),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Mati City, Davao Oriental',
                ),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                enabled: !_isLoading,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Description (Optional)',
                style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.xs),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Brief description of the campus...',
                ),
                enabled: !_isLoading,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Campus Logo',
                style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  if (_logoImage == null && widget.campus.logoUrl != null && widget.campus.logoUrl!.isNotEmpty) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        widget.campus.logoUrl!,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image_rounded, size: 48),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                  ],
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : _pickImage,
                      icon: Icon(_logoImage != null ? Icons.check_circle_rounded : Icons.image_outlined, 
                        color: _logoImage != null ? Colors.green : null),
                      label: Text(_logoImage != null ? 'Logo Selected' : 'Change Logo',
                        style: TextStyle(color: _logoImage != null ? Colors.green : null)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        side: BorderSide(color: _logoImage != null ? Colors.green : Theme.of(context).colorScheme.outlineVariant),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
                    ),
                    child: _isLoading 
                      ? const SizedBox(height: 20, width: 20, child: FlickrLoader())
                      : const Text('Update Campus'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
