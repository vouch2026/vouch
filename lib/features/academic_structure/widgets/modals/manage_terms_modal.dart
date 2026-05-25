import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../models/academic_term_model.dart';
import '../../providers/term_provider.dart';

class ManageTermsModal extends ConsumerStatefulWidget {
  const ManageTermsModal({super.key});

  @override
  ConsumerState<ManageTermsModal> createState() => _ManageTermsModalState();
}

class _ManageTermsModalState extends ConsumerState<ManageTermsModal> {
  final _yearController = TextEditingController();
  String _selectedSemester = '1st';
  bool _isSubmitting = false;

  final List<String> _semesters = ['1st', '2nd', 'Summer'];

  @override
  void dispose() {
    _yearController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    if (_yearController.text.isEmpty) return;

    setState(() => _isSubmitting = true);
    try {
      await ref.read(termRepositoryProvider).createTerm(
            academicYear: _yearController.text,
            semester: _selectedSemester,
          );
      _yearController.clear();
      ref.invalidate(academicTermsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Academic term created successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _handleSetActive(String id) async {
    try {
      await ref.read(termRepositoryProvider).setActiveTerm(id);
      ref.invalidate(academicTermsProvider);
      ref.invalidate(activeTermProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final termsAsync = ref.watch(academicTermsProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Manage Academic Terms', style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold)),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            const Divider(),
            const SizedBox(height: AppSpacing.lg),
            
            // Create New Term Section
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Academic Year', style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _yearController,
                        decoration: InputDecoration(
                          hintText: 'e.g. 2025-2026',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Semester', style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedSemester,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: _semesters.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (val) => setState(() => _selectedSemester = val!),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                FilledButton(
                  onPressed: _isSubmitting ? null : _handleCreate,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _isSubmitting 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Create'),
                ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.xl),
            Text('Existing Terms', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.md),
            
            // Terms List
            Flexible(
              child: termsAsync.when(
                data: (terms) => ListView.separated(
                  shrinkWrap: true,
                  itemCount: terms.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final term = terms[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('${term.academicYear} - ${term.semester}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (term.isActive)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('ACTIVE', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 10)),
                            )
                          else
                            TextButton(
                              onPressed: () => _handleSetActive(term.id),
                              child: const Text('Set Active'),
                            ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: term.isActive ? null : () async {
                              await ref.read(termRepositoryProvider).deleteTerm(term.id);
                              ref.invalidate(academicTermsProvider);
                            },
                            icon: const Icon(Icons.delete_outline, color: AppColors.error),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Text('Error: $err'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
