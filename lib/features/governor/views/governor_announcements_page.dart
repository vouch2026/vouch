import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../../users/widgets/user_management_header.dart';
import '../models/governor_announcement_mock_data.dart';
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
            child: _buildAnnouncementList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementList() {
    final query = _searchController.text.toLowerCase();
    final filtered = GovernorAnnouncementMockData.announcements.where((a) {
      final matchesCategory = _selectedCategory == 'All' || a['category'] == _selectedCategory;
      final matchesQuery = a['title']!.toLowerCase().contains(query) ||
                          a['content']!.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();

    // Sort: Pinned first, then by date (mock data is already sorted by date)
    filtered.sort((a, b) {
      if (a['isPinned'] == b['isPinned']) return 0;
      return a['isPinned'] == true ? -1 : 1;
    });

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
            onDelete: () {},
          ),
        );
      },
    );
  }

  void _navigateToCreate(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const GovernorCreateAnnouncementPage()));
  }
}
