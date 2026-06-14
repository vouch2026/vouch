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
import '../../organizations/providers/workspace_provider.dart';
import '../../../core/permissions/app_permissions.dart';
import '../../../core/utils/time_formatter.dart';

import '../../attendance/widgets/event_scanner_screen.dart';
import '../../attendance/views/attendance_report_page.dart';
import 'event_highlights_gallery_page.dart';

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
    
    final workspace = ref.watch(workspaceProvider);
    final activeRole = workspace.activeRole;
    final canScan = activeRole?.hasPermission(AppPermissions.scanEventAttendance) ?? false;
    final isOfficer = activeRole != null && activeRole.roleName != 'Member';
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isToday = widget.event.eventDate.year == now.year &&
                    widget.event.eventDate.month == now.month &&
                    widget.event.eventDate.day == now.day;
    final isUpcoming = widget.event.eventDate.isAfter(today);

    return DashboardLayout(
      title: 'Event Details',
      onBack: () {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      },
      floatingActionButton: (canScan && isToday) 
        ? FloatingActionButton.extended(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EventScannerScreen(event: widget.event),
              ),
            ),
            label: Text(
              'Scan QR',
              style: AppTextStyles.labelLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            icon: const Icon(Icons.qr_code_scanner_rounded),
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.primary,
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          )
        : null,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? AppSpacing.lg : AppSpacing.xl),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () {
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
                    const SizedBox(width: 8),
                    Icon(Icons.chevron_right_rounded, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.event.name,
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
                const SizedBox(height: AppSpacing.md),
                _buildResponsiveHero(),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTitleSection(),
                            const SizedBox(height: AppSpacing.lg),
                            _buildDescriptionSection(),
                            const SizedBox(height: AppSpacing.xxl),
                            if (!isOfficer && !isUpcoming)
                              highlightsAsync.when(
                                data: (count) => _buildHighlightsSection(count),
                                loading: () => const Center(child: CircularProgressIndicator()),
                                error: (_, __) => const SizedBox.shrink(),
                              ),
                            if (isOfficer && widget.event.isPastTimeout) ...[
                              _buildOfficerPastEventActions(context),
                            ],
                          ],
                        ),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: widget.event.imageUrl != null
            ? Image.network(widget.event.imageUrl!, fit: BoxFit.cover)
            : Container(
                color: AppColors.primary.withValues(alpha: 0.05),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.image_outlined, size: 32, color: AppColors.primary),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'No banner image available',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
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
            style: AppTextStyles.titleMedium.copyWith(color: AppColors.textGrey, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        Text(
          'About this Event',
          style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          widget.event.fullDescription ?? 'No description available for this event.',
          style: AppTextStyles.bodyLarge.copyWith(height: 1.6, color: AppColors.textDark),
        ),
      ],
    );
  }

  Widget _buildInfoSidebar() {
    final userAsync = ref.watch(userProfileProvider);
    final attendanceAsync = ref.watch(userEventAttendanceProvider(widget.event.id!));
    final workspace = ref.watch(workspaceProvider);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isPast = widget.event.eventDate.isBefore(today);

    return userAsync.when(
      data: (user) {
        final activeRole = workspace.activeRole;
        final isOfficer = activeRole != null && activeRole.roleName != 'Member';

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
                            ? DateFormat('h:mm a').format(attendance!.actualTimeIn!.toLocal())
                            : 'No Record',
                        color: Colors.green,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildInfoCard(
                        icon: Icons.logout_rounded,
                        title: 'Time Out',
                        content: attendance?.actualTimeOut != null
                            ? DateFormat('h:mm a').format(attendance!.actualTimeOut!.toLocal())
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
                content: TimeFormatter.formatTimeRange(widget.event.timeInStart, widget.event.timeInEnd),
                color: Colors.green,
              ),
              const SizedBox(height: AppSpacing.md),
              _buildInfoCard(
                icon: Icons.logout_rounded,
                title: isOfficer ? 'Time Out' : 'Check-out Window',
                content: TimeFormatter.formatTimeRange(widget.event.timeOutStart, widget.event.timeOutEnd),
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
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
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
              style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            if (!isLimitReached && _selectedImages.length < remainingSlots)
              TextButton.icon(
                onPressed: _isUploading ? null : () => _pickImages(remainingSlots),
                icon: const Icon(Icons.add_a_photo_rounded, size: 16),
                label: const Text('Add Photos'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
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
              height: 160,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add_photo_alternate_rounded, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'No photos selected', 
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap to upload event highlights', 
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey),
                  ),
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
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _isUploading
                  ? const CircularProgressIndicator(color: AppColors.primary)
                  : Text(
                      'Upload Event Highlights', 
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildOfficerPastEventActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Officer Management Actions',
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.bold, 
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Access past records, uploaded photos, and full attendance sheets for this event.',
          style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: AppSpacing.lg),
        LayoutBuilder(
          builder: (context, constraints) {
            final useVerticalLayout = constraints.maxWidth < 600;
            
            final highlightsButton = SizedBox(
              height: 54,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EventHighlightsGalleryPage(
                      eventId: widget.event.id!,
                      eventName: widget.event.name,
                    ),
                  ),
                ),
                icon: const Icon(Icons.photo_library_rounded),
                label: Text(
                  'View Uploaded Highlights',
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            );

            final attendanceButton = SizedBox(
              height: 54,
              child: FilledButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AttendanceReportPage(
                      event: widget.event,
                    ),
                  ),
                ),
                icon: const Icon(Icons.analytics_rounded),
                label: Text(
                  'View Attendance Report',
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            );

            if (useVerticalLayout) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  highlightsButton,
                  const SizedBox(height: AppSpacing.md),
                  attendanceButton,
                ],
              );
            }

            return Row(
              children: [
                Expanded(child: highlightsButton),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: attendanceButton),
              ],
            );
          },
        ),
      ],
    );
  }
}
