import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../models/organization_model.dart';
import '../../providers/workspace_provider.dart';
import '../../controllers/organization_controller.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../core/widgets/loaders/flickr_loader.dart';

class OrganizationSettingsPanel extends ConsumerWidget {
  final OrganizationModel org;

  const OrganizationSettingsPanel({super.key, required this.org});

  Future<void> _pickAndUploadLogo(BuildContext context, WidgetRef ref, String orgId, String orgCode) async {
    final picker = ImagePicker();
    try {
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 85,
      );
      if (image != null && context.mounted) {
        final success = await ref.read(organizationControllerProvider.notifier).updateOrganization(
          id: orgId,
          code: orgCode,
          logoFile: image,
        );
        if (success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Logo updated successfully'), backgroundColor: AppColors.success),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking/uploading logo: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _pickAndUploadBanner(BuildContext context, WidgetRef ref, String orgId, String orgCode) async {
    final picker = ImagePicker();
    try {
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 600,
        imageQuality: 85,
      );
      if (image != null && context.mounted) {
        final success = await ref.read(organizationControllerProvider.notifier).updateOrganization(
          id: orgId,
          code: orgCode,
          bannerFile: image,
        );
        if (success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Banner updated successfully'), backgroundColor: AppColors.success),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking/uploading banner: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _showEditNameDialog(BuildContext context, WidgetRef ref, OrganizationModel org) async {
    final controller = TextEditingController(text: org.name);
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Organization Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Organization Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final val = controller.text.trim();
              if (val.isEmpty) return;
              final success = await ref.read(organizationControllerProvider.notifier).updateOrganization(
                id: org.id,
                code: org.code,
                name: val,
              );
              if (success && context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Organization name updated successfully'), backgroundColor: AppColors.success),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditCodeDialog(BuildContext context, WidgetRef ref, OrganizationModel org) async {
    final controller = TextEditingController(text: org.code);
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Organization Code'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Organization Code'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final val = controller.text.trim();
              if (val.isEmpty) return;
              final success = await ref.read(organizationControllerProvider.notifier).updateOrganization(
                id: org.id,
                code: val,
              );
              if (success && context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Organization code updated successfully'), backgroundColor: AppColors.success),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditAdviserDialog(BuildContext context, WidgetRef ref, OrganizationModel org) async {
    final controller = TextEditingController(text: org.adviserName);
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Adviser Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Adviser Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final val = controller.text.trim();
              final success = await ref.read(organizationControllerProvider.notifier).updateOrganization(
                id: org.id,
                code: org.code,
                adviserName: val,
              );
              if (success && context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Adviser name updated successfully'), backgroundColor: AppColors.success),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditDescriptionDialog(BuildContext context, WidgetRef ref, OrganizationModel org) async {
    final controller = TextEditingController(text: org.description);
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Description'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'Description'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final val = controller.text.trim();
              final success = await ref.read(organizationControllerProvider.notifier).updateOrganization(
                id: org.id,
                code: org.code,
                description: val,
              );
              if (success && context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Description updated successfully'), backgroundColor: AppColors.success),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showClearancePeriodDialog(BuildContext context, WidgetRef ref, OrganizationModel org) async {
    DateTime? tempStart = org.clearancePeriodStart ?? DateTime.now();
    DateTime? tempEnd = org.clearancePeriodEnd ?? DateTime.now().add(const Duration(days: 7));
    bool tempActive = org.isClearanceActive;

    Future<void> pickDateTime(BuildContext context, StateSetter dialogSetState, bool isStart) async {
      final initialDate = isStart ? tempStart : tempEnd;
      final pickedDate = await showDatePicker(
        context: context,
        initialDate: initialDate ?? DateTime.now(),
        firstDate: DateTime.now().subtract(const Duration(days: 365)),
        lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      );
      if (pickedDate == null) return;

      if (!context.mounted) return;
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate ?? DateTime.now()),
      );
      if (pickedTime == null) return;

      dialogSetState(() {
        final finalDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        if (isStart) {
          tempStart = finalDateTime;
        } else {
          tempEnd = finalDateTime;
        }
      });
    }

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, dialogSetState) => AlertDialog(
          title: const Text('Configure Clearance Period'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile(
                title: const Text('Enable Clearance Period', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Students can submit requests during this period'),
                value: tempActive,
                onChanged: (val) => dialogSetState(() => tempActive = val),
                activeColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
              ),
              const Divider(),
              const SizedBox(height: AppSpacing.sm),
              const Text('Start Date & Time', style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
              const SizedBox(height: 4),
              InkWell(
                onTap: () => pickDateTime(context, dialogSetState, true),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.calendar, size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        tempStart != null ? DateFormat('MMM dd, yyyy - hh:mm a').format(tempStart!) : 'Select start date',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const Text('End Date & Time', style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
              const SizedBox(height: 4),
              InkWell(
                onTap: () => pickDateTime(context, dialogSetState, false),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.calendar, size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        tempEnd != null ? DateFormat('MMM dd, yyyy - hh:mm a').format(tempEnd!) : 'Select end date',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            if (org.clearancePeriodStart != null || org.clearancePeriodEnd != null)
              TextButton(
                onPressed: () async {
                  final success = await ref.read(organizationControllerProvider.notifier).updateOrganization(
                    id: org.id,
                    code: org.code,
                    isClearanceActive: false,
                    clearClearancePeriod: true,
                  );
                  if (success && context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Clearance period cleared and disabled')),
                    );
                  }
                },
                child: const Text('Clear Schedule', style: TextStyle(color: AppColors.error)),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (tempStart != null && tempEnd != null && tempStart!.isAfter(tempEnd!)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Start date must be before end date'), backgroundColor: AppColors.error),
                  );
                  return;
                }
                final success = await ref.read(organizationControllerProvider.notifier).updateOrganization(
                  id: org.id,
                  code: org.code,
                  isClearanceActive: tempActive,
                  clearancePeriodStart: tempStart,
                  clearancePeriodEnd: tempEnd,
                );
                if (success && context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Clearance period updated successfully'), backgroundColor: AppColors.success),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  String _getClearancePeriodDisplay(OrganizationModel org) {
    final start = org.clearancePeriodStart;
    final end = org.clearancePeriodEnd;
    final now = DateTime.now();

    if (start != null && end != null) {
      if (now.isBefore(start)) {
        return 'Scheduled (Starts ${DateFormat('MMM dd, yyyy - hh:mm a').format(start)})';
      } else if (now.isAfter(end)) {
        return 'Ended (Expired on ${DateFormat('MMM dd, yyyy - hh:mm a').format(end)})';
      } else {
        return 'Active (Ends ${DateFormat('MMM dd, yyyy - hh:mm a').format(end)})';
      }
    }
    return 'Disabled';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.watch(workspaceProvider);
    final isCurrentWorkspace = workspace.selectedOrganization?.id == org.id;
    final activeOrg = isCurrentWorkspace ? (workspace.selectedOrganization ?? org) : org;
    final activeRole = isCurrentWorkspace ? workspace.activeRole : null;
    final activeMembership = isCurrentWorkspace ? workspace.activeMembership : null;

    final isGovernor = activeRole?.roleName == 'Governor' ||
        activeRole?.roleName == 'President' ||
        activeRole?.roleName == 'Super Admin' ||
        activeRole?.roleName == 'Adviser';

    final isSecretaryOrTreasurer = activeRole?.roleName == 'Secretary' ||
        activeRole?.roleName == 'Treasurer';

    final canEdit = isGovernor;
    final orgState = ref.watch(organizationControllerProvider);

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOrgHeader(context, ref, activeOrg, canEdit),
              const SizedBox(height: AppSpacing.xl),
              
              _buildSectionTitle('General Information'),
              const SizedBox(height: AppSpacing.md),
              _buildInfoCard([
                _buildInfoTile(
                  label: 'Organization Name',
                  value: activeOrg.name,
                  icon: LucideIcons.building,
                  canEdit: canEdit,
                  onEdit: () => _showEditNameDialog(context, ref, activeOrg),
                ),
                _buildInfoTile(
                  label: 'Organization Code',
                  value: activeOrg.code,
                  icon: LucideIcons.hash,
                  canEdit: canEdit,
                  onEdit: () => _showEditCodeDialog(context, ref, activeOrg),
                ),
                _buildInfoTile(
                  label: 'Adviser Name',
                  value: activeOrg.adviserName ?? 'N/A',
                  icon: LucideIcons.userCheck,
                  canEdit: canEdit,
                  onEdit: () => _showEditAdviserDialog(context, ref, activeOrg),
                ),
                _buildInfoTile(
                  label: 'Description',
                  value: activeOrg.description ?? 'N/A',
                  icon: LucideIcons.alignLeft,
                  canEdit: canEdit,
                  onEdit: () => _showEditDescriptionDialog(context, ref, activeOrg),
                ),
              ]),

              const SizedBox(height: AppSpacing.xl),
              _buildSectionTitle('Clearance Settings'),
              const SizedBox(height: AppSpacing.md),
              _buildInfoCard([
                _buildInfoTile(
                  label: 'Clearance Period',
                  value: _getClearancePeriodDisplay(activeOrg),
                  icon: LucideIcons.calendar,
                  canEdit: canEdit,
                  onEdit: () => _showClearancePeriodDialog(context, ref, activeOrg),
                ),
                _buildSwitchTile(
                  label: 'Require Adviser Signature',
                  subtitle: 'Adviser final signature required on activity card',
                  value: activeOrg.requiresAdviserSignature,
                  icon: LucideIcons.signature,
                  onChanged: canEdit
                      ? (val) async {
                          final success = await ref.read(organizationControllerProvider.notifier).updateOrganization(
                                id: activeOrg.id,
                                code: activeOrg.code,
                                requiresAdviserSignature: val,
                              );
                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Adviser signature requirement ${val ? 'enabled' : 'disabled'}')),
                            );
                          }
                        }
                      : null,
                ),
                _buildSwitchTile(
                  label: 'Require Faculty Dean Signature',
                  subtitle: 'Dean final signature required on activity card',
                  value: activeOrg.requiresFacultyDeanSignature,
                  icon: LucideIcons.graduationCap,
                  onChanged: canEdit
                      ? (val) async {
                          final success = await ref.read(organizationControllerProvider.notifier).updateOrganization(
                                id: activeOrg.id,
                                code: activeOrg.code,
                                requiresFacultyDeanSignature: val,
                              );
                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Faculty Dean signature requirement ${val ? 'enabled' : 'disabled'}')),
                            );
                          }
                        }
                      : null,
                ),
                _buildSwitchTile(
                  label: 'Allow Member Card Printing',
                  subtitle: 'Allow student members to print cleared cards',
                  value: activeOrg.allowMemberCardPrinting,
                  icon: LucideIcons.printer,
                  onChanged: canEdit
                      ? (val) async {
                          final success = await ref.read(organizationControllerProvider.notifier).updateOrganization(
                                id: activeOrg.id,
                                code: activeOrg.code,
                                allowMemberCardPrinting: val,
                              );
                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Member card printing ${val ? 'enabled' : 'disabled'}')),
                            );
                          }
                        }
                      : null,
                ),
                if (activeMembership != null && (isGovernor || isSecretaryOrTreasurer))
                  _buildSwitchTile(
                    label: 'Auto-Sign Clearances',
                    subtitle: 'Auto-sign when student has zero balances/absences',
                    value: activeMembership.autoSignClearance,
                    icon: LucideIcons.zap,
                    onChanged: (val) async {
                      try {
                        await SupabaseConfig.client
                            .from('organization_members')
                            .update({'auto_sign_clearance': val})
                            .eq('id', activeMembership.id);
                        ref.invalidate(workspaceProvider);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Auto-sign preferences updated successfully')),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error updating preferences: $e')),
                          );
                        }
                      }
                    },
                  ),
              ]),

              const SizedBox(height: AppSpacing.xl),
              _buildWorkflowDiagramCard(
                activeOrg.requiresAdviserSignature,
                activeOrg.requiresFacultyDeanSignature,
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
        if (orgState.isLoading)
          const Center(child: FlickrLoader()),
      ],
    );
  }

  Widget _buildOrgHeader(BuildContext context, WidgetRef ref, OrganizationModel org, bool canEdit) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Banner Placeholder
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Container(
              height: 120,
              width: double.infinity,
              color: AppColors.primary,
              child: org.bannerUrl != null && org.bannerUrl!.isNotEmpty
                  ? Image.network(
                      org.bannerUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Opacity(
                        opacity: 0.1,
                        child: Icon(LucideIcons.image, size: 100, color: Colors.white),
                      ),
                    )
                  : const Opacity(
                      opacity: 0.1,
                      child: Icon(LucideIcons.image, size: 100, color: Colors.white),
                    ),
            ),
          ),
          
