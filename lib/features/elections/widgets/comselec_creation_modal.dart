import 'package:vouch_v2/core/widgets/loaders/flickr_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../campuses/providers/campus_provider.dart';
import '../controllers/comselec_controller.dart';

class ComselecCreationModal extends ConsumerStatefulWidget {
  const ComselecCreationModal({super.key});

  @override
  ConsumerState<ComselecCreationModal> createState() => _ComselecCreationModalState();
}

class _ComselecCreationModalState extends ConsumerState<ComselecCreationModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String? _selectedCampusId;

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
      comselecControllerProvider,
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
    final comselecState = ref.watch(comselecControllerProvider);

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
                    Text('Create New COMSELEC Branch', style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),

                _buildFieldLabel('COMSELEC Name'),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(hintText: 'Enter full COMSELEC branch name'),
                  validator: (val) => val == null || val.isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                
                _buildFieldLabel('COMSELEC Code'),
                TextFormField(
                  controller: _codeController,
                  decoration: const InputDecoration(hintText: 'e.g. CAMPUS-COMSELEC'),
                  validator: (val) => val == null || val.isEmpty ? 'Code is required' : null,
                ),
                const SizedBox(height: AppSpacing.md),

                _buildFieldLabel('Campus'),
                campusesAsync.when(
                  data: (campuses) => DropdownButtonFormField<String>(
                    value: _selectedCampusId,
                    items: campuses.map((c) => DropdownMenuItem<String>(value: c.id, child: Text(c.name))).toList(),
                    onChanged: (val) => setState(() {
                      _selectedCampusId = val;
                    }),
                    validator: (val) => val == null ? 'Campus is required' : null,
                    decoration: const InputDecoration(hintText: 'Select Campus'),
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const Text('Error loading campuses'),
                ),
                const SizedBox(height: AppSpacing.md),

                _buildFieldLabel('Description'),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(hintText: 'Describe the branch scope/purpose'),
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
                    onPressed: comselecState.isLoading
                      ? null
                      : _handleSubmit,
                    child: comselecState.isLoading
                      ? const SizedBox(width: 20, height: 20, child: FlickrLoader())
                      : const Text('Create COMSELEC'),
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
      final success = await ref.read(comselecControllerProvider.notifier).createComselec(
        name: _nameController.text.trim(),
        code: _codeController.text.trim(),
        description: _descriptionController.text.trim(),
        campusId: _selectedCampusId,
        logo: _logoImage,
        banner: _bannerImage,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('COMSELEC branch created successfully. Students on this campus have been registered as Voters.')),
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
