import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../faculties/providers/faculty_provider.dart';

class CreateProgramModal extends ConsumerStatefulWidget {
  const CreateProgramModal({super.key});

  @override
  ConsumerState<CreateProgramModal> createState() => _CreateProgramModalState();
}

class _CreateProgramModalState extends ConsumerState<CreateProgramModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  String? _selectedFacultyId;

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final facultiesAsync = ref.watch(facultiesProvider);

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
                    Text('Add New Program', style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                _buildFieldLabel('Program Name'),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(hintText: 'e.g. BS Information Technology'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                _buildFieldLabel('Program Code'),
                TextFormField(
                  controller: _codeController,
                  decoration: const InputDecoration(hintText: 'e.g. BSIT'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                _buildFieldLabel('Assign to Faculty'),
                facultiesAsync.when(
                  data: (faculties) => DropdownButtonFormField<String>(
                    value: _selectedFacultyId,
                    items: faculties.map((f) => DropdownMenuItem(value: f.id, child: Text(f.name))).toList(),
                    onChanged: (v) => setState(() => _selectedFacultyId = v),
                    validator: (v) => v == null ? 'Required' : null,
                    decoration: const InputDecoration(hintText: 'Select Faculty'),
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (e, s) => Text('Error: $e'),
                ),
                const SizedBox(height: AppSpacing.md),
                _buildFieldLabel('Assign Program Head (Optional)'),
                TextFormField(
                  decoration: const InputDecoration(hintText: 'Search or enter Program Head name'),
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
                    child: const Text('Add Program'),
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
