import 'package:vouch_v2/core/widgets/loaders/flickr_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../../auth/providers/auth_provider.dart';
import '../controllers/profile_controller.dart';
import 'package:intl/intl.dart';
import '../providers/account_deletion_provider.dart';
import '../widgets/delete_account_request_modal.dart';
import '../../../routes/route_paths.dart';

class ManageAccountPage extends ConsumerWidget {
  const ManageAccountPage({super.key});

  Future<void> _showEditNameDialog(BuildContext context, WidgetRef ref, dynamic profile) async {
    final firstController = TextEditingController(text: profile.firstName);
    final lastController = TextEditingController(text: profile.lastName);

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Name'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: firstController,
              decoration: const InputDecoration(labelText: 'First Name'),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: lastController,
              decoration: const InputDecoration(labelText: 'Last Name'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await ref.read(profileControllerProvider.notifier).updateName(
                firstName: firstController.text.trim(),
                lastName: lastController.text.trim(),
              );
              if (success && context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Name updated successfully'), backgroundColor: AppColors.success),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }



  Future<void> _showYearLevelDialog(BuildContext context, WidgetRef ref, dynamic profile) async {
    int? selectedYear = profile.yearLevel;

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Update Year Level'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [1, 2, 3, 4, 5].map((year) => RadioListTile<int>(
              title: Text('$year${_getYearSuffix(year)} Year'),
              value: year,
              groupValue: selectedYear,
              onChanged: (val) => setState(() => selectedYear = val),
              activeColor: AppColors.primary,
              contentPadding: EdgeInsets.zero,
            )).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: selectedYear == null ? null : () async {
                final success = await ref.read(profileControllerProvider.notifier).updateYearLevel(selectedYear!);
                if (success && context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Year level updated successfully'), backgroundColor: AppColors.success),
                  );
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  String _getYearSuffix(int year) {
    if (year >= 11 && year <= 13) return 'th';
    switch (year % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  Future<void> _pickAndUploadImage(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final name = image.name.toLowerCase();
      final allowedExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp'];
      final isImage = allowedExtensions.any((ext) => name.endsWith(ext));

      if (!isImage) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid file format. Please select a valid image file (JPG, JPEG, PNG, GIF, WEBP, BMP).'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      await ref.read(profileControllerProvider.notifier).updateAvatar(image);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(userProfileProvider);
    final profileState = ref.watch(profileControllerProvider);

    return DashboardLayout(
      title: 'Manage Account',
      child: userProfileAsync.when(
        data: (profile) {
          if (profile == null) return const Center(child: Text('User not found'));

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileHeader(context, ref, profile),
                    const SizedBox(height: AppSpacing.xl),
                    _buildSectionTitle('Personal Information'),
                    const SizedBox(height: AppSpacing.md),
                    _buildInfoCard([
                      _buildInfoTile(
                        label: 'Full Name',
                        value: profile.fullName,
                        icon: LucideIcons.user,
                        onEdit: () => _showEditNameDialog(context, ref, profile),
                      ),
                      _buildInfoTile(
                        label: 'Email Address',
                        value: profile.email,
                        icon: LucideIcons.mail,
                        canEdit: true,
                        onEdit: () => context.push(RoutePaths.changeEmail),
                      ),
                      _buildInfoTile(
                        label: 'ID Number',
                        value: profile.schoolId,
                        icon: LucideIcons.creditCard,
                        canEdit: false,
                      ),
                    ]),
                    const SizedBox(height: AppSpacing.xl),
                    _buildSectionTitle('Academic Information'),
                    const SizedBox(height: AppSpacing.md),
                    _buildInfoCard([
                      _buildInfoTile(
                        label: 'Faculty',
                        value: profile.facultyName ?? 'N/A',
                        icon: LucideIcons.graduationCap,
                        canEdit: false,
                      ),
                      _buildInfoTile(
                        label: 'Program',
                        value: profile.programName ?? 'N/A',
                        icon: LucideIcons.bookOpen,
                        canEdit: false,
                      ),
                      _buildInfoTile(
                        label: 'Year Level',
                        value: profile.yearLevelDisplay,
                        icon: LucideIcons.layers,
                        canEdit: profile.role == 'student',
                        onEdit: () => _showYearLevelDialog(context, ref, profile),
                      ),
                    ]),
                    const SizedBox(height: AppSpacing.xl),
                    _buildSectionTitle('Security'),
                    const SizedBox(height: AppSpacing.md),
                    _buildInfoCard([
                      _buildActionTile(
                        label: 'Change Password',
                        icon: LucideIcons.lock,
                        onTap: () => context.push(RoutePaths.changePassword),
                      ),
                    ]),
                    const SizedBox(height: AppSpacing.xxl),
                    ref.watch(myPendingDeletionRequestProvider).when(
                      data: (pendingRequest) {
                        if (pendingRequest != null) {
                          return Center(
                            child: Container(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withOpacity(0.1),
                                border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(LucideIcons.alertTriangle, color: AppColors.warning, size: 18),
                                      const SizedBox(width: AppSpacing.sm),
                                      Text(
                                        'Deletion Request Pending',
                                        style: AppTextStyles.bodyMedium.copyWith(
                                          color: AppColors.warning,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    'Submitted on: ${DateFormat('yyyy-MM-dd HH:mm').format(pendingRequest.createdAt ?? DateTime.now())}',
                                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        
                        return Center(
                          child: TextButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => DeleteAccountRequestModal(profile: profile),
                              );
                            },
                            icon: const Icon(LucideIcons.trash2, color: AppColors.error, size: 18),
                            label: Text(
                              'Delete Account',
                              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error, fontWeight: FontWeight.w600),
                            ),
                          ),
                        );
                      },
                      loading: () => const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      error: (err, _) => Center(
                        child: TextButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => DeleteAccountRequestModal(profile: profile),
                            );
                          },
                          icon: const Icon(LucideIcons.trash2, color: AppColors.error, size: 18),
                          label: Text(
                            'Delete Account',
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
              if (profileState.isLoading)
                const Center(child: FlickrLoader()),
            ],
          );
        },
        loading: () => const Center(child: FlickrLoader()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, WidgetRef ref, dynamic profile) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.1), width: 4),
                ),
                child: CircleAvatar(
                  radius: 46,
                  backgroundColor: AppColors.background,
                  backgroundImage: profile.avatarUrl != null && profile.avatarUrl.isNotEmpty
                      ? NetworkImage(profile.avatarUrl)
                      : const AssetImage('assets/images/my_profile.png') as ImageProvider,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _pickAndUploadImage(context, ref),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.camera, color: AppColors.white, size: 16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.xl),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.fullName,
                  style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  profile.email,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey),
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    profile.roleDisplay.toUpperCase(),
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Text(
        title,
        style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.textDark),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildInfoTile({
    required String label,
    required String value,
    required IconData icon,
    bool canEdit = true,
    VoidCallback? onEdit,
  }) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.textGrey),
                ),
                Text(
                  value,
                  style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600, color: AppColors.textDark),
                ),
              ],
            ),
          ),
          if (canEdit)
            IconButton(
              onPressed: onEdit,
              icon: const Icon(LucideIcons.edit3, size: 18, color: AppColors.textGrey),
            ),
        ],
      ),
    );
  }

  Widget _buildActionTile({required String label, required IconData icon, Widget? trailing, required VoidCallback onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.05),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        label,
        style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600, color: AppColors.textDark),
      ),
      trailing: trailing ?? const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.textGrey),
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
    );
  }
}
