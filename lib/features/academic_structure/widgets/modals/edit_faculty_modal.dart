import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../campuses/providers/campus_provider.dart';
import '../../../faculties/models/faculty_model.dart';
import '../../../faculties/providers/faculty_provider.dart';

class EditFacultyModal extends ConsumerStatefulWidget {
  final FacultyModel faculty;
  const EditFacultyModal({super.key, required this.faculty});

  @override
  ConsumerState<EditFacultyModal> createState() => _EditFacultyModalState();
}

class _EditFacultyModalState extends ConsumerState<EditFacultyModal> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _codeController;
  String? _selectedCampus;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.faculty.name);
    _codeController = TextEditingController(text: widget.faculty.code);
    _selectedCampus = widget.faculty.campusId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final updatedFaculty = widget.faculty.copyWith(
        name: _nameController.text.trim(),
        code: _codeController.text.trim(),
        campusId: _selectedCampus!,
      );

      await ref.read(facultyRepositoryProvider).updateFaculty(updatedFaculty);
      ref.invalidate(facultiesProvider);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Faculty updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating faculty: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final campusesAsync = ref.watch(campusesProvider);

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
                    'Edit Faculty',
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
                'Campus Assignment',
                style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.xs),
              campusesAsync.when(
                data: (campuses) => DropdownButtonFormField<String>(
                  initialValue: _selectedCampus,
                  decoration: const InputDecoration(hintText: 'Select Campus'),
                  items: campuses.map((c) => DropdownMenuItem(
                    value: c.id, 
                    child: Text(c.name),
                  )).toList(),
                  onChanged: _isLoading ? null : (val) => setState(() => _selectedCampus = val),
                  validator: (val) => val == null ? 'Required' : null,
                ),
                loading: () => const LinearProgressIndicator(),
                error: (e, s) => Text('Error loading campuses: $e', style: const TextStyle(color: Colors.red)),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Faculty Name',
                style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.xs),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Faculty of Computing, Engineering and Technology',
                ),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                enabled: !_isLoading,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Faculty Code',
                style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.xs),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  hintText: 'e.g. FaCET',
                ),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                enabled: !_isLoading,
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
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
                    ),
                    child: _isLoading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Update Faculty'),
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
