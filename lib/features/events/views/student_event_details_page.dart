import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/providers/storage_provider.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../../../shared/layouts/responsive_layout.dart';
import '../models/event_model.dart';
import '../providers/event_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../attendance/providers/attendance_provider.dart';
import '../../attendance/models/attendance_model.dart';

class StudentEventDetailsPage extends ConsumerStatefulWidget {
  final EventModel event;

  const StudentEventDetailsPage({
    super.key,
    required this.event,
  });

  @override
  ConsumerState<StudentEventDetailsPage> createState() => _StudentEventDetailsPageState();
}

class _StudentEventDetailsPageState extends ConsumerState<StudentEventDetailsPage> {
  final List<XFile> _selectedImages = [];
  final Map<String, Uint8List> _selectedImagesBytes = {};
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImages(int remainingSlots) async {
    if (remainingSlots <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have already uploaded the maximum of 2 images for this event.')),
      );
      return;
    }

    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        for (var image in images) {
          if (_selectedImages.length < remainingSlots) {
            final bytes = await image.readAsBytes();
            final fileSize = bytes.length;
            if (fileSize <= 5 * 1024 * 1024) {
              setState(() {
                _selectedImages.add(image);
                _selectedImagesBytes[image.path] = bytes;
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Image ${image.name} exceeds 5MB limit.')),
              );
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking images: $e')),
        );
      }
    }
  }

  void _removeImage(int index) {
    final image = _selectedImages[index];
    setState(() {
      _selectedImages.removeAt(index);
      _selectedImagesBytes.remove(image.path);
    });
  }

