import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:ionicons/ionicons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_storage_service.dart';

typedef HighlightImage = ({String url, String path});

class AdminEventHighlightsScreen extends StatefulWidget {
  final String eventName;

  const AdminEventHighlightsScreen({
    super.key,
    required this.eventName,
  });

  @override
  State<AdminEventHighlightsScreen> createState() => _AdminEventHighlightsScreenState();
}

class _AdminEventHighlightsScreenState extends State<AdminEventHighlightsScreen> {
  static const Color royalBlue = Color(0xFF003DA5);
  static const Color gold = Color(0xFFFFC107);
  static const Color lightGray = Color(0xFFF5F5F5);
  static const Color darkGray = Color(0xFF666666);

  bool _isLoading = true;
  List<HighlightImage> _images = [];
  Set<String> _selectedPaths = {};
  bool _isSelectionMode = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchHighlights();
  }

  Future<void> _fetchHighlights() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _selectedPaths.clear();
      _isSelectionMode = false;
    });

    try {
      final bucketName = dotenv.env['SUPABASE_HIGHLIGHTS_BUCKET'] ?? 'highlight-pictures';
      final baseFolder = 'event_highlights/${widget.eventName}';

      final List<FileObject> userFolders = await SupabaseStorageService.instance.listFiles(
        bucketName: bucketName,
        folder: baseFolder,
      );

      List<HighlightImage> allImages = [];

      for (var folder in userFolders) {
        if (folder.id == null) {
          final userFolderPath = '$baseFolder/${folder.name}';
          final List<FileObject> files = await SupabaseStorageService.instance.listFiles(
            bucketName: bucketName,
            folder: userFolderPath,
          );

          for (var file in files) {
            if (file.id != null) {
              final String path = '$userFolderPath/${file.name}';
              final String? projectUrl = dotenv.env['SUPABASE_URL'];
              if (projectUrl == null) continue;
              
              final String encodedPath = path.split('/').map((segment) => Uri.encodeComponent(segment)).join('/');
              final String publicUrl = '$projectUrl/storage/v1/object/public/$bucketName/$encodedPath';
              allImages.add((url: publicUrl, path: path));
            }
          }
        }
      }

      if (mounted) {
        setState(() {
          _images = allImages;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load highlights: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedPaths.clear();
      }
    });
  }

  void _toggleImageSelection(String path) {
    setState(() {
      if (_selectedPaths.contains(path)) {
        _selectedPaths.remove(path);
        if (_selectedPaths.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedPaths.add(path);
        _isSelectionMode = true;
      }
    });
  }

  void _selectAll() {
    setState(() {
      if (_selectedPaths.length == _images.length) {
        _selectedPaths.clear();
        _isSelectionMode = false;
      } else {
        _selectedPaths = _images.map((img) => img.path).toSet();
        _isSelectionMode = true;
      }
    });
  }

  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
        return await Permission.photos.request().isGranted;
      } else {
        return await Permission.storage.request().isGranted;
      }
    } else {
      return await Permission.photos.request().isGranted;
    }
  }

  Future<bool> _deleteImages(List<String> paths) async {
    if (paths.isEmpty) return false;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Highlights'),
        content: Text('Are you sure you want to delete ${paths.length} image(s)?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return false;

    setState(() => _isLoading = true);

    try {
      final bucketName = dotenv.env['SUPABASE_HIGHLIGHTS_BUCKET'] ?? 'highlight-pictures';
      await SupabaseStorageService.instance.removeFiles(
        bucketName: bucketName,
        paths: paths,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully deleted ${paths.length} image(s)')),
        );
        await _fetchHighlights();
        return true;
      }
      return false;
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Failed to delete images: $e';
        });
      }
      return false;
    }
  }

  Future<void> _downloadImages(List<HighlightImage> items) async {
    if (items.isEmpty) return;

    if (!await _requestStoragePermission()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage/Photos permission is required to download images')),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    int successCount = 0;
    int failCount = 0;

    for (final item in items) {
      try {
        final response = await http.get(Uri.parse(item.url));
        if (response.statusCode == 200) {
          final result = await ImageGallerySaverPlus.saveImage(
            Uint8List.fromList(response.bodyBytes),
            quality: 100,
            name: "vouch_${DateTime.now().millisecondsSinceEpoch}",
          );
          if (result['isSuccess']) {
            successCount++;
          } else {
            failCount++;
          }
        } else {
          failCount++;
        }
      } catch (e) {
        failCount++;
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download complete: $successCount success, $failCount failed'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme);

    return Theme(
      data: Theme.of(context).copyWith(textTheme: textTheme),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Positioned(
              top: 100,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: gold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
            Positioned(
              bottom: 240,
              left: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: royalBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(75),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 10),
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator(color: royalBlue))
                        : _error != null
                            ? _buildErrorState()
                            : _images.isEmpty
                                ? _buildEmptyState()
                                : RefreshIndicator(
                                    color: royalBlue,
                                    onRefresh: _fetchHighlights,
                                    child: _buildGrid(),
                                  ),
                  ),
                ],
              ),
            ),
            if (_isSelectionMode) _buildSelectionActionBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
      child: SizedBox(
        height: 34,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () {
                  if (_isSelectionMode) {
                    _toggleSelectionMode();
                  } else {
                    Navigator.pop(context);
                  }
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  _isSelectionMode ? Ionicons.close : Ionicons.arrow_back,
                  color: royalBlue,
                ),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _isSelectionMode
                  ? Text(
                      '${_selectedPaths.length} Selected',
                      key: const ValueKey('selection_title'),
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: royalBlue,
                      ),
                    )
                  : RichText(
                      key: const ValueKey('normal_title'),
                      text: TextSpan(
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                        children: const [
                          TextSpan(
                            text: 'Event ',
                            style: TextStyle(color: royalBlue),
                          ),
                          TextSpan(
                            text: 'Highlights',
                            style: TextStyle(color: gold),
                          ),
                        ],
                      ),
                    ),
            ),
            if (_isSelectionMode)
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: _selectAll,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    _selectedPaths.length == _images.length
                        ? Ionicons.checkmark_circle
                        : Ionicons.checkmark_circle_outline,
                    color: royalBlue,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionActionBar() {
    return Positioned(
      bottom: 30,
      left: 20,
      right: 20,
      child: Container(
        height: 65,
        decoration: BoxDecoration(
          color: royalBlue,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: royalBlue.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildActionButton(
              icon: Ionicons.download_outline,
              label: 'Download',
              onPressed: () {
                final itemsToDownload = _images
                    .where((img) => _selectedPaths.contains(img.path))
                    .toList();
                _downloadImages(itemsToDownload).then((_) => _toggleSelectionMode());
              },
            ),
            VerticalDivider(
              color: Colors.white.withOpacity(0.2),
              indent: 15,
              endIndent: 15,
            ),
            _buildActionButton(
              icon: Ionicons.trash_outline,
              label: 'Delete',
              onPressed: () => _deleteImages(_selectedPaths.toList()),
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isDestructive = false,
    Color color = Colors.white,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isDestructive ? Colors.red.shade200 : color,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: isDestructive ? Colors.red.shade100 : color,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      padding: EdgeInsets.only(bottom: _isSelectionMode ? 100 : 20),
      physics: const AlwaysScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        childAspectRatio: 1,
      ),
      itemCount: _images.length,
      itemBuilder: (context, index) {
        return _buildImageCard(index);
      },
    );
  }

  Widget _buildImageCard(int index) {
    final image = _images[index];
    final isSelected = _selectedPaths.contains(image.path);

    return GestureDetector(
      onTap: () {
        if (_isSelectionMode) {
          _toggleImageSelection(image.path);
        } else {
          _showFullScreenGallery(index);
        }
      },
      onLongPress: () {
        if (!_isSelectionMode) {
          _toggleImageSelection(image.path);
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            image.url,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: lightGray,
                child: Center(
                  child: SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(royalBlue.withOpacity(0.3)),
                    ),
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: lightGray,
                child: const Icon(Ionicons.image_outline, color: darkGray, size: 20),
              );
            },
          ),
          if (isSelected)
            Container(
              color: Colors.black.withOpacity(0.4),
            ),
          if (isSelected)
            Positioned(
              top: 5,
              right: 5,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: royalBlue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Ionicons.checkmark,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showFullScreenGallery(int initialIndex) {
    int currentIndex = initialIndex;
    bool isDownloadingLocal = false;
    bool showSuccessMessage = false;

    showDialog(
      context: context,
      useSafeArea: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final pageController = PageController(initialPage: initialIndex);

          return Material(
            color: Colors.transparent,
            child: Stack(
              children: [
                // Background Blur
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(color: Colors.black.withOpacity(0.85)),
                  ),
                ),

                // PageView for Images
                PageView.builder(
                  controller: pageController,
                  itemCount: _images.length,
                  onPageChanged: (index) {
                    setDialogState(() => currentIndex = index);
                  },
                  itemBuilder: (context, index) {
                    return InteractiveViewer(
                      minScale: 1.0,
                      maxScale: 4.0,
                      child: Center(
                        child: Image.network(
                          _images[index].url,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const CircularProgressIndicator(color: Colors.white, strokeWidth: 2);
                          },
                        ),
                      ),
                    );
                  },
                ),

                // Success Message Overlay
                if (showSuccessMessage)
                  Positioned(
                    top: 120,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Ionicons.checkmark_circle, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Saved to Gallery',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Top Navigation Bar
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Ionicons.close, color: Colors.white, size: 28),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Text(
                          '${currentIndex + 1} / ${_images.length}',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 48), 
                      ],
                    ),
                  ),
                ),

                // Bottom Action Bar
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(40, 20, 40, 40),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (isDownloadingLocal)
                          const SizedBox(
                            width: 60,
                            height: 60,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                          )
                        else
                          _buildActionButton(
                            icon: Ionicons.download_outline,
                            label: 'Save',
                            onPressed: () async {
                              setDialogState(() => isDownloadingLocal = true);
                              await _downloadImages([_images[currentIndex]]);
                              if (mounted) {
                                setDialogState(() {
                                  isDownloadingLocal = false;
                                  showSuccessMessage = true;
                                });
                                Future.delayed(const Duration(seconds: 2), () {
                                  if (mounted) {
                                    setDialogState(() => showSuccessMessage = false);
                                  }
                                });
                              }
                            },
                          ),
                        _buildActionButton(
                          icon: Ionicons.trash_outline,
                          label: 'Delete',
                          onPressed: () async {
                            final pathToDelete = _images[currentIndex].path;
                            await _deleteImages([pathToDelete]);
                            if (mounted && !_images.any((img) => img.path == pathToDelete)) {
                              Navigator.pop(context);
                            }
                          },
                          isDestructive: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Ionicons.cloud_offline_outline, color: darkGray, size: 44),
            const SizedBox(height: 10),
            Text(
              _error ?? 'Unable to load highlights.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: darkGray,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _fetchHighlights,
              style: ElevatedButton.styleFrom(
                backgroundColor: royalBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Ionicons.refresh_outline, size: 16),
              label: const Text(
                'Retry',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Ionicons.images_outline, color: darkGray.withOpacity(0.5), size: 44),
          const SizedBox(height: 10),
          const Text(
            'No highlights uploaded yet',
            style: TextStyle(
              color: darkGray,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
