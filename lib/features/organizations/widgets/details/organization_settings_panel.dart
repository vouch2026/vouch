import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../models/organization_model.dart';
import '../../models/organization_membership_model.dart';
import '../../providers/workspace_provider.dart';
import '../../providers/organization_provider.dart';
import '../../controllers/organization_controller.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../sanctions/views/sanction_rules_page.dart';
import '../../../../core/models/app_role.dart';

class OrganizationSettingsPanel extends ConsumerStatefulWidget {
  final OrganizationModel org;

  const OrganizationSettingsPanel({super.key, required this.org});

  @override
  ConsumerState<OrganizationSettingsPanel> createState() => _OrganizationSettingsPanelState();
}

class _OrganizationSettingsPanelState extends ConsumerState<OrganizationSettingsPanel> {
  final _formKey = GlobalKey<FormState>();
  
  String? _initializedOrgId;
  late final TextEditingController _nameController;
  late final TextEditingController _codeController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _adviserNameController;
  late final TextEditingController _logoUrlController;
  late final TextEditingController _bannerUrlController;
  
  bool? _requiresAdviserSignature;
  bool? _requiresFacultyDeanSignature;
  bool? _isClearanceActive;
  int _activeTab = 0;
  
  XFile? _logoImage;
  XFile? _bannerImage;
  final ImagePicker _picker = ImagePicker();