  Future<void> _uploadHighlights() async {
    final user = ref.read(userProfileProvider).value;
    if (user == null || user.id == null) return;

    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one image.')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final storageService = ref.read(storageServiceProvider);

      for (var file in _selectedImages) {
        await storageService.uploadEventHighlight(
          file: file,
          eventId: widget.event.id!,
          userId: user.id!,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Highlights uploaded successfully!')),
        );
        setState(() {
          _selectedImages.clear();
          _selectedImagesBytes.clear();
        });
        ref.invalidate(eventHighlightsProvider(widget.event.id!));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final highlightsAsync = ref.watch(eventHighlightsProvider(widget.event.id!));
    final isMobile = ResponsiveLayout.isMobile(context);

    return DashboardLayout(
      title: 'Event Details',
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? AppSpacing.lg : AppSpacing.xl),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildResponsiveHero(),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTitleSection(),
                          const SizedBox(height: AppSpacing.lg),
                          _buildDescriptionSection(),
                          const SizedBox(height: AppSpacing.xxl),
                          highlightsAsync.when(
                            data: (count) => _buildHighlightsSection(count),
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (_, __) => const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                    if (!isMobile) ...[
                      const SizedBox(width: AppSpacing.xxl),
                      Expanded(
                        flex: 1,
                        child: _buildInfoSidebar(),
                      ),
                    ],
                  ],
                ),
                if (isMobile) ...[
                  const SizedBox(height: AppSpacing.xxl),
                  _buildInfoSidebar(),
                ],
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveHero() {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: widget.event.imageUrl != null
            ? Image.network(widget.event.imageUrl!, fit: BoxFit.cover)
            : Container(
                color: AppColors.primary.withValues(alpha: 0.1),
                child: const Icon(Icons.image_outlined, size: 64, color: AppColors.primary),
              ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (widget.event.isMandatory)
              Container(
                margin: const EdgeInsets.only(right: AppSpacing.sm),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'MANDATORY',
                  style: AppTextStyles.labelSmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            Text(
              widget.event.scopeType.toUpperCase(),
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          widget.event.name,
          style: AppTextStyles.headlineMedium.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.event.shortDescription != null) ...[
          Text(
            widget.event.shortDescription!,
            style: AppTextStyles.titleMedium.copyWith(color: Colors.grey[700], fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        Text(
          'About this Event',
          style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          widget.event.fullDescription ?? 'No description available for this event.',
          style: AppTextStyles.bodyLarge.copyWith(height: 1.6),
        ),
      ],
    );
  }

  Widget _buildInfoSidebar() {
    final userAsync = ref.watch(userProfileProvider);
    final attendanceAsync = ref.watch(userEventAttendanceProvider(widget.event.id!));

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isPast = widget.event.eventDate.isBefore(today);

    return userAsync.when(
      data: (user) {
        final isOfficer = user?.role != 'student';

        return Column(
          children: [
            _buildInfoCard(
              icon: Icons.calendar_today_rounded,
              title: 'Date',
              content: DateFormat.yMMMMd().format(widget.event.eventDate),
              color: Colors.blue,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildInfoCard(
              icon: Icons.location_on_rounded,
              title: 'Location',
              content: widget.event.location,
              color: Colors.red,
            ),
            const SizedBox(height: AppSpacing.md),
            if (isPast && !isOfficer) ...[
              attendanceAsync.when(
                data: (attendance) {
                  final isAbsent = attendance == null || attendance.status == 'Absent';
                  
                  return Column(
                    children: [
                      if (isAbsent) ...[
                        _buildInfoCard(
                          icon: Icons.cancel_rounded,
                          title: 'Attendance Status',
                          content: 'ABSENT',
                          color: Colors.red,
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                      _buildInfoCard(
                        icon: Icons.login_rounded,
                        title: 'Time In',
                        content: attendance?.actualTimeIn != null
                            ? DateFormat.jm().format(attendance!.actualTimeIn!.toLocal())
                            : 'No Record',
                        color: Colors.green,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildInfoCard(
                        icon: Icons.logout_rounded,
                        title: 'Time Out',
                        content: attendance?.actualTimeOut != null
                            ? DateFormat.jm().format(attendance!.actualTimeOut!.toLocal())
                            : 'No Record',
                        color: Colors.orange,
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Text('Error loading attendance'),
              ),
            ] else ...[
              _buildInfoCard(
                icon: Icons.access_time_rounded,
                title: isOfficer ? 'Time In' : 'Check-in Window',
                content: '${widget.event.timeInStart} - ${widget.event.timeInEnd}',
                color: Colors.green,
              ),
              const SizedBox(height: AppSpacing.md),
              _buildInfoCard(
                icon: Icons.logout_rounded,
                title: isOfficer ? 'Time Out' : 'Check-out Window',
                content: '${widget.event.timeOutStart} - ${widget.event.timeOutEnd}',
                color: Colors.orange,
              ),
            ],
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Text('Error loading user profile'),
    );
  }


  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelSmall.copyWith(color: Colors.grey[600], fontWeight: FontWeight.bold),
                ),
                Text(
                  content,
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightsSection(int existingCount) {
    final remainingSlots = 2 - existingCount;
    final isLimitReached = remainingSlots <= 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Event Highlights',
              style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
            ),
            if (!isLimitReached && _selectedImages.length < remainingSlots)
              TextButton.icon(
                onPressed: _isUploading ? null : () => _pickImages(remainingSlots),
                icon: const Icon(Icons.add_a_photo_rounded),
                label: const Text('Add Photos'),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          isLimitReached
              ? 'You have reached the maximum of 2 photos for this event.'
              : 'Share your favorite moments (Remaining slots: $remainingSlots)',
          style: AppTextStyles.bodySmall.copyWith(color: isLimitReached ? Colors.orange : Colors.grey[600]),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (_selectedImages.isNotEmpty)
          SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.md),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(_selectedImagesBytes[_selectedImages[index].path]!, width: 150, height: 150, fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                            child: const Icon(Icons.close, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        if (_selectedImages.isEmpty && !isLimitReached)
          GestureDetector(
            onTap: () => _pickImages(remainingSlots),
            child: Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!, style: BorderStyle.solid),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_outlined, color: Colors.grey[400], size: 48),
                  const SizedBox(height: 8),
                  Text('No photos selected', style: TextStyle(color: Colors.grey[500])),
                ],
              ),
            ),
          ),
        if (isLimitReached)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.green),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'You\'ve successfully shared your highlights for this event!',
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        if (_selectedImages.isNotEmpty && !isLimitReached) ...[
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _isUploading ? null : _uploadHighlights,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _isUploading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Upload Event Highlights', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ],
    );
  }
}
