import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../../academic_structure/providers/term_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../organizations/providers/workspace_provider.dart';
import '../../announcements/models/announcement_model.dart';
import '../../announcements/repositories/announcement_repository.dart';
import '../../announcements/providers/announcement_provider.dart';

class GovernorCreateAnnouncementPage extends ConsumerStatefulWidget {
  final AnnouncementModel? initialData;

  const GovernorCreateAnnouncementPage({super.key, this.initialData});

  @override
  ConsumerState<GovernorCreateAnnouncementPage> createState() => _GovernorCreateAnnouncementPageState();
}

class _GovernorCreateAnnouncementPageState extends ConsumerState<GovernorCreateAnnouncementPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialData?.title);
    _contentController = TextEditingController(text: widget.initialData?.content);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final workspace = ref.read(workspaceProvider);
      final org = workspace.selectedOrganization!;
      final user = ref.read(userProfileProvider).value!;
      final activeTerm = await ref.read(activeTermProvider.future);

      if (activeTerm == null) {
        throw Exception('No active academic term found. Please contact an administrator.');
      }

      final scopeType = org.type == 'campus-based' 
          ? 'Institutional' 
          : (org.type == 'faculty-based' ? 'Faculty' : 'Program');
      
      final scopeId = org.type == 'campus-based' 
          ? org.campusId 
          : (org.type == 'faculty-based' ? org.facultyId : org.programId);

      final announcement = AnnouncementModel(
        id: widget.initialData?.id,
        title: _titleController.text,
        content: _contentController.text,
        scopeType: scopeType,
        scopeId: scopeId!,
        academicTermId: activeTerm.id,
        createdByUserId: user.id,
      );

      if (widget.initialData != null) {
        await ref.read(announcementRepositoryProvider).updateAnnouncement(announcement);
      } else {
        await ref.read(announcementRepositoryProvider).createAnnouncement(announcement);
      }

      if (mounted) {
        ref.invalidate(workspaceAnnouncementsProvider);
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Announcement ${widget.initialData != null ? 'updated' : 'posted'} successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.initialData != null;

    return DashboardLayout(
      title: isEdit ? 'Edit Announcement' : 'Post Announcement',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEdit ? 'Update Announcement' : 'Write New Announcement',
                style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Share important updates, events, or news with your organization members.',
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: AppSpacing.xl),
              
              _buildFormSection(
                context,
                title: 'CONTENT',
                children: [
                  _buildLabel('Announcement Title'),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: 'e.g., Orientation Schedule, Holiday Notice',
                      prefixIcon: Icon(Icons.campaign_outlined),
                    ),
                    validator: (v) => v?.isEmpty == true ? 'Title is required' : null,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildLabel('Message Content'),
                  TextFormField(
                    controller: _contentController,
                    maxLines: 8,
                    decoration: const InputDecoration(
                      hintText: 'Enter the full message details here...',
                      alignLabelWithHint: true,
                    ),
                    validator: (v) => v?.isEmpty == true ? 'Content is required' : null,
                  ),
                ],
              ),
              
              const SizedBox(height: AppSpacing.xxl),
              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: FilledButton(
                      onPressed: _isLoading ? null : _submit,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      ),
                      child: _isLoading 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(isEdit ? 'Update Post' : 'Post Announcement'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormSection(BuildContext context, {required String title, required List<Widget> children}) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.labelSmall.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ...children,
        ],
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}
