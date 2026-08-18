import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../../../core/utils/offline_image_cache.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final userProfileAsync = ref.watch(userProfileProvider);

    return DashboardLayout(
      title: 'Settings',
      child: userProfileAsync.when(
        data: (profile) {
          if (profile == null) return const Center(child: Text('User not found'));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(context, ref, profile),
                const SizedBox(height: AppSpacing.xl),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(LucideIcons.smartphone, color: AppColors.info, size: 20),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          'Note: These preferences and reminder options are only applicable in the mobile app version of Vouch.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.info,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                
                 _buildSectionTitle('Notifications & Reminders'),
                const SizedBox(height: AppSpacing.md),
                _buildSettingsContainer([
                  _buildSwitchTile(
                    icon: LucideIcons.bell,
                    title: 'Global Notifications',
                    value: settings.notificationsEnabled,
                    onChanged: (val) => ref.read(settingsProvider.notifier).toggleNotifications(val),
                  ),
                  if (settings.notificationsEnabled) ...[
                    const Divider(height: 1, color: AppColors.border),
                    _buildDropdownTile<int>(
                      context: context,
                      icon: LucideIcons.clock,
                      title: 'Class Reminders',
                      value: settings.scheduleReminderLeadMinutes,
                      options: const [
                        SettingsOption(value: 5, label: '5 minutes before'),
                        SettingsOption(value: 10, label: '10 minutes before'),
                        SettingsOption(value: 15, label: '15 minutes before'),
                        SettingsOption(value: 30, label: '30 minutes before'),
                        SettingsOption(value: 60, label: '1 hour before'),
                      ],
                      onChanged: (val) {
                        ref.read(settingsProvider.notifier).updateScheduleReminderMinutes(val);
                      },
                    ),
                    const Divider(height: 1, color: AppColors.border),
                    _buildDropdownTile<int>(
                      context: context,
                      icon: LucideIcons.calendarClock,
                      title: 'Task Reminders',
                      value: settings.taskReminderLeadMinutes,
                      options: const [
                        SettingsOption(value: 60, label: '1 hour before'),
                        SettingsOption(value: 360, label: '6 hours before'),
                        SettingsOption(value: 720, label: '12 hours before'),
                        SettingsOption(value: 1440, label: '1 day before'),
                        SettingsOption(value: 2880, label: '2 days before'),
                        SettingsOption(value: 4320, label: '3 days before'),
                      ],
                      onChanged: (val) {
                        ref.read(settingsProvider.notifier).updateTaskReminderMinutes(val);
                      },
                    ),
                  ],
                ]),

                const SizedBox(height: AppSpacing.xl),
                _buildSectionTitle('Preferences & Security'),
                const SizedBox(height: AppSpacing.md),
                _buildSettingsContainer([
                  _buildDropdownTile<String>(
                    context: context,
                    icon: LucideIcons.palette,
                    title: 'Theme Mode',
                    value: settings.themeMode,
                    options: const [
                      SettingsOption(value: 'system', label: 'System Default'),
                    ],
                    onChanged: (val) {
                      ref.read(settingsProvider.notifier).updateThemeMode(val);
                    },
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  _buildSwitchTile(
                    icon: LucideIcons.fingerprint,
                    title: 'Biometric Lock',
                    value: settings.biometricLockEnabled,
                    onChanged: (val) async {
                      final newSettings = settings.copyWith(biometricLockEnabled: val);
                      await ref.read(settingsProvider.notifier).updateSettings(newSettings);
                    },
                  ),
                ]),

                const SizedBox(height: AppSpacing.xl),
                _buildSectionTitle('Data & Storage'),
                const SizedBox(height: AppSpacing.md),
                _buildSettingsContainer([
                  _buildSwitchTile(
                    icon: LucideIcons.wifi,
                    title: 'WiFi-Only Sync',
                    value: settings.wifiOnlySync,
                    onChanged: (val) async {
                      final newSettings = settings.copyWith(wifiOnlySync: val);
                      await ref.read(settingsProvider.notifier).updateSettings(newSettings);
                    },
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  ListTile(
                    leading: Icon(LucideIcons.trash2, color: AppColors.error),
                    title: const Text('Clear Image Cache', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
                    onTap: () async {
                      try {
                        await Hive.box('offline_images').clear();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Offline image cache successfully cleared!')),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to clear cache: $e')),
                          );
                        }
                      }
                    },
                  ),
                ]),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading profile: $e')),
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
              backgroundImage: profile.avatarUrl != null && profile.avatarUrl.isNotEmpty && OfflineImageCache.get(profile.avatarUrl) != null
                  ? OfflineImageCache.get(profile.avatarUrl)
                  : const AssetImage('assets/images/my_profile.webp') as ImageProvider,
            ),
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

  Widget _buildSettingsContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon, color: AppColors.primary),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textGrey)) : null,
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
    );
  }

  Widget _buildDropdownTile<T>({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    required T value,
    required List<SettingsOption<T>> options,
    required ValueChanged<T> onChanged,
  }) {
    final selectedOption = options.firstWhere((opt) => opt.value == value, orElse: () => options.first);
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textGrey)) : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            selectedOption.label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
          ),
          const SizedBox(width: 4),
          Icon(LucideIcons.chevronDown, size: 14, color: AppColors.primary),
        ],
      ),
      onTap: () => _showSelectionBottomSheet<T>(
        context: context,
        title: title,
        options: options,
        selectedValue: value,
        onChanged: onChanged,
      ),
    );
  }

  void _showSelectionBottomSheet<T>({
    required BuildContext context,
    required String title,
    required List<SettingsOption<T>> options,
    required T selectedValue,
    required ValueChanged<T> onChanged,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  title,
                  style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.textDark),
                ),
              ),
              const Divider(height: 1, color: AppColors.border),
              ...options.map((option) {
                final isSelected = option.value == selectedValue;
                return ListTile(
                  title: Text(
                    option.label,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? AppColors.primary : AppColors.textDark,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(LucideIcons.check, color: AppColors.primary, size: 20)
                      : null,
                  onTap: () {
                    onChanged(option.value);
                    Navigator.pop(context);
                  },
                );
              }),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        );
      },
    );
  }
}

class SettingsOption<T> {
  final T value;
  final String label;
  const SettingsOption({required this.value, required this.label});
}
