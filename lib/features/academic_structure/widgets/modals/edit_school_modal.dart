import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/loaders/flickr_loader.dart';
import '../../../schools/models/school_model.dart';
import '../../../schools/providers/school_provider.dart';

/// Edit an existing school. Superadmin-only (callers gate the menu).
///
/// Mirrors [CreateSchoolModal] structure with fields pre-filled, plus a
/// status selector (create does not expose status).
class EditSchoolModal extends ConsumerStatefulWidget {
  final SchoolModel school;

  const EditSchoolModal({super.key, required this.school});

  @override
  ConsumerState<EditSchoolModal> createState() => _EditSchoolModalState();
}

class _EditSchoolModalState extends ConsumerState<EditSchoolModal> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _shortNameController;
  late String _status;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.school.name);
    _shortNameController =
        TextEditingController(text: widget.school.shortName ?? '');
    _status = widget.school.status;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _shortNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final updated = SchoolModel(
        id: widget.school.id,
        name: _nameController.text.trim(),
        shortName: _shortNameController.text.trim().isEmpty
            ? null
            : _shortNameController.text.trim(),
        logoUrl: widget.school.logoUrl,
        bannerUrl: widget.school.bannerUrl,
        status: _status,
      );
      await ref.read(schoolsProvider.notifier).updateSchool(updated);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('School updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating school: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    'Edit School',
                    style: AppTextStyles.titleLarge
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'School Name',
                style: AppTextStyles.labelMedium
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.xs),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Davao Oriental State University',
                ),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Required' : null,
                enabled: !_isLoading,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Short Name (Optional)',
                style: AppTextStyles.labelMedium
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.xs),
              TextFormField(
                controller: _shortNameController,
                decoration: const InputDecoration(hintText: 'e.g. DORSU'),
                enabled: !_isLoading,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Status',
                style: AppTextStyles.labelMedium
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.xs),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.all(Radius.circular(8))),
                ),
                isExpanded: true,
                items: const [
                  DropdownMenuItem(
                      value: 'active', child: Text('Active')),
                  DropdownMenuItem(
                      value: 'inactive', child: Text('Inactive')),
                ],
                onChanged: _isLoading
                    ? null
                    : (val) {
                        if (val != null) setState(() => _status = val);
                      },
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed:
                        _isLoading ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl, vertical: AppSpacing.md),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: FlickrLoader())
                        : const Text('Save Changes'),
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
