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
import '../../auth/providers/auth_provider.dart';
import '../../organizations/providers/workspace_provider.dart';
import '../providers/event_provider.dart';
import '../../../core/utils/file_saver_helper.dart';
import 'package:vouch_v2/core/providers/connectivity_provider.dart';
import 'package:vouch_v2/core/widgets/states/offline_state_view.dart';

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

class EventHighlightsGalleryPage extends ConsumerStatefulWidget {
  final String eventId;
  final String eventName;

  const EventHighlightsGalleryPage({
    super.key,
    required this.eventId,
    required this.eventName,
  });

  @override
  ConsumerState<EventHighlightsGalleryPage> createState() => _EventHighlightsGalleryPageState();
}

class _EventHighlightsGalleryPageState extends ConsumerState<EventHighlightsGalleryPage> {
  bool _isSelectionMode = false;
  final Set<String> _selectedFileNames = {};
  bool _isActionInProgress = false;

  Future<void> _deleteSelected(List<Map<String, dynamic>> highlights) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Selected Highlights'),
        content: Text('Are you sure you want to delete ${_selectedFileNames.length} selected highlight(s)? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isActionInProgress = true);

    try {
      final storageService = ref.read(storageServiceProvider);
      final bucket = dotenv.get('SUPABASE_HIGHLIGHTS_BUCKET', fallback: 'highlight-pictures');
      final folder = 'highlights/${widget.eventId}';
      
      final pathsToDelete = _selectedFileNames.map((fileName) => '$folder/$fileName').toList();
      await storageService.deleteFiles(bucket: bucket, paths: pathsToDelete);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully deleted ${_selectedFileNames.length} highlight(s).')),
        );
        ref.invalidate(eventAllHighlightsProvider(widget.eventId));
        ref.invalidate(eventHighlightsProvider(widget.eventId));
        setState(() {
          _selectedFileNames.clear();
          _isSelectionMode = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete highlights: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isActionInProgress = false);
    }
  }

