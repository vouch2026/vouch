import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../campuses/providers/campus_provider.dart';

class CreateFacultyModal extends ConsumerStatefulWidget {
  const CreateFacultyModal({super.key});

  @override
  ConsumerState<CreateFacultyModal> createState() => _CreateFacultyModalState();
}

class _CreateFacultyModalState extends ConsumerState<CreateFacultyModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  String? _selectedCampusId;

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final campusesAsync = ref.watch(campusesProvider);

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
                    Text('Add New Faculty', style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                _buildFieldLabel('Faculty Name'),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(hintText: 'e.g. Faculty of Computing'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                _buildFieldLabel('Faculty Code'),
                TextFormField(
                  controller: _codeController,
                  decoration: const InputDecoration(hintText: 'e.g. FCET'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                _buildFieldLabel('Assign to Campus'),
                campusesAsync.when(
                  data: (campuses) => DropdownButtonFormField<String>(
                    value: _selectedCampusId,
                    items: campuses.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                    onChanged: (v) => setState(() => _selectedCampusId = v),
                    validator: (v) => v == null ? 'Required' : null,
                    decoration: const InputDecoration(hintText: 'Select Campus'),
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (e, s) => Text('Error: $e'),
                ),
                const SizedBox(height: AppSpacing.md),
                _buildFieldLabel('Assign Dean (Optional)'),
                TextFormField(
                  decoration: const InputDecoration(hintText: 'Search or enter Dean name'),
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
                    child: const Text('Add Faculty'),
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
