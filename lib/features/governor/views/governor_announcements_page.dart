import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../../users/widgets/user_management_header.dart';
import '../../announcements/models/announcement_model.dart';
import '../../announcements/providers/announcement_provider.dart';
import '../widgets/governor_announcement_card.dart';
import 'governor_create_announcement_page.dart';

class GovernorAnnouncementsPage extends ConsumerStatefulWidget {
  const GovernorAnnouncementsPage({super.key});

  @override
  ConsumerState<GovernorAnnouncementsPage> createState() => _GovernorAnnouncementsPageState();
}

class _GovernorAnnouncementsPageState extends ConsumerState<GovernorAnnouncementsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'General', 'Urgent', 'Events', 'Academic'];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final announcementsAsync = ref.watch(workspaceAnnouncementsProvider);

    return DashboardLayout(
      title: 'Organization Announcements',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: UserManagementHeader(
              title: 'Announcements',
              subtitle: 'Broadcast important updates and news to your members',
              actions: [
                HeaderActionButton(
                  icon: Icons.add_comment_rounded,
                  label: 'Post Announcement',
                  onPressed: () => _navigateToCreate(context),
                  isPrimary: true,
                ),
              ],
            ),
          ),

          // Filters & Search Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search announcements...',
                          prefixIcon: const Icon(Icons.search_rounded),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((c) {
                      final isSelected = _selectedCategory == c;
                      return Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: ChoiceChip(
                          label: Text(c),
                          selected: isSelected,
                          onSelected: (val) => setState(() => _selectedCategory = c),
                          selectedColor: theme.colorScheme.primaryContainer,
                          labelStyle: TextStyle(
                            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          Expanded(
            child: announcementsAsync.when(
              data: (announcements) => _buildAnnouncementList(announcements),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementList(List<AnnouncementModel> announcements) {
    final query = _searchController.text.toLowerCase();
    final filtered = announcements.where((a) {
      // Category is currently placeholder in the model/db
      final matchesCategory = _selectedCategory == 'All'; 
      final matchesQuery = a.title.toLowerCase().contains(query) ||
                          a.content.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.campaign_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No announcements found',
              style: AppTextStyles.bodyLarge.copyWith(color: Colors.grey[600], fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 1;
        if (constraints.maxWidth > 1200) {
          crossAxisCount = 3;
        } else if (constraints.maxWidth > 700) {
          crossAxisCount = 2;
        }

        return GridView.builder(
          padding: const EdgeInsets.all(AppSpacing.lg),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: AppSpacing.lg,
            mainAxisSpacing: AppSpacing.lg,
            mainAxisExtent: 260,
          ),
          itemCount: filtered.length,
          itemBuilder: (context, index) => GovernorAnnouncementCard(
            announcement: filtered[index],
            onPin: () {},
            onDelete: () => _deleteAnnouncement(filtered[index].id!),
          ),
        );
      },
    );
  }

  void _navigateToCreate(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const GovernorCreateAnnouncementPage()));
  }

  Future<void> _deleteAnnouncement(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Announcement'),
        content: const Text('Are you sure you want to delete this announcement? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(announcementRepositoryProvider).deleteAnnouncement(id);
        ref.invalidate(workspaceAnnouncementsProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Announcement deleted successfully')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }
}