  Future<void> _downloadSelected(List<Map<String, dynamic>> highlights) async {
    setState(() => _isActionInProgress = true);
    int successCount = 0;
    try {
      final storageService = ref.read(storageServiceProvider);
      final bucket = dotenv.get('SUPABASE_HIGHLIGHTS_BUCKET', fallback: 'highlight-pictures');
      final folder = 'highlights/${widget.eventId}';

      for (final fileName in _selectedFileNames) {
        final path = '$folder/$fileName';
        final bytes = await storageService.downloadFile(bucket: bucket, path: path);
        final isSuccess = await FileSaverUtil.saveFile(bytes, fileName);
        if (isSuccess) successCount++;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully downloaded $successCount highlight(s).')),
        );
        setState(() {
          _selectedFileNames.clear();
          _isSelectionMode = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to download highlights: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isActionInProgress = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = ref.watch(connectivityProvider).value ?? true;

    if (!isOnline) {
      return DashboardLayout(
        title: 'Highlights Gallery',
        onBack: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        },
        child: OfflineStateView(
          title: 'Gallery Offline',
          message: 'Viewing and downloading event highlights requires internet access. Please reconnect and try again.',
          onRetry: () {
            ref.invalidate(connectivityProvider);
          },
          onGoBack: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
      );
    }

    final highlightsAsync = ref.watch(eventAllHighlightsProvider(widget.eventId));
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
                    widget.eventName,
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
            
            highlightsAsync.when(
              data: (highlights) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Highlights Gallery',
                            style: AppTextStyles.headlineMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Moments shared by members for ${widget.eventName}',
                            style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    if (highlights.isNotEmpty)
                      OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _isSelectionMode = !_isSelectionMode;
                            _selectedFileNames.clear();
                          });
                        },
                        icon: Icon(_isSelectionMode ? Icons.close : Icons.playlist_add_check_rounded),
                        label: Text(_isSelectionMode ? 'Cancel' : 'Select'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                        ),
                      ),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
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
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_isSelectionMode) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  '${_selectedFileNames.length} selected',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const Spacer(),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      if (_selectedFileNames.length == highlights.length) {
                                        _selectedFileNames.clear();
                                      } else {
                                        _selectedFileNames.addAll(highlights.map((h) => h['name'] as String));
                                      }
                                    });
                                  },
                                  child: Text(
                                    _selectedFileNames.length == highlights.length ? 'Deselect All' : 'Select All',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                ElevatedButton.icon(
                                  onPressed: _selectedFileNames.isEmpty || _isActionInProgress
                                      ? null
                                      : () => _downloadSelected(highlights),
                                  icon: _isActionInProgress
                                      ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                      : const Icon(Icons.download_rounded, size: 16),
                                  label: const Text('Download'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                ElevatedButton.icon(
                                  onPressed: _selectedFileNames.isEmpty || _isActionInProgress
                                      ? null
                                      : () => _deleteSelected(highlights),
                                  icon: _isActionInProgress
                                      ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                      : const Icon(Icons.delete_outline_rounded, size: 16),
                                  label: const Text('Delete'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.error,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                        ],
                        LayoutBuilder(
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

                                final isSelected = _selectedFileNames.contains(highlight['name']);

                                return _HighlightCard(
                                  highlight: highlight,
                                  uploader: uploader,
                                  isSelected: isSelected,
                                  isSelectionMode: _isSelectionMode,
                                  onTap: () {
                                    if (_isSelectionMode) {
                                      setState(() {
                                        if (isSelected) {
                                          _selectedFileNames.remove(highlight['name'] as String);
                                        } else {
                                          _selectedFileNames.add(highlight['name'] as String);
                                        }
                                      });
                                    } else {
                                      _openGalleryOverlay(context, highlights, users, index);
                                    }
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ],
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
            eventId: widget.eventId,
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
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onTap;

  const _HighlightCard({
    required this.highlight,
    required this.uploader,
    required this.isSelected,
    required this.isSelectionMode,
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
            color: widget.isSelected
                ? AppColors.primary
                : (_isHovered 
                    ? AppColors.primary.withValues(alpha: 0.3) 
                    : AppColors.primary.withValues(alpha: 0.1)),
            width: widget.isSelected || _isHovered ? 1.5 : 1,
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
                    if (widget.isSelectionMode)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          decoration: BoxDecoration(
                            color: widget.isSelected 
                                ? AppColors.primary 
                                : Colors.black.withOpacity(0.4),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            widget.isSelected ? Icons.check : null,
                            size: 16,
                            color: Colors.white,
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

class _FullScreenGalleryOverlay extends ConsumerStatefulWidget {
  final String eventId;
  final List<Map<String, dynamic>> highlights;
  final List<UserModel> users;
  final int initialIndex;

  const _FullScreenGalleryOverlay({
    required this.eventId,
    required this.highlights,
    required this.users,
    required this.initialIndex,
  });

  @override
  ConsumerState<_FullScreenGalleryOverlay> createState() => _FullScreenGalleryOverlayState();
}

class _FullScreenGalleryOverlayState extends ConsumerState<_FullScreenGalleryOverlay> {
  late PageController _pageController;
  late int _currentIndex;
  bool _isActionInProgress = false;

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

  Future<void> _downloadImage(Map<String, dynamic> highlight) async {
    setState(() => _isActionInProgress = true);
    try {
      final storageService = ref.read(storageServiceProvider);
      final bucket = dotenv.get('SUPABASE_HIGHLIGHTS_BUCKET', fallback: 'highlight-pictures');
      final fileName = highlight['name'] as String;
      final folder = 'highlights/${widget.eventId}';
      final path = '$folder/$fileName';

      final bytes = await storageService.downloadFile(bucket: bucket, path: path);
      final isSuccess = await FileSaverUtil.saveFile(bytes, fileName);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isSuccess ? 'Image downloaded successfully.' : 'Failed to save image.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to download image: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isActionInProgress = false);
    }
  }

  Future<void> _deleteImage(Map<String, dynamic> highlight) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Highlight'),
        content: const Text('Are you sure you want to delete this highlight? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isActionInProgress = true);
    try {
      final storageService = ref.read(storageServiceProvider);
      final bucket = dotenv.get('SUPABASE_HIGHLIGHTS_BUCKET', fallback: 'highlight-pictures');
      final fileName = highlight['name'] as String;
      final folder = 'highlights/${widget.eventId}';
      final path = '$folder/$fileName';

      await storageService.deleteFiles(bucket: bucket, paths: [path]);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Highlight deleted successfully.')),
        );
        ref.invalidate(eventAllHighlightsProvider(widget.eventId));
        ref.invalidate(eventHighlightsProvider(widget.eventId));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete highlight: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isActionInProgress = false);
    }
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

    final currentUser = ref.watch(userProfileProvider).value;
    final workspace = ref.watch(workspaceProvider);
    final activeRole = workspace.activeRole;
    final canDelete = currentUser != null && (
      highlight['userId'] == currentUser.id ||
      (activeRole != null && activeRole.roleName != 'Member')
    );

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
                    const SizedBox(width: AppSpacing.md),
                    IconButton(
                      icon: _isActionInProgress
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.download_rounded, color: Colors.white),
                      tooltip: 'Download',
                      onPressed: _isActionInProgress ? null : () => _downloadImage(highlight),
                    ),
                    if (canDelete) ...[
                      const SizedBox(width: AppSpacing.sm),
                      IconButton(
                        icon: _isActionInProgress
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                        tooltip: 'Delete',
                        onPressed: _isActionInProgress ? null : () => _deleteImage(highlight),
                      ),
                    ],
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
