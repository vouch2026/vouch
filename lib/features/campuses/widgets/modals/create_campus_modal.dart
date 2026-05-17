import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class CreateCampusModal extends StatefulWidget {
  const CreateCampusModal({super.key});

  @override
  State<CreateCampusModal> createState() => _CreateCampusModalState();
}

class _CreateCampusModalState extends State<CreateCampusModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
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
                    Text('Add New Campus', style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                _buildFieldLabel('Campus Name'),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(hintText: 'e.g. DORSU Main Campus'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                _buildFieldLabel('Location'),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(hintText: 'e.g. Mati City, Davao Oriental'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                _buildFieldLabel('Description'),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(hintText: 'Enter campus description'),
                ),
                const SizedBox(height: AppSpacing.xl),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.image_outlined),
                  label: const Text('Upload Campus Logo'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Add Campus'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(label, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
    );
  }
}