          // Banner Edit Button
          if (canEdit)
            Positioned(
              top: 12,
              right: 12,
              child: GestureDetector(
                onTap: () => _pickAndUploadBanner(context, ref, org.id, org.code),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.camera, color: AppColors.white, size: 16),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 80, AppSpacing.xl, AppSpacing.xl),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.primary,
                        backgroundImage: org.logoUrl != null && org.logoUrl!.isNotEmpty
                            ? NetworkImage(org.logoUrl!)
                            : null,
                        child: org.logoUrl == null || org.logoUrl!.isEmpty
                            ? const Icon(LucideIcons.building, color: Colors.white, size: 40)
                            : null,
                      ),
                    ),
                    if (canEdit)
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _pickAndUploadLogo(context, ref, org.id, org.code),
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
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        org.name,
                        style: AppTextStyles.headlineSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${org.memberCount} MEMBERS',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '• ${org.type.replaceAll('-', ' ').toUpperCase()}',
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey),
                          ),
                        ],
                      ),
                    ],
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

  Widget _buildSwitchTile({
    required String label,
    required String subtitle,
    required bool value,
    required IconData icon,
    required ValueChanged<bool>? onChanged,
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
                  style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600, color: AppColors.textDark),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.textGrey),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildWorkflowDiagramCard(bool requiresAdviser, bool requiresFacultyDean) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.08)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Clearance Approval Path',
              style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(height: 4),
            Text(
              'Visual flowchart representing clearance processing based on current configs.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey),
            ),
            const SizedBox(height: AppSpacing.xl),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 500;

                final steps = [
                  _buildWorkflowStep(
                    step: '1',
                    title: 'Submission',
                    subtitle: 'Student clearance request',
                    color: AppColors.primary,
                    isCompleted: true,
                  ),
                  _buildWorkflowStep(
                    step: '2',
                    title: 'Officer review',
                    subtitle: 'Officers sign off',
                    color: AppColors.info,
                    isCompleted: true,
                  ),
                  _buildWorkflowStep(
                    step: '3',
                    title: 'Adviser sign',
                    subtitle: requiresAdviser ? 'Final signature required' : 'Auto-approved',
                    color: requiresAdviser ? AppColors.warning : Colors.grey,
                    isCompleted: requiresAdviser,
                    isSkipped: !requiresAdviser,
                  ),
                  _buildWorkflowStep(
                    step: '4',
                    title: 'Dean sign',
                    subtitle: requiresFacultyDean ? 'Dean signature required' : 'Auto-approved',
                    color: requiresFacultyDean ? AppColors.info : Colors.grey,
                    isCompleted: requiresFacultyDean,
                    isSkipped: !requiresFacultyDean,
                  ),
                  _buildWorkflowStep(
                    step: '5',
                    title: 'Cleared',
                    subtitle: 'Card approved',
                    color: AppColors.success,
                    isCompleted: true,
                  ),
                ];

                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: steps[0]),
                      _buildArrowConnector(),
                      Expanded(child: steps[1]),
                      _buildArrowConnector(),
                      Expanded(child: steps[2]),
                      _buildArrowConnector(),
                      Expanded(child: steps[3]),
                      _buildArrowConnector(),
                      Expanded(child: steps[4]),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      steps[0],
                      _buildVerticalConnector(),
                      steps[1],
                      _buildVerticalConnector(),
                      steps[2],
                      _buildVerticalConnector(),
                      steps[3],
                      _buildVerticalConnector(),
                      steps[4],
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkflowStep({
    required String step,
    required String title,
    required String subtitle,
    required Color color,
    required bool isCompleted,
    bool isSkipped = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      width: double.infinity,
      decoration: BoxDecoration(
        color: isSkipped ? Colors.grey.shade50 : color.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSkipped
              ? Colors.grey.shade200
              : (isCompleted ? color : color.withValues(alpha: 0.2)),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: isSkipped ? Colors.grey.shade300 : color,
            child: Text(
              step,
              style: TextStyle(
                color: isSkipped ? Colors.grey.shade600 : Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.bold,
              color: isSkipped ? Colors.grey.shade500 : AppColors.textDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 9,
              color: isSkipped ? Colors.grey.shade400 : AppColors.textGrey,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildArrowConnector() {
    return const Padding(
      padding: EdgeInsets.only(top: 36, left: 4, right: 4),
      child: Icon(Icons.arrow_forward_rounded, color: AppColors.border, size: 16),
    );
  }

  Widget _buildVerticalConnector() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Icon(Icons.arrow_downward_rounded, color: AppColors.border, size: 16),
    );
  }
}