  bool _isSaving = false;
  bool _isSavingBranding = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _codeController = TextEditingController();
    _descriptionController = TextEditingController();
    _adviserNameController = TextEditingController();
    _logoUrlController = TextEditingController();
    _bannerUrlController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _descriptionController.dispose();
    _adviserNameController.dispose();
    _logoUrlController.dispose();
    _bannerUrlController.dispose();
    super.dispose();
  }

  void _initControllersIfNeeded(OrganizationModel org) {
    if (_initializedOrgId != org.id) {
      _initializedOrgId = org.id;
      _nameController.text = org.name;
      _codeController.text = org.code;
      _descriptionController.text = org.description ?? '';
      _adviserNameController.text = org.adviserName ?? '';
      _logoUrlController.text = org.logoUrl ?? '';
      _bannerUrlController.text = org.bannerUrl ?? '';
      _requiresAdviserSignature = org.requiresAdviserSignature;
      _requiresFacultyDeanSignature = org.requiresFacultyDeanSignature;
      _isClearanceActive = org.isClearanceActive;
      _logoImage = null;
      _bannerImage = null;
    }
  }

  Future<void> _pickImage(bool isLogo) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: isLogo ? 500 : 1200,
        maxHeight: isLogo ? 500 : 600,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          if (isLogo) {
            _logoImage = image;
          } else {
            _bannerImage = image;
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  void _saveGeneralInfo(String orgId) async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      final success = await ref.read(organizationControllerProvider.notifier).updateOrganization(
        id: orgId,
        name: _nameController.text.trim(),
        code: _codeController.text.trim(),
        description: _descriptionController.text.trim(),
        adviserName: _adviserNameController.text.trim(),
        logoUrl: _logoUrlController.text,
        bannerUrl: _bannerUrlController.text,
        requiresAdviserSignature: _requiresAdviserSignature,
        requiresFacultyDeanSignature: _requiresFacultyDeanSignature,
        isClearanceActive: _isClearanceActive,
      );
      
      if (mounted) {
        setState(() => _isSaving = false);
      }
      
      if (success && mounted) {
        final updatedOrg = await ref.read(organizationRepositoryProvider).getOrganizationById(orgId);
        if (updatedOrg != null && mounted) {
          await ref.read(workspaceProvider.notifier).selectOrganization(updatedOrg);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Organization profile updated successfully')),
        );
      }
    }
  }

  void _saveBranding(String orgId) async {
    setState(() => _isSavingBranding = true);
    final success = await ref.read(organizationControllerProvider.notifier).updateOrganization(
      id: orgId,
      name: _nameController.text.trim(),
      code: _codeController.text.trim(),
      description: _descriptionController.text.trim(),
      adviserName: _adviserNameController.text.trim(),
      logoFile: _logoImage,
      bannerFile: _bannerImage,
      logoUrl: _logoUrlController.text,
      bannerUrl: _bannerUrlController.text,
      requiresAdviserSignature: _requiresAdviserSignature,
      requiresFacultyDeanSignature: _requiresFacultyDeanSignature,
      isClearanceActive: _isClearanceActive,
    );
    
    if (mounted) {
      setState(() => _isSavingBranding = false);
    }
    
    if (success && mounted) {
      final updatedOrg = await ref.read(organizationRepositoryProvider).getOrganizationById(orgId);
      if (updatedOrg != null && mounted) {
        await ref.read(workspaceProvider.notifier).selectOrganization(updatedOrg);
      }
      setState(() {
        _logoImage = null;
        _bannerImage = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Branding assets updated successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _initControllersIfNeeded(widget.org);
    
    final workspace = ref.watch(workspaceProvider);
    final isCurrentWorkspace = workspace.selectedOrganization?.id == widget.org.id;
    final activeRole = isCurrentWorkspace ? workspace.activeRole : null;
    final activeMembership = isCurrentWorkspace ? workspace.activeMembership : null;
    
    final isGovernor = activeRole?.roleName == 'Governor' || 
                       activeRole?.roleName == 'President' || 
                       activeRole?.roleName == 'Super Admin' ||
                       activeRole?.roleName == 'Adviser';
                       
    final isSecretaryOrTreasurer = activeRole?.roleName == 'Secretary' || 
                                 activeRole?.roleName == 'Treasurer';

    final canEdit = isGovernor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildOrgHeaderCard(widget.org),
        const SizedBox(height: AppSpacing.lg),
        _buildTabSelector(),
        const SizedBox(height: AppSpacing.lg),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _buildActiveTabContent(widget.org, canEdit, activeRole, activeMembership),
        ),
      ],
    );
  }

  Widget _buildActiveTabContent(
    OrganizationModel org, 
    bool canEdit, 
    AppRole? activeRole, 
    OrganizationMembershipModel? activeMembership
  ) {
    switch (_activeTab) {
      case 0:
        return _buildGeneralInfoTab(org, canEdit);
      case 1:
        return _buildBrandingTab(org, canEdit);
      case 2:
        return _buildClearanceTab(org, activeRole, activeMembership);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildOrgHeaderCard(OrganizationModel org) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            if (org.bannerUrl != null && org.bannerUrl!.isNotEmpty)
              Positioned.fill(
                child: Opacity(
                  opacity: 0.2,
                  child: Image.network(
                    org.bannerUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(),
                  ),
                ),
              ),
            Positioned(
              right: -40,
              top: -40,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.04),
                ),
              ),
            ),
            Positioned(
              left: -10,
              bottom: -40,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.02),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: ClipOval(
                      child: org.logoUrl != null && org.logoUrl!.isNotEmpty
                          ? Image.network(
                              org.logoUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.business_rounded,
                                size: 36,
                                color: AppColors.primary,
                              ),
                            )
                          : const Icon(
                              Icons.business_rounded,
                              size: 36,
                              color: AppColors.primary,
                            ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xl),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                org.name,
                                style: AppTextStyles.headlineLarge.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.accent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                org.code,
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.textDark,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (org.description != null && org.description!.isNotEmpty)
                          Text(
                            org.description!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white.withOpacity(0.8),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.person_rounded, size: 12, color: Colors.white.withOpacity(0.7)),
                            const SizedBox(width: 4),
                            Text(
                              org.adviserName != null && org.adviserName!.isNotEmpty
                                  ? 'Adviser: ${org.adviserName}'
                                  : 'No adviser assigned',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.lg),
                            Icon(Icons.people_alt_rounded, size: 12, color: Colors.white.withOpacity(0.7)),
                            const SizedBox(width: 4),
                            Text(
                              '${org.memberCount} members',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 11,
                              ),
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
      ),
    );
  }

  Widget _buildTabSelector() {
    final tabs = [
      {'icon': Icons.business_rounded, 'label': 'General Info'},
      {'icon': Icons.image_rounded, 'label': 'Branding Assets'},
      {'icon': Icons.rule_rounded, 'label': 'Clearance & Rules'},
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final active = _activeTab == index;
          return Expanded(
            child: InkWell(
              onTap: () => setState(() => _activeTab = index),
              borderRadius: BorderRadius.circular(8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: active ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: active
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      tabs[index]['icon'] as IconData,
                      size: 16,
                      color: active ? AppColors.primary : AppColors.textGrey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      tabs[index]['label'] as String,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: active ? FontWeight.bold : FontWeight.normal,
                        color: active ? AppColors.primary : AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildGeneralInfoTab(OrganizationModel org, bool canEdit) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'General Information',
              style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Configure your organization\'s primary identifier and details.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey),
            ),
            const SizedBox(height: AppSpacing.xl),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel('Organization Name'),
                  TextFormField(
                    controller: _nameController,
                    enabled: canEdit,
                    style: AppTextStyles.bodyMedium,
                    decoration: const InputDecoration(
                      hintText: 'Enter organization name',
                      prefixIcon: Icon(Icons.business_rounded, size: 20),
                    ),
                    validator: (val) => val == null || val.isEmpty ? 'Name is required' : null,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildFieldLabel('Organization Code'),
                  TextFormField(
                    controller: _codeController,
                    enabled: canEdit,
                    style: AppTextStyles.bodyMedium,
                    decoration: const InputDecoration(
                      hintText: 'e.g. GDSC-VOUCH',
                      prefixIcon: Icon(Icons.qr_code_rounded, size: 20),
                    ),
                    validator: (val) => val == null || val.isEmpty ? 'Code is required' : null,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildFieldLabel('Adviser Name'),
                  TextFormField(
                    controller: _adviserNameController,
                    enabled: canEdit,
                    style: AppTextStyles.bodyMedium,
                    decoration: const InputDecoration(
                      hintText: 'Enter adviser name',
                      prefixIcon: Icon(Icons.person_rounded, size: 20),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildFieldLabel('Description'),
                  TextFormField(
                    controller: _descriptionController,
                    enabled: canEdit,
                    style: AppTextStyles.bodyMedium,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Describe the organization\'s purpose and goals...',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  if (canEdit)
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: FilledButton.icon(
                        onPressed: _isSaving ? null : () => _saveGeneralInfo(org.id),
                        icon: _isSaving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Icon(Icons.save_rounded, size: 18),
                        label: Text(_isSaving ? 'Saving Changes...' : 'Save Settings'),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandingTab(OrganizationModel org, bool canEdit) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Branding Assets',
              style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Upload or configure your organization\'s official logo and banner image.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey),
            ),
            const SizedBox(height: AppSpacing.xl),
            
            Text('Organization Logo', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: _logoImage != null
                        ? (kIsWeb
                            ? Image.network(_logoImage!.path, fit: BoxFit.cover)
                            : Image.file(File(_logoImage!.path), fit: BoxFit.cover))
                        : (org.logoUrl != null && org.logoUrl!.isNotEmpty
                            ? Image.network(
                                org.logoUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(Icons.business_rounded),
                              )
                            : _buildImagePlaceholder(Icons.business_rounded)),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                if (canEdit) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _pickImage(true),
                        icon: const Icon(Icons.upload_rounded, size: 16),
                        label: const Text('Upload New Logo'),
                        style: ElevatedButton.styleFrom(elevation: 0),
                      ),
                      const SizedBox(height: 8),
                      if (_logoImage != null)
                        TextButton.icon(
                          onPressed: () => setState(() => _logoImage = null),
                          icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.error),
                          label: const Text('Cancel Upload', style: TextStyle(color: AppColors.error)),
                        ),
                    ],
                  ),
                ] else
                  Text('Only administrators can update branding.', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey)),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            
            Text('Organization Banner', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: _bannerImage != null
                    ? (kIsWeb
                        ? Image.network(_bannerImage!.path, fit: BoxFit.cover)
                        : Image.file(File(_bannerImage!.path), fit: BoxFit.cover))
                    : (org.bannerUrl != null && org.bannerUrl!.isNotEmpty
                        ? Image.network(
                            org.bannerUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(Icons.add_photo_alternate_outlined),
                          )
                        : _buildImagePlaceholder(Icons.add_photo_alternate_rounded)),
              ),
            ),
            if (canEdit) ...[
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(false),
                    icon: const Icon(Icons.upload_rounded, size: 16),
                    label: const Text('Upload New Banner'),
                    style: ElevatedButton.styleFrom(elevation: 0),
                  ),
                  if (_bannerImage != null) ...[
                    const SizedBox(width: AppSpacing.md),
                    TextButton.icon(
                      onPressed: () => setState(() => _bannerImage = null),
                      icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.error),
                      label: const Text('Cancel Upload', style: TextStyle(color: AppColors.error)),
                    ),
                  ],
                ],
              ),
            ],
            
            const SizedBox(height: AppSpacing.xl),
            if (canEdit && (_logoImage != null || _bannerImage != null))
              SizedBox(
                width: double.infinity,
                height: 44,
                child: FilledButton.icon(
                  onPressed: _isSavingBranding ? null : () => _saveBranding(org.id),
                  icon: _isSavingBranding
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.cloud_upload_rounded, size: 18),
                  label: Text(_isSavingBranding ? 'Saving Images...' : 'Upload & Save Branding'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(IconData icon) {
    return Container(
      color: Colors.grey.shade50,
      child: Center(
        child: Icon(icon, size: 32, color: Colors.grey.shade300),
      ),
    );
  }

  Widget _buildClearanceTab(
    OrganizationModel org, 
    AppRole? activeRole, 
    OrganizationMembershipModel? activeMembership
  ) {
    final isGovernorOrAdviser = activeRole?.roleName == 'Governor' || 
                                activeRole?.roleName == 'President' || 
                                activeRole?.roleName == 'Super Admin' ||
                                activeRole?.roleName == 'Adviser';
                                
    final isSecretaryOrTreasurer = activeRole?.roleName == 'Secretary' || 
                                   activeRole?.roleName == 'Treasurer';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.border),
          ),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Workflow Rules',
                  style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Define how student clearances are submitted, approved, and tracked.',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey),
                ),
                const SizedBox(height: AppSpacing.xl),
                
                if (isGovernorOrAdviser) ...[
                  _buildSwitchTilePremium(
                    title: 'Clearance Period Active',
                    subtitle: 'Allow student members to submit clearance requests. If disabled, members cannot request clearances.',
                    value: _isClearanceActive ?? org.isClearanceActive,
                    icon: Icons.power_settings_new_rounded,
                    onChanged: (value) async {
                      setState(() => _isClearanceActive = value);
                      try {
                        final success = await ref.read(organizationControllerProvider.notifier).updateOrganization(
                          id: org.id,
                          name: org.name,
                          code: org.code,
                          description: org.description ?? '',
                          adviserName: org.adviserName,
                          logoUrl: org.logoUrl,
                          bannerUrl: org.bannerUrl,
                          isClearanceActive: value,
                        );
                        if (success && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(value 
                                  ? 'Clearance requests are now enabled for all members.' 
                                  : 'Clearance requests are now locked.'),
                            ),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    },
                  ),
                  const Divider(height: AppSpacing.xl),
                  _buildSwitchTilePremium(
                    title: 'Require Adviser Signature',
                    subtitle: 'Students will need a final signature from their Adviser/Instructor on their activity card after officers sign.',
                    value: _requiresAdviserSignature ?? org.requiresAdviserSignature,
                    icon: Icons.assignment_turned_in_rounded,
                    onChanged: (value) async {
                      setState(() => _requiresAdviserSignature = value);
                      try {
                        final success = await ref.read(organizationControllerProvider.notifier).updateOrganization(
                          id: org.id,
                          name: org.name,
                          code: org.code,
                          description: org.description ?? '',
                          adviserName: org.adviserName,
                          logoUrl: org.logoUrl,
                          bannerUrl: org.bannerUrl,
                          requiresAdviserSignature: value,
                        );
                        if (success && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Adviser signature requirement updated successfully')),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    },
                  ),
                  const Divider(height: AppSpacing.xl),
                  _buildSwitchTilePremium(
                    title: 'Require Faculty Dean Signature',
                    subtitle: 'Students will need a signature from their Faculty Dean on their activity card after officers and adviser sign.',
                    value: _requiresFacultyDeanSignature ?? org.requiresFacultyDeanSignature,
                    icon: Icons.school_rounded,
                    onChanged: (value) async {
                      setState(() => _requiresFacultyDeanSignature = value);
                      try {
                        final success = await ref.read(organizationControllerProvider.notifier).updateOrganization(
                          id: org.id,
                          name: org.name,
                          code: org.code,
                          description: org.description ?? '',
                          adviserName: org.adviserName,
                          logoUrl: org.logoUrl,
                          bannerUrl: org.bannerUrl,
                          requiresFacultyDeanSignature: value,
                        );
                        if (success && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Faculty Dean signature requirement updated successfully')),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    },
                  ),
                  const Divider(height: AppSpacing.xl),
                ],
                
                if (activeMembership != null && (isGovernorOrAdviser || isSecretaryOrTreasurer)) ...[
                  _buildSwitchTilePremium(
                    title: 'Auto-Sign Clearances (My Office)',
                    subtitle: 'Automatically sign clearances when students have zero outstanding balance and no absences.',
                    value: activeMembership.autoSignClearance,
                    icon: Icons.bolt_rounded,
                    onChanged: (value) async {
                      try {
                        await SupabaseConfig.client
                            .from('organization_members')
                            .update({'auto_sign_clearance': value})
                            .eq('id', activeMembership.id);
                        ref.invalidate(workspaceProvider);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('My office signing preferences updated successfully')),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error updating preferences: $e')),
                        );
                      }
                    },
                  ),
                ],
                
                if (activeRole?.roleName == 'Secretary' || activeRole?.roleName == 'Governor' || activeRole?.roleName == 'President' || activeRole?.roleName == 'Super Admin') ...[
                  const Divider(height: AppSpacing.xl),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.gavel_rounded, color: AppColors.primary, size: 20),
                    ),
                    title: Text('Configure Sanction Rules', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                    subtitle: Text('Define cash or item donations based on student attendance/absences.', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey)),
                    trailing: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.chevron_right_rounded, size: 18),
                    ),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SanctionRulesPage())),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildWorkflowDiagramCard(
          _requiresAdviserSignature ?? org.requiresAdviserSignature,
          _requiresFacultyDeanSignature ?? org.requiresFacultyDeanSignature,
        ),
      ],
    );
  }

  Widget _buildSwitchTilePremium({
    required String title,
    required String subtitle,
    required bool value,
    required IconData icon,
    required Function(bool) onChanged,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(subtitle, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey)),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildWorkflowDiagramCard(bool requiresAdviser, bool requiresFacultyDean) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Clearance Approval Path',
              style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
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
        color: isSkipped ? Colors.grey.shade50 : color.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSkipped
              ? Colors.grey.shade200
              : (isCompleted ? color : color.withOpacity(0.2)),
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

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
        ),
      ),
    );
  }
}
