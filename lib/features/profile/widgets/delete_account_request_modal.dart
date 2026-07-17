import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../auth/models/user_model.dart';
import '../controllers/account_deletion_controller.dart';

class DeleteAccountRequestModal extends ConsumerStatefulWidget {
  final UserModel profile;

  const DeleteAccountRequestModal({
    super.key,
    required this.profile,
  });

  @override
  ConsumerState<DeleteAccountRequestModal> createState() => _DeleteAccountRequestModalState();
}

class _DeleteAccountRequestModalState extends ConsumerState<DeleteAccountRequestModal> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _studentIdController;
  late final TextEditingController _nameController;

  bool _acknowledgedClearance = false;
  bool _acknowledgedDataLoss = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.profile.email);
    _studentIdController = TextEditingController(text: widget.profile.schoolId);
    _nameController = TextEditingController(text: widget.profile.fullName);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _studentIdController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deletionState = ref.watch(accountDeletionControllerProvider);
    final isLoading = deletionState.isLoading;

    final isFormValid = _acknowledgedClearance &&
        _acknowledgedDataLoss &&
        _emailController.text.trim().isNotEmpty &&
        _studentIdController.text.trim().isNotEmpty &&
        _nameController.text.trim().isNotEmpty;

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? AppSpacing.md : 40.0,
        vertical: 24.0,
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 550),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? AppSpacing.md : AppSpacing.xl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header Row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.alertTriangle, color: AppColors.error, size: 24),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        'Account Deletion Request',
                        style: AppTextStyles.titleLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.x, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                
                // Description Text
                Text(
                  'Please use this form to request the permanent deletion of your Vouch account and associated data. Because your account is integrated with institutional attendance logs, fees, and clearances, your request is subject to administrative review. An administrator will review your academic record within 7-14 days to ensure there are no pending sanctions or unpaid fees. Once cleared, your account, authentication credentials, and personal data will be permanently purged from our system.',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey, height: 1.5),
                ),
                const Divider(height: AppSpacing.xxl),

                // Form Fields
                Text('1. Registered Email Address', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'Enter your registered email address',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onChanged: (_) => setState(() {}),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Email is required';
                    if (!value.contains('@')) return 'Please enter a valid email address';
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                Text('2. Official Student ID Number', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(
                  controller: _studentIdController,
                  decoration: const InputDecoration(
                    hintText: 'Enter student ID (e.g. SA-2026-001)',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onChanged: (_) => setState(() {}),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Student ID is required';
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                Text('3. Full Legal Name', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your first and last name',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onChanged: (_) => setState(() {}),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Name is required';
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.xl),

                // Checkbox Acknowledgments
                _buildCheckboxTile(
                  title: 'Acknowledgment of Clearance Review',
                  subtitle: 'I understand that my deletion request will be placed on a temporary administrative hold. My account will only be permanently deleted once an authorized institutional officer confirms I have no active sanctions, pending item collections, or uncleared organizational fees.',
                  value: _acknowledgedClearance,
                  onChanged: (val) {
                    setState(() => _acknowledgedClearance = val ?? false);
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                _buildCheckboxTile(
                  title: 'Acknowledgment of Data Loss',
                  subtitle: 'I understand that once this deletion is approved and executed, my account cannot be recovered. My attendance records, excuse requests, submitted proof of payments, and activity card signatures will be permanently purged.',
                  value: _acknowledgedDataLoss,
                  onChanged: (val) {
                    setState(() => _acknowledgedDataLoss = val ?? false);
                  },
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: isLoading ? null : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: AppColors.white,
                        disabledBackgroundColor: AppColors.error.withOpacity(0.4),
                      ),
                      onPressed: (!isFormValid || isLoading)
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                final success = await ref
                                    .read(accountDeletionControllerProvider.notifier)
                                    .submitRequest(
                                      userId: widget.profile.id!,
                                      email: _emailController.text.trim(),
                                      studentIdNumber: _studentIdController.text.trim(),
                                      fullName: _nameController.text.trim(),
                                      acknowledgedClearance: _acknowledgedClearance,
                                      acknowledgedDataLoss: _acknowledgedDataLoss,
                                    );

                                if (success && context.mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Deletion request submitted successfully. Under administrative review.'),
                                      backgroundColor: AppColors.success,
                                    ),
                                  );
                                } else if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Failed to submit request: ${deletionState.error ?? 'Unknown error'}'),
                                      backgroundColor: AppColors.error,
                                    ),
                                  );
                                }
                              }
                            },
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                            )
                          : const Text('Submit Request'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckboxTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 24,
            width: 24,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.error,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.textDark),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
