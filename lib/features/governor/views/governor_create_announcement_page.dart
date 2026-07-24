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
  final List<TextEditingController> _linkControllers = [];
  
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
    if (widget.initialData?.linkUrls != null && widget.initialData!.linkUrls!.isNotEmpty) {
      for (final link in widget.initialData!.linkUrls!) {
        _linkControllers.add(TextEditingController(text: link));
      }
    } else {
      _linkControllers.add(TextEditingController());
    }
    _selectedType = widget.initialData?.type ?? 'General';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    for (final controller in _linkControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final name = pickedFile.name.toLowerCase();
      if (!name.endsWith('.jpg') && 
          !name.endsWith('.jpeg') && 
          !name.endsWith('.png') && 
          !name.endsWith('.gif') && 
          !name.endsWith('.webp') && 
          !name.endsWith('.bmp')) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid file format. Please upload an image (JPG, PNG, WEBP, etc.)')),
          );
        }
        return;
      }
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

      final linkUrls = _linkControllers
          .map((c) => c.text.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      final announcement = AnnouncementModel(
        id: widget.initialData?.id,
        title: _titleController.text,
        content: _contentController.text,
        type: _selectedType,
        linkUrls: linkUrls.isNotEmpty ? linkUrls : null,
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
        context.pop(true);
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
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;

    return DashboardLayout(
      title: isEdit ? 'Edit Announcement' : 'Post Announcement',
      onBack: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/workspace/announcements');
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.campaign_outlined, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/workspace/announcements');
                    }
                  },
                  child: Text(
                    'Announcements',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right_rounded, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 8),
                Text(
                  isEdit ? 'Edit Announcement' : 'Create Announcement',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
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
                    if (!isMobile)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _buildLeftFields(context),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xl),
                          Expanded(
                            flex: 4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _buildRightFields(context, theme),
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ..._buildLeftFields(context),
                          const SizedBox(height: AppSpacing.lg),
                          ..._buildRightFields(context, theme),
                        ],
                      ),
                    const SizedBox(height: AppSpacing.xxl),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isLoading ? null : () => context.pop(),
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
          ],
        ),
      ),
    );
  }

  List<Widget> _buildLeftFields(BuildContext context) {
    return [
      _buildSectionTitle('Announcement Content'),
      const SizedBox(height: AppSpacing.md),
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
      const SizedBox(height: AppSpacing.lg),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildLabel('Reference Links (Optional)'),
          TextButton.icon(
            onPressed: () {
              setState(() {
                _linkControllers.add(TextEditingController());
              });
            },
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add Link'),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
      ..._linkControllers.asMap().entries.map((entry) {
        final index = entry.key;
        final controller = entry.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: 'https://example.com',
                    prefixIcon: Icon(Icons.link_rounded),
                  ),
                ),
              ),
              if (_linkControllers.length > 1) ...[
                const SizedBox(width: AppSpacing.sm),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _linkControllers.removeAt(index);
                      controller.dispose();
                    });
                  },
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ],
          ),
        );
      }).toList(),
    ];
  }

  List<Widget> _buildRightFields(BuildContext context, ThemeData theme) {
    return [
      _buildSectionTitle('Visuals (Optional)'),
      const SizedBox(height: AppSpacing.md),
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
      const SizedBox(height: AppSpacing.xl),
      _buildSectionTitle('Settings'),
      const SizedBox(height: AppSpacing.md),
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
    ];
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
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
