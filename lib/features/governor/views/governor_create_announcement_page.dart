import 'package:vouch_v2/core/widgets/loaders/flickr_loader.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../../../core/providers/storage_provider.dart';
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
  late final TextEditingController _linkController;
  
  String _selectedType = 'General';
  XFile? _announcementImage;
  Uint8List? _announcementImageBytes;
  final _picker = ImagePicker();
  bool _isLoading = false;

  final List<String> _types = ['General', 'Urgent', 'Events', 'Fees', 'Academic', 'Others'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialData?.title);
    _contentController = TextEditingController(text: widget.initialData?.content);
    _linkController = TextEditingController(text: widget.initialData?.linkUrl);
    _selectedType = widget.initialData?.type ?? 'General';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _announcementImage = pickedFile;
        _announcementImageBytes = bytes;
      });
    }
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

      String? imageUrl = widget.initialData?.imageUrl;
      if (_announcementImage != null) {
        imageUrl = await ref.read(storageServiceProvider).uploadAnnouncementImage(
          file: _announcementImage!,
          title: _titleController.text,
        );
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
        type: _selectedType,
        linkUrl: _linkController.text.isNotEmpty ? _linkController.text : null,
        imageUrl: imageUrl,
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
                title: 'VISUALS (OPTIONAL)',
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: double.infinity,
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[300]!),
                        image: _announcementImageBytes != null
                            ? DecorationImage(image: MemoryImage(_announcementImageBytes!), fit: BoxFit.cover)
                            : (widget.initialData?.imageUrl != null
                                ? DecorationImage(image: NetworkImage(widget.initialData!.imageUrl!), fit: BoxFit.cover)
                                : null),
                      ),
                      child: _announcementImageBytes == null && widget.initialData?.imageUrl == null
                          ? const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate_outlined, size: 48, color: Colors.grey),
                                SizedBox(height: 8),
                                Text('Add an image (Optional)', style: TextStyle(color: Colors.grey)),
                              ],
                            )
                          : null,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppSpacing.lg),

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
                    maxLines: 6,
                    decoration: const InputDecoration(
                      hintText: 'Enter the full message details here...',
                      alignLabelWithHint: true,
                    ),
                    validator: (v) => v?.isEmpty == true ? 'Content is required' : null,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildLabel('Reference Link (Optional)'),
                  TextFormField(
                    controller: _linkController,
                    decoration: const InputDecoration(
                      hintText: 'https://example.com',
                      prefixIcon: Icon(Icons.link_rounded),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppSpacing.lg),
              
              _buildFormSection(
                context,
                title: 'SETTINGS',
                children: [
                  _buildLabel('Announcement Type'),
                  Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.md,
                    children: _types.map((t) {
                      final isSelected = _selectedType == t;
                      return ChoiceChip(
                        label: Text(t),
                        selected: isSelected,
                        onSelected: (val) => setState(() => _selectedType = t),
                        selectedColor: theme.colorScheme.primaryContainer,
                        labelStyle: TextStyle(
                          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      );
                    }).toList(),
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
                        ? const SizedBox(height: 20, width: 20, child: FlickrLoader())
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
