import 'package:vouch_v2/core/widgets/loaders/flickr_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/providers/storage_provider.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../../../shared/layouts/responsive_layout.dart';
import '../../users/providers/users_provider.dart';
import '../../auth/models/user_model.dart';

final eventAllHighlightsProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, eventId) async {
  final storageService = ref.read(storageServiceProvider);
  final bucket = dotenv.get('SUPABASE_HIGHLIGHTS_BUCKET', fallback: 'highlight-pictures');
  final folder = 'highlights/$eventId';
  
  try {
    final files = await storageService.listFiles(bucket: bucket, folder: folder);
    
    final highlights = <Map<String, dynamic>>[];
    for (final file in files) {
      if (file.name == '.emptyFolderPlaceholder') continue;
      
      final publicUrl = storageService.getPublicUrl(bucket, '$folder/${file.name}');
      
      String? userId;
      DateTime? timestamp;
      try {
        final parts = file.name.split('_');
        if (parts.length >= 4) {
          userId = parts[2];
          final timeStr = parts[3].split('.').first;
          timestamp = DateTime.fromMillisecondsSinceEpoch(int.parse(timeStr));
        }
      } catch (_) {}
      
      highlights.add({
        'name': file.name,
        'url': publicUrl,
        'userId': userId,
        'timestamp': timestamp ?? (file.createdAt != null ? DateTime.parse(file.createdAt!) : null),
      });
    }
    
    highlights.sort((a, b) {
      final tA = a['timestamp'] as DateTime?;
      final tB = b['timestamp'] as DateTime?;
      if (tA == null && tB == null) return 0;
      if (tA == null) return 1;
      if (tB == null) return -1;
      return tB.compareTo(tA);
    });
    
    return highlights;
  } catch (e) {
    return [];
  }
});

class EventHighlightsGalleryPage extends ConsumerWidget {
  final String eventId;
  final String eventName;

