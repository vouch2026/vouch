import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/layouts/dashboard_layout.dart';

class GovernorCreateAnnouncementPage extends ConsumerStatefulWidget {
  final Map<String, dynamic>? initialData;

  const GovernorCreateAnnouncementPage({super.key, this.initialData});

  @override
  ConsumerState<GovernorCreateAnnouncementPage> createState() => _GovernorCreateAnnouncementPageState();
}

class _GovernorCreateAnnouncementPageState extends ConsumerState<GovernorCreateAnnouncementPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  String _selectedCategory = 'General';
  bool _isPinned = false;

  final List<String> _categories = ['General', 'Urgent', 'Events', 'Academic', 'Others'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialData?['title']);
    _contentController = TextEditingController(text: widget.initialData?['content']);
    _selectedCategory = widget.initialData?['category'] ?? 'General';
    _isPinned = widget.initialData?['isPinned'] ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
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
              
              const SizedBox(height: AppSpacing.lg),
              
              _buildFormSection(
                context,
                title: 'SETTINGS',
                children: [
                  _buildLabel('Category'),
                  Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.md,
                    children: _categories.map((c) {
                      final isSelected = _selectedCategory == c;
                      return ChoiceChip(
                        label: Text(c),
                        selected: isSelected,
                        onSelected: (val) => setState(() => _selectedCategory = c),
                        selectedColor: theme.colorScheme.primaryContainer,
                        labelStyle: TextStyle(
                          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SwitchListTile(
                    title: const Text('Pin to Top', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Keep this announcement at the top of the feed'),
                    value: _isPinned,
                    onChanged: (v) => setState(() => _isPinned = v),
                    contentPadding: EdgeInsets.zero,
                    activeColor: theme.colorScheme.primary,
                  ),
                ],
              ),
              
              const SizedBox(height: AppSpacing.xxl),
              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Navigator.pop(context, true);
                        }
                      },
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      ),
                      child: Text(isEdit ? 'Update Post' : 'Post Announcement'),
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
