import 'package:vouch_v2/core/widgets/loaders/flickr_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../faculties/providers/faculty_provider.dart';
import '../../../programs/models/program_model.dart';
import '../../../programs/providers/program_provider.dart';

class CreateProgramModal extends ConsumerStatefulWidget {
  const CreateProgramModal({super.key});

  @override
  ConsumerState<CreateProgramModal> createState() => _CreateProgramModalState();
}

class _CreateProgramModalState extends ConsumerState<CreateProgramModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  String? _selectedFaculty;
  bool _isLoading = false;

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
      final program = ProgramModel(
        id: '', 
        name: _nameController.text.trim(),
        code: _codeController.text.trim(),
        facultyId: _selectedFaculty!,
      );

      await ref.read(programsProvider.notifier).addProgram(program);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Program created successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating program: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final facultiesAsync = ref.watch(facultiesProvider);

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
                    'Add New Program',
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
                'Faculty Assignment',
                style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.xs),
              facultiesAsync.when(
                data: (faculties) => DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: _selectedFaculty,
                  decoration: const InputDecoration(hintText: 'Select Faculty'),
                  items: faculties.map((f) => DropdownMenuItem(
                    value: f.id, 
                    child: Text(
                      f.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )).toList(),
                  onChanged: _isLoading ? null : (val) => setState(() => _selectedFaculty = val),
                  validator: (val) => val == null ? 'Required' : null,
                ),
                loading: () => const LinearProgressIndicator(),
                error: (e, s) => Text('Error loading faculties: $e', style: const TextStyle(color: Colors.red)),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Program Name',
                style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.xs),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'e.g. BS Information Technology',
                ),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                enabled: !_isLoading,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Program Code',
                style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.xs),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  hintText: 'e.g. BSIT',
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
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
                    ),
                    child: _isLoading 
                      ? const SizedBox(height: 20, width: 20, child: FlickrLoader())
                      : const Text('Create Program'),
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
