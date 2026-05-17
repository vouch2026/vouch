import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class OrganizationCreationModal extends StatefulWidget {
  const OrganizationCreationModal({super.key});

  @override
  State<OrganizationCreationModal> createState() => _OrganizationCreationModalState();
}

class _OrganizationCreationModalState extends State<OrganizationCreationModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedType = 'academic';
  String? _selectedFaculty;

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                
                _buildFieldLabel('Organization Name'),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(hintText: 'Enter full organization name'),
                  validator: (val) => val == null || val.isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('Organization Code'),
                          TextFormField(
                            controller: _codeController,
                            decoration: const InputDecoration(hintText: 'e.g. GDSC-VOUCH'),
                            validator: (val) => val == null || val.isEmpty ? 'Code is required' : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('Organization Type'),
                          DropdownButtonFormField<String>(
                            value: _selectedType,
                            items: ['academic', 'non-academic', 'sports', 'religious']
                                .map((e) => DropdownMenuItem(value: e, child: Text(e.toUpperCase())))
                                .toList(),
                            onChanged: (val) => setState(() => _selectedType = val!),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                
                _buildFieldLabel('Description'),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(hintText: 'Describe the organization\'s purpose'),
                ),
                const SizedBox(height: AppSpacing.md),
                
                _buildFieldLabel('Faculty / Program'),
                DropdownButtonFormField<String>(
                  value: _selectedFaculty,
                  items: ['College of Engineering', 'College of Arts and Sciences', 'College of Education']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedFaculty = val),
                  decoration: const InputDecoration(hintText: 'Select faculty/program'),
                ),
                const SizedBox(height: AppSpacing.xl),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildUploadButton(Icons.image_outlined, 'Upload Logo'),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _buildUploadButton(Icons.add_photo_alternate_outlined, 'Upload Banner'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Submit logic
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Create Organization'),
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

  Widget _buildUploadButton(IconData icon, String label) {
    final theme = Theme.of(context);
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
    );
  }
}
