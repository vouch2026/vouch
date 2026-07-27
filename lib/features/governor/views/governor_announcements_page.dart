import 'package:vouch_v2/core/widgets/loaders/flickr_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../../../routes/route_paths.dart';
import '../../users/widgets/user_management_header.dart';
import '../../announcements/models/announcement_model.dart';
import '../../announcements/providers/announcement_provider.dart';
import '../../organizations/providers/workspace_provider.dart';
import '../widgets/governor_announcement_card.dart';
import '../../../core/widgets/states/offline_state_view.dart';

class GovernorAnnouncementsPage extends ConsumerStatefulWidget {
  const GovernorAnnouncementsPage({super.key});

  @override
  ConsumerState<GovernorAnnouncementsPage> createState() => _GovernorAnnouncementsPageState();
}

class _GovernorAnnouncementsPageState extends ConsumerState<GovernorAnnouncementsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'General', 'Urgent', 'Events', 'Fees', 'Academic', 'Others'];

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
    final workspace = ref.watch(workspaceProvider);
    final org = workspace.selectedOrganization;
    final activeRole = workspace.activeRole?.roleName;
    final canPost = activeRole != 'Student' && activeRole != 'Member';

    return DashboardLayout(
      title: 'Organization Announcements',
      child: announcementsAsync.when(
        data: (announcements) {
          final query = _searchController.text.toLowerCase();
          final filtered = announcements.where((a) {
            final matchesCategory = _selectedCategory == 'All' || a.type == _selectedCategory; 
            final matchesQuery = a.title.toLowerCase().contains(query) ||
                                a.content.toLowerCase().contains(query);
            return matchesCategory && matchesQuery;
          }).toList();

          return LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 768;
              int crossAxisCount = 1;
              if (constraints.maxWidth > 1200) {
                crossAxisCount = 4;
              } else if (constraints.maxWidth > 900) {
                crossAxisCount = 3;
              } else if (constraints.maxWidth > 600) {
                crossAxisCount = 2;
              }

              return RefreshIndicator(
                onRefresh: () => ref.refresh(workspaceAnnouncementsProvider.future),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? AppSpacing.lg : AppSpacing.xl,
                    vertical: isMobile ? AppSpacing.lg : AppSpacing.xl,
                  ),
                  children: [
                    Row(
                      children: [
                        Icon(Icons.campaign_outlined, size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 8),
                        Text(
                          'Announcements',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    UserManagementHeader(
                      title: 'Announcements',
                      subtitle: 'Broadcast important updates and news to your members',
                      actions: [
                        if (canPost)
                          HeaderActionButton(
                            icon: Icons.add_comment_rounded,
                            label: 'Post Announcement',
                            onPressed: () => context.push(RoutePaths.workspaceCreateAnnouncement),
                            isPrimary: true,
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    
                    if (org != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: Text(
                          'Scope: ${org.type.replaceAll('-', ' ').toUpperCase()} | Total Found: ${announcements.length}',
                          style: AppTextStyles.labelSmall.copyWith(color: Colors.grey[500]),
                        ),
                      ),

                    // Filters & Search Section
                    if (isMobile) ...[
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search announcements...',
                          prefixIcon: const Icon(Icons.search_rounded),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildCategoryFilters(theme),
                    ] else
                      Row(
                        children: [
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: constraints.maxWidth * 0.6,
                            ),
                            child: _buildCategoryFilters(theme),
                          ),
                          const SizedBox(width: AppSpacing.md),
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
                    
                    const SizedBox(height: AppSpacing.xl),

                    if (filtered.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 64),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.campaign_outlined, size: 64, color: Colors.grey[300]),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                announcements.isEmpty 
                                  ? 'No announcements found in this scope' 
                                  : 'No announcements match your filters',
                                style: AppTextStyles.bodyLarge.copyWith(color: Colors.grey[600], fontWeight: FontWeight.bold),
                              ),
                              if (announcements.isNotEmpty)
                                TextButton(
                                  onPressed: () => setState(() => _selectedCategory = 'All'),
                                  child: const Text('Clear Filters'),
                                ),
                            ],
                          ),
                        ),
                      )
                    else
                      _buildMasonryGrid(filtered, crossAxisCount),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: FlickrLoader()),
        error: (err, _) {
          if (OfflineStateView.isOfflineError(err)) {
            return OfflineStateView(
              onRetry: () => ref.invalidate(workspaceAnnouncementsProvider),
            );
          }
          return Center(child: Text('Error: $err'));
        },
      ),
    );
  }

  Widget _buildCategoryFilters(ThemeData theme) {
    return SingleChildScrollView(
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
    );
  }

  Widget _buildMasonryGrid(List<AnnouncementModel> announcements, int crossAxisCount) {
    if (crossAxisCount <= 1) {
      return Column(
        children: announcements.map((a) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
          child: GovernorAnnouncementCard(
            key: ValueKey(a.id),
            announcement: a,
            onPin: () {},
            onDelete: () => _deleteAnnouncement(a.id!),
          ),
        )).toList(),
      );
    }

    final List<List<AnnouncementModel>> columns = List.generate(crossAxisCount, (_) => []);
    for (int i = 0; i < announcements.length; i++) {
      columns[i % crossAxisCount].add(announcements[i]);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: columns.asMap().entries.map((entry) {
        final idx = entry.key;
        final col = entry.value;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: idx == 0 ? 0 : AppSpacing.lg / 2,
              right: idx == crossAxisCount - 1 ? 0 : AppSpacing.lg / 2,
            ),
            child: Column(
              children: col.map((a) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: GovernorAnnouncementCard(
                  key: ValueKey(a.id),
                  announcement: a,
                  onPin: () {},
                  onDelete: () => _deleteAnnouncement(a.id!),
                ),
              )).toList(),
            ),
          ),
        );
      }).toList(),
    );
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
