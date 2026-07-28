import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:vouch_v2/core/theme/app_colors.dart';
import 'package:vouch_v2/core/theme/app_spacing.dart';
import 'package:vouch_v2/core/theme/app_text_styles.dart';
import 'package:vouch_v2/core/widgets/loaders/flickr_loader.dart';
import 'package:vouch_v2/features/events/models/event_model.dart';
import 'package:vouch_v2/features/events/providers/event_provider.dart';
import 'package:vouch_v2/features/events/views/event_highlights_gallery_page.dart';
import 'package:vouch_v2/features/organizations/providers/workspace_provider.dart';
import 'package:vouch_v2/shared/layouts/dashboard_layout.dart';

class GovernorGalleryPage extends ConsumerStatefulWidget {
  const GovernorGalleryPage({super.key});

  @override
  ConsumerState<GovernorGalleryPage> createState() => _GovernorGalleryPageState();
}

class _GovernorGalleryPageState extends ConsumerState<GovernorGalleryPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final workspace = ref.watch(workspaceProvider);
    final selectedOrg = workspace.selectedOrganization;
    final eventsAsync = ref.watch(workspaceEventsProvider);

    return DashboardLayout(
      title: 'Media Gallery',
      child: selectedOrg == null
          ? _buildNoOrgSelectedState()
          : eventsAsync.when(
              data: (events) {
                // Filter past events
                final pastEvents = events.where((e) => e.isPastTimeout).toList();
                
                // Search filter
                final filteredEvents = pastEvents.where((e) {
                  return e.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                      (e.location.toLowerCase().contains(_searchQuery.toLowerCase()));
                }).toList();

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Breadcrumb
                      Row(
                        children: [
                          Icon(Icons.photo_library_outlined, size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 8),
                          Text(
                            'Gallery',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      
                      // Heading Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Event Gallery Albums',
                                  style: AppTextStyles.displaySmall.copyWith(
                                    color: AppColors.textDark,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Browse past events and manage official highlight galleries',
                                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Premium Analytics Stats Row
                      _buildAnalyticsStatsRow(pastEvents),
                      const SizedBox(height: AppSpacing.xl),

                      // Search / Filters
                      _buildSearchAndFilters(),
                      const SizedBox(height: AppSpacing.lg),

                      // Albums Grid
                      filteredEvents.isEmpty
                          ? _buildEmptyState(pastEvents.isEmpty)
                          : _buildAlbumGrid(filteredEvents),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: FlickrLoader()),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 64),
                  child: Text(
                    'Error loading past events: $err',
                    style: AppTextStyles.bodyLarge.copyWith(color: AppColors.error),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildNoOrgSelectedState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.business_rounded, size: 48, color: Colors.grey),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'No Active Organization Selected',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Please select an organization workspace from the dashboard to view the gallery.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsStatsRow(List<EventModel> pastEvents) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Total Albums',
            value: '${pastEvents.length}',
            icon: Icons.folder_copy_rounded,
            gradientColors: [AppColors.primary, AppColors.primaryDark],
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: _buildStatCard(
            title: 'Events',
            value: '${pastEvents.where((e) => e.imageUrl != null && e.imageUrl!.isNotEmpty).length}',
            icon: Icons.star_rounded,
            gradientColors: [AppColors.accent, AppColors.accentLight],
            isDarkText: true,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required List<Color> gradientColors,
    bool isDarkText = false,
  }) {
    final textColor = isDarkText ? AppColors.textDark : AppColors.white;
    final subtextColor = isDarkText ? AppColors.textGrey : AppColors.white.withValues(alpha: 0.8);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.labelMedium.copyWith(
                  color: subtextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: AppTextStyles.displaySmall.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isDarkText ? Colors.black : Colors.white).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: textColor,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: AppColors.textGrey),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Search albums by event name or venue...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey.withValues(alpha: 0.7)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 18),
              onPressed: () {
                setState(() => _searchQuery = '');
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool noEventsAtAll) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 64),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                noEventsAtAll ? Icons.photo_library_outlined : Icons.search_off_rounded,
                size: 64,
                color: AppColors.primary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              noEventsAtAll ? 'No past events found' : 'No matching albums found',
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              noEventsAtAll
                  ? 'Only completed organization events will display album galleries.'
                  : 'Try adjusting your search criteria or clear the query.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlbumGrid(List<EventModel> events) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 2;
        if (constraints.maxWidth > 1200) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth > 800) {
          crossAxisCount = 3;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: AppSpacing.lg,
            mainAxisSpacing: AppSpacing.lg,
            childAspectRatio: 0.85,
          ),
          itemCount: events.length,
          itemBuilder: (context, index) {
            return _PastEventAlbumCard(event: events[index]);
          },
        );
      },
    );
  }
}

class _PastEventAlbumCard extends ConsumerStatefulWidget {
  final EventModel event;

  const _PastEventAlbumCard({required this.event});

  @override
  ConsumerState<_PastEventAlbumCard> createState() => _PastEventAlbumCardState();
}

class _PastEventAlbumCardState extends ConsumerState<_PastEventAlbumCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final highlightsAsync = ref.watch(eventAllHighlightsProvider(widget.event.id!));

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        transform: _isHovered ? Matrix4.translationValues(0, -6, 0) : Matrix4.identity(),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _isHovered
                ? AppColors.primary.withValues(alpha: 0.35)
                : AppColors.primary.withValues(alpha: 0.08),
            width: _isHovered ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _isHovered ? 0.12 : 0.04),
              blurRadius: _isHovered ? 24 : 12,
              offset: Offset(0, _isHovered ? 8 : 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EventHighlightsGalleryPage(
                  eventId: widget.event.id!,
                  eventName: widget.event.name,
                ),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover Image/Gradient area
              Expanded(
                flex: 5,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (widget.event.imageUrl != null && widget.event.imageUrl!.isNotEmpty)
                      Image.network(
                        widget.event.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildPlaceholderGradient(),
                      )
                    else
                      _buildPlaceholderGradient(),
                    
                    // Darkening Vignette
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.black.withValues(alpha: 0.4), Colors.transparent],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),

                    // Highlights count Badge
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.photo_library_rounded, color: Colors.white, size: 12),
                            const SizedBox(width: 4),
                            highlightsAsync.when(
                              data: (highlights) => Text(
                                '${highlights.length}',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              loading: () => const SizedBox(
                                width: 10,
                                height: 10,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              error: (error, stackTrace) => Text(
                                '0',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Title and Date Details
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.event.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 12, color: AppColors.textGrey),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  widget.event.location,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      
                      // Divider / Date Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat.yMMMMd().format(widget.event.eventDate),
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textGrey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 16,
                            color: _isHovered ? AppColors.primary : AppColors.textGrey,
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
      ),
    );
  }

  Widget _buildPlaceholderGradient() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.95),
            AppColors.primaryDark.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          color: Colors.white.withValues(alpha: 0.25),
          size: 48,
        ),
      ),
    );
  }
}