  const EventHighlightsGalleryPage({
    super.key,
    required this.eventId,
    required this.eventName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final highlightsAsync = ref.watch(eventAllHighlightsProvider(eventId));
    final usersAsync = ref.watch(allUsersProvider);
    final isMobile = ResponsiveLayout.isMobile(context);

    return DashboardLayout(
      title: 'Highlights Gallery',
      onBack: () {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? AppSpacing.lg : AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Breadcrumbs / Header
            Row(
              children: [
                Icon(Icons.event_note_rounded, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 6),
                InkWell(
                  onTap: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    'Events',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.chevron_right_rounded, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 6),
                InkWell(
                  onTap: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    eventName,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.chevron_right_rounded, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Highlights Gallery',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            
            Text(
              'Highlights Gallery',
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Moments shared by members for $eventName',
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: AppSpacing.xl),

            highlightsAsync.when(
              data: (highlights) {
                if (highlights.isEmpty) {
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
                            child: const Icon(
                              Icons.no_photography_rounded,
                              size: 64,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            'No highlights uploaded yet',
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Members haven\'t shared any photos for this event.',
                            style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return usersAsync.when(
                  data: (users) {
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount = 2;
                        if (constraints.maxWidth > 1200) {
                          crossAxisCount = 5;
                        } else if (constraints.maxWidth > 900) {
                          crossAxisCount = 4;
                        } else if (constraints.maxWidth > 600) {
                          crossAxisCount = 3;
                        }

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: AppSpacing.lg,
                            mainAxisSpacing: AppSpacing.lg,
                            childAspectRatio: 0.82,
                          ),
                          itemCount: highlights.length,
                          itemBuilder: (context, index) {
                            final highlight = highlights[index];
                            final userId = highlight['userId'] as String?;
                            final uploader = users.firstWhere(
                              (u) => u.id == userId,
                              orElse: () => UserModel(
                                authId: '',
                                email: '',
                                schoolId: '',
                                firstName: 'Unknown',
                                lastName: 'Member',
                              ),
                            );

                            return _HighlightCard(
                              highlight: highlight,
                              uploader: uploader,
                              onTap: () => _openGalleryOverlay(context, highlights, users, index),
                            );
                          },
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: FlickrLoader()),
                  error: (err, _) => Center(child: Text('Error: $err')),
                );
              },
              loading: () => const Center(child: FlickrLoader()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ],
        ),
      ),
    );
  }

  void _openGalleryOverlay(
    BuildContext context, 
    List<Map<String, dynamic>> highlights, 
    List<UserModel> users,
    int initialIndex,
  ) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        pageBuilder: (context, _, __) {
          return _FullScreenGalleryOverlay(
            highlights: highlights,
            users: users,
            initialIndex: initialIndex,
          );
        },
      ),
    );
  }
}

class _HighlightCard extends StatefulWidget {
  final Map<String, dynamic> highlight;
  final UserModel uploader;
  final VoidCallback onTap;

  const _HighlightCard({
    required this.highlight,
    required this.uploader,
    required this.onTap,
  });

  @override
  State<_HighlightCard> createState() => _HighlightCardState();
}

class _HighlightCardState extends State<_HighlightCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timestamp = widget.highlight['timestamp'] as DateTime?;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        transform: _isHovered ? Matrix4.translationValues(0, -6, 0) : Matrix4.identity(),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _isHovered 
                ? AppColors.primary.withValues(alpha: 0.3) 
                : AppColors.primary.withValues(alpha: 0.1),
            width: _isHovered ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _isHovered ? 0.12 : 0.06),
              blurRadius: _isHovered ? 20 : 12,
              offset: Offset(0, _isHovered ? 8 : 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: widget.onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: theme.colorScheme.surfaceVariant,
                      child: Image.network(
                        widget.highlight['url'] as String,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(child: FlickrLoader());
                        },
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.broken_image_outlined, color: Colors.grey),
                        ),
                      ),
                    ),
                    if (timestamp != null)
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            DateFormat.jm().format(timestamp),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.uploader.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.uploader.programName ?? widget.uploader.roleDisplay,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.grey[600],
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FullScreenGalleryOverlay extends StatefulWidget {
  final List<Map<String, dynamic>> highlights;
  final List<UserModel> users;
  final int initialIndex;

  const _FullScreenGalleryOverlay({
    required this.highlights,
    required this.users,
    required this.initialIndex,
  });

  @override
  State<_FullScreenGalleryOverlay> createState() => _FullScreenGalleryOverlayState();
}

class _FullScreenGalleryOverlayState extends State<_FullScreenGalleryOverlay> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final highlight = widget.highlights[_currentIndex];
    final userId = highlight['userId'] as String?;
    final uploader = widget.users.firstWhere(
      (u) => u.id == userId,
      orElse: () => UserModel(
        authId: '',
        email: '',
        schoolId: '',
        firstName: 'Unknown',
        lastName: 'Member',
      ),
    );
    final timestamp = highlight['timestamp'] as DateTime?;

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.9),
      body: SafeArea(
        child: Stack(
          children: [
            // Page View for sliding images
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.highlights.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return InteractiveViewer(
                    minScale: 1.0,
                    maxScale: 3.0,
                    child: Center(
                      child: Image.network(
                        widget.highlights[index]['url'] as String,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(child: FlickrLoader());
                        },
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.broken_image_outlined, color: Colors.white, size: 64),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Top bar controls
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${_currentIndex + 1} / ${widget.highlights.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // spacing spacer
                ],
              ),
            ),

            // Navigation arrows on desktop
            if (size.width > 700) ...[
              if (_currentIndex > 0)
                Positioned(
                  left: 24,
                  top: size.height / 2 - 24,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  ),
                ),
              if (_currentIndex < widget.highlights.length - 1)
                Positioned(
                  right: 24,
                  top: size.height / 2 - 24,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white),
                      onPressed: () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  ),
                ),
            ],

            // Bottom metadata panel
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            uploader.fullName,
                            style: AppTextStyles.titleMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${uploader.programName ?? uploader.roleDisplay} • ${uploader.schoolId}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.grey[400],
                            ),
                          ),
                          if (timestamp != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Uploaded ${DateFormat.yMMMMd().add_jm().format(timestamp)}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.grey[500],
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ],
                      ),
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
}
