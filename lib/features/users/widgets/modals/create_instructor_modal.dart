import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class CreateInstructorModal extends StatefulWidget {
  const CreateInstructorModal({super.key});

  @override
  State<CreateInstructorModal> createState() => _CreateInstructorModalState();
}

class _CreateInstructorModalState extends State<CreateInstructorModal> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  String _position = 'instructor';

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    Text('Register New Instructor', style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Instructor ID'),
                          TextFormField(
                            controller: _idController,
                            decoration: const InputDecoration(hintText: 'e.g. INS-00123'),
                            validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
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
                          _buildLabel('Position'),
                          DropdownButtonFormField<String>(
                            value: _position,
                            items: const [
                              DropdownMenuItem(value: 'instructor', child: Text('Instructor')),
                              DropdownMenuItem(value: 'dean', child: Text('Dean')),
                              DropdownMenuItem(value: 'program_head', child: Text('Program Head')),
                            ],
                            onChanged: (val) => setState(() => _position = val!),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                
                _buildLabel('Full Name'),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(hintText: 'Enter instructor\'s full name'),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                
                _buildLabel('Institutional Email'),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(hintText: 'e.g. prof.name@dorsu.edu.ph'),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                
                _buildLabel('Faculty Assignment'),
                DropdownButtonFormField<String>(
                  items: const [
                    DropdownMenuItem(value: 'fcet', child: Text('FCET')),
                    DropdownMenuItem(value: 'fte', child: Text('FTE')),
                  ],
                  onChanged: (v) {},
                  decoration: const InputDecoration(hintText: 'Select Faculty'),
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
                    child: const Text('Create Instructor Account'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
    );
  }
}
