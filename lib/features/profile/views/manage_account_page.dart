import 'package:vouch_v2/core/widgets/loaders/flickr_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../../auth/providers/auth_provider.dart';
import '../controllers/profile_controller.dart';

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

  Future<void> _showChangePasswordDialog(BuildContext context, WidgetRef ref) async {
    final passController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: TextField(
          controller: passController,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'New Password'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (passController.text.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password must be at least 6 characters'), backgroundColor: AppColors.error),
                );
                return;
              }
              final success = await ref.read(profileControllerProvider.notifier).updatePassword(
                passController.text.trim(),
              );
              if (success && context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password updated successfully'), backgroundColor: AppColors.success),
                );
              }
            },
            child: const Text('Update'),
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

  Future<void> _pickAndUploadImage(WidgetRef ref) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
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
                    _buildProfileHeader(ref, profile),
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
                        canEdit: false,
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
                        onTap: () => _showChangePasswordDialog(context, ref),
                      ),
                      _buildActionTile(
                        label: 'Two-Factor Authentication',
                        icon: LucideIcons.shieldCheck,
                        trailing: Switch(
                          value: false,
                          onChanged: (val) {},
                          activeColor: AppColors.primary,
                        ),
                        onTap: () {},
                      ),
                    ]),
                    const SizedBox(height: AppSpacing.xxl),
                    Center(
                      child: TextButton.icon(
                        onPressed: () {
                          // TODO: Implement delete account
                        },
                        icon: const Icon(LucideIcons.trash2, color: AppColors.error, size: 18),
                        label: Text(
                          'Delete Account',
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error, fontWeight: FontWeight.w600),
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

  Widget _buildProfileHeader(WidgetRef ref, dynamic profile) {
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
                  onTap: () => _pickAndUploadImage(ref),
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
