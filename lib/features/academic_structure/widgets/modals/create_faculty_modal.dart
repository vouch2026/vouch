import 'package:vouch_v2/core/widgets/loaders/flickr_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../campuses/providers/campus_provider.dart';
import '../../../faculties/models/faculty_model.dart';
import '../../../faculties/providers/faculty_provider.dart';
import '../../../users/providers/users_provider.dart';

class CreateFacultyModal extends ConsumerStatefulWidget {
  const CreateFacultyModal({super.key});

  @override
  ConsumerState<CreateFacultyModal> createState() => _CreateFacultyModalState();
}

class _CreateFacultyModalState extends ConsumerState<CreateFacultyModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  String? _selectedCampus;
  String? _selectedDean;
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
      final faculty = FacultyModel(
        id: '', 
        name: _nameController.text.trim(),
        code: _codeController.text.trim(),
        campusId: _selectedCampus!,
        deanId: _selectedDean,
      );

      await ref.read(facultiesProvider.notifier).addFaculty(faculty);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Faculty created successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating faculty: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final campusesAsync = ref.watch(campusesProvider);
    final usersAsync = ref.watch(allUsersProvider);

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
                    'Add New Faculty',
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
                  isExpanded: true,
                  initialValue: _selectedCampus,
                  decoration: const InputDecoration(hintText: 'Select Campus'),
                  items: campuses.map((c) => DropdownMenuItem(
                    value: c.id, 
                    child: Text(
                      c.name,
                      overflow: TextOverflow.ellipsis,
                    ),
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
              const SizedBox(height: AppSpacing.md),
              Text(
                'Faculty Dean',
                style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.xs),
              usersAsync.when(
                data: (users) => DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: _selectedDean,
                  decoration: const InputDecoration(hintText: 'Select Faculty Dean (Optional)'),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('No Dean Assigned'),
                    ),
                    ...users.map((u) => DropdownMenuItem(
                      value: u.id, 
                      child: Text(
                        '${u.fullName} (${u.email})',
                        overflow: TextOverflow.ellipsis,
                      ),
                    )).toList(),
                  ],
                  onChanged: _isLoading ? null : (val) => setState(() => _selectedDean = val),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (e, s) => Text('Error loading users: $e', style: const TextStyle(color: Colors.red)),
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
                      ? const SizedBox(height: 20, width: 20, child: FlickrLoader())
                      : const Text('Create Faculty'),
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
