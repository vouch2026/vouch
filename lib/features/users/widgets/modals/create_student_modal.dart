import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class CreateStudentModal extends StatefulWidget {
  const CreateStudentModal({super.key});

  @override
  State<CreateStudentModal> createState() => _CreateStudentModalState();
}

class _CreateStudentModalState extends State<CreateStudentModal> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  int _yearLevel = 1;

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
                    Text('Register New Student', style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
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
                          _buildLabel('Student Number'),
                          TextFormField(
                            controller: _idController,
                            decoration: const InputDecoration(hintText: 'e.g. 2022-00123'),
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
                          _buildLabel('Year Level'),
                          DropdownButtonFormField<int>(
                            value: _yearLevel,
                            items: [1, 2, 3, 4, 5].map((y) => DropdownMenuItem(value: y, child: Text('$y Year'))).toList(),
                            onChanged: (val) => setState(() => _yearLevel = val!),
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
                  decoration: const InputDecoration(hintText: 'Enter student\'s full name'),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                
                _buildLabel('Institutional Email'),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(hintText: 'e.g. name@dorsu.edu.ph'),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Faculty'),
                          DropdownButtonFormField<String>(
                            items: const [
                              DropdownMenuItem(value: 'fcet', child: Text('FCET')),
                              DropdownMenuItem(value: 'fte', child: Text('FTE')),
                            ],
                            onChanged: (v) {},
                            decoration: const InputDecoration(hintText: 'Select Faculty'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Program'),
                          DropdownButtonFormField<String>(
                            items: const [
                              DropdownMenuItem(value: 'bsit', child: Text('BSIT')),
                              DropdownMenuItem(value: 'bscs', child: Text('BSCS')),
                            ],
                            onChanged: (v) {},
                            decoration: const InputDecoration(hintText: 'Select Program'),
                          ),
                        ],
                      ),
                    ),
                  ],
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
                    child: const Text('Create Student Account'),
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
