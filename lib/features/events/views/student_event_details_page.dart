import 'package:vouch_v2/core/widgets/loaders/flickr_loader.dart';
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
import '../../excuse_requests/providers/excuse_provider.dart';
import '../../excuse_requests/views/excuse_request_form_page.dart';
import '../../organizations/providers/workspace_provider.dart';
import '../../organizations/providers/organization_provider.dart';
import '../../organizations/models/organization_membership_model.dart';
import '../../../core/permissions/app_permissions.dart';
import '../../../core/utils/time_formatter.dart';
import '../../../core/utils/role_mapper.dart';

import '../../attendance/widgets/event_scanner_screen.dart';
import '../../attendance/views/attendance_report_page.dart';
import '../../attendance/views/attendance_history_page.dart';
import 'event_highlights_gallery_page.dart';
import '../../governor/views/governor_create_event_page.dart';
import 'package:vouch_v2/core/providers/connectivity_provider.dart';
import 'package:vouch_v2/core/utils/offline_image_cache.dart';

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
        final allowedExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp'];
        for (var image in images) {
          final name = image.name.toLowerCase();
          final isImage = allowedExtensions.any((ext) => name.endsWith(ext));

          if (!isImage) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('File ${image.name} is not a valid image. Only JPG, JPEG, PNG, GIF, WEBP, BMP are allowed.'),
                backgroundColor: Colors.red,
              ),
            );
            continue;
          }

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

  void _navigateToEditEvent(EventModel currentEvent) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GovernorCreateEventPage(eventToEdit: currentEvent),
      ),
    ).then((result) {
      if (result == 'deleted') {
        if (context.mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      } else if (result == true) {
        ref.invalidate(eventProvider(widget.event.id!));
        ref.invalidate(workspaceEventsProvider);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final eventAsync = ref.watch(eventProvider(widget.event.id!));
    final event = eventAsync.value ?? widget.event;

    final userAsync = ref.watch(userProfileProvider);
    final currentUserId = userAsync.value?.id;

    final highlightsAsync = ref.watch(eventHighlightsProvider(event.id!));
    final isMobile = ResponsiveLayout.isMobile(context);
    
    final workspace = ref.watch(workspaceProvider);
    final activeRole = workspace.activeRole;
    
    final userOrgsAsync = ref.watch(userOrganizationsProvider);
    final userOrgs = userOrgsAsync.value ?? [];
    
    final creatorOrgId = event.createdByOrganizationId;
    final creatorMembershipAsync = creatorOrgId != null
        ? ref.watch(userMembershipInOrgProvider(creatorOrgId))
        : const AsyncValue<OrganizationMembershipModel?>.data(null);
    final creatorMembership = creatorMembershipAsync.value;

    final isMemberOfCreatorOrg = creatorOrgId != null
        ? userOrgs.any((org) => org.id == creatorOrgId)
        : userOrgs.any((org) {
            if (org.id == event.scopeId) return true;
            if (event.scopeType == 'Institutional' && org.type == 'campus-based' && org.campusId == event.scopeId) return true;
            if (event.scopeType == 'Faculty' && org.type == 'faculty-based' && org.facultyId == event.scopeId) return true;
            if (event.scopeType == 'Program' && org.type == 'program-based' && org.programId == event.scopeId) return true;
            return false;
          });

    final selectedOrg = workspace.selectedOrganization;
    final isSelectedOrgCreator = selectedOrg != null && (
      selectedOrg.id == event.scopeId ||
      (event.scopeType == 'Institutional' && selectedOrg.type == 'campus-based' && selectedOrg.campusId == event.scopeId) ||
      (event.scopeType == 'Faculty' && selectedOrg.type == 'faculty-based' && selectedOrg.facultyId == event.scopeId) ||
      (event.scopeType == 'Program' && selectedOrg.type == 'program-based' && selectedOrg.programId == event.scopeId)
    );

    final isOfficer = creatorOrgId != null
        ? ((creatorMembership != null && creatorMembership.roleName != null && creatorMembership.roleName != 'Member') ||
           (selectedOrg?.id == creatorOrgId && activeRole != null && activeRole.roleName != 'Member'))
        : (activeRole != null && activeRole.roleName != 'Member' && isSelectedOrgCreator);

    final officerRoleName = creatorOrgId != null
        ? (creatorMembership?.roleName ?? (selectedOrg?.id == creatorOrgId ? activeRole?.roleName : null))
        : (isSelectedOrgCreator ? activeRole?.roleName : null);

    final normalizedRole = officerRoleName != null
        ? RoleMapper.mapDbRoleToAppFormat(officerRoleName)
        : null;

    final isAllowedOfficer = isOfficer && (
      normalizedRole == 'governor' ||
      normalizedRole == 'vice_governor' ||
      normalizedRole == 'president' ||
      normalizedRole == 'vice_president'
    );

    final isFullOfficer = isOfficer && normalizedRole != 'representative';

    final canScan = isOfficer;

    final canEdit = (creatorOrgId != null
        ? (creatorMembership?.permissions.contains(AppPermissions.editEvent) ?? false)
        : ((activeRole?.hasPermission(AppPermissions.editEvent) ?? false) && isSelectedOrgCreator)) && (
          normalizedRole == 'secretary' ||
          normalizedRole == 'president' ||
          normalizedRole == 'vice_president' ||
          normalizedRole == 'governor' ||
          normalizedRole == 'vice_governor'
        );
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isToday = event.eventDate.year == now.year &&
                    event.eventDate.month == now.month &&
                    event.eventDate.day == now.day;
    final isUpcoming = event.eventDate.isAfter(today);

    return DashboardLayout(
      title: 'Event Details',
      onBack: () {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      },
      floatingActionButton: (canScan && isToday && !event.isPastTimeout) 
        ? FloatingActionButton.extended(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EventScannerScreen(event: event),
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
                    event.name,
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
            _buildResponsiveHero(event),
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
                        _buildTitleSection(event, canEdit),
                        const SizedBox(height: AppSpacing.lg),
                        _buildDescriptionSection(event),
                        const SizedBox(height: AppSpacing.xxl),
                        if (!isFullOfficer && !isUpcoming) ...[
                          if (isMemberOfCreatorOrg) ...[
                            highlightsAsync.when(
                              data: (count) => _buildHighlightsSection(count),
                              loading: () => const Center(child: FlickrLoader()),
                              error: (_, __) => const SizedBox.shrink(),
                            ),
                            const SizedBox(height: AppSpacing.xxl),
                          ],
                          _buildStudentExcuseAction(context, event, isOfficer: isFullOfficer),
                        ],
                        if (isAllowedOfficer && event.isPastTimeout) ...[
                          _buildOfficerPastEventActions(context, event, isMemberOfCreatorOrg: isMemberOfCreatorOrg),
                        ],
                        if (canScan && event.isPastTimeout) ...[
                          _buildMyScansAction(context, event, currentUserId),
                        ],
                      ],
                    ),
                  ),
                ),
                if (!isMobile) ...[
                  const SizedBox(width: AppSpacing.xxl),
                  Expanded(
                    flex: 1,
                    child: _buildInfoSidebar(event, isOfficer: isFullOfficer),
                  ),
                ],
              ],
            ),
            if (isMobile) ...[
              const SizedBox(height: AppSpacing.xxl),
              _buildInfoSidebar(event, isOfficer: isFullOfficer),
            ],
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsiveHero(EventModel event) {
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
        child: event.imageUrl != null
            ? Image(image: OfflineImageCache.get(event.imageUrl!)!, fit: BoxFit.cover)
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

  Widget _buildTitleSection(EventModel event, bool canEdit) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (event.isMandatory)
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
                    event.scopeType.toUpperCase(),
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
                event.name,
                style: AppTextStyles.headlineMedium.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        if (canEdit) ...[
          const SizedBox(width: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: () => _navigateToEditEvent(event),
            icon: const Icon(Icons.edit_rounded, size: 16),
            label: const Text('Edit Event', style: TextStyle(fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: const BorderSide(color: AppColors.primary),
              foregroundColor: AppColors.primary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDescriptionSection(EventModel event) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (event.shortDescription != null) ...[
          Text(
            event.shortDescription!,
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
          event.fullDescription ?? 'No description available for this event.',
          style: AppTextStyles.bodyLarge.copyWith(height: 1.6, color: AppColors.textDark),
        ),
      ],
    );
  }

  Widget _buildInfoSidebar(EventModel event, {required bool isOfficer}) {
    final userAsync = ref.watch(userProfileProvider);
    final attendanceAsync = ref.watch(userEventAttendanceProvider(event.id!));

    final isPast = event.isPastTimeout;

    return userAsync.when(
      data: (user) {

        return Column(
          children: [
            _buildInfoCard(
              icon: Icons.calendar_today_rounded,
              title: 'Date',
              content: DateFormat.yMMMMd().format(event.eventDate),
              color: Colors.blue,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildInfoCard(
              icon: Icons.location_on_rounded,
              title: 'Location',
              content: event.location,
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
                        ref.watch(studentEventExcuseProvider(event.id!)).when(
                          data: (excuse) {
                            if (excuse == null) return const SizedBox.shrink();
                            Color excuseColor = Colors.orange;
                            if (excuse.status == 'Approved') excuseColor = Colors.green;
                            if (excuse.status == 'Rejected') excuseColor = Colors.red;
                            
                            return Column(
                              children: [
                                _buildInfoCard(
                                  icon: Icons.info_outline_rounded,
                                  title: 'Excuse Status',
                                  content: excuse.status.toUpperCase(),
                                  color: excuseColor,
                                ),
                                const SizedBox(height: AppSpacing.md),
                              ],
                            );
                          },
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
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
                loading: () => const Center(child: FlickrLoader()),
                error: (_, __) => const Text('Error loading attendance'),
              ),
            ] else ...[
              _buildInfoCard(
                icon: Icons.access_time_rounded,
                title: isOfficer ? 'Time In' : 'Check-in Window',
                content: TimeFormatter.formatTimeRange(event.timeInStart, event.timeInEnd),
                color: Colors.green,
              ),
              const SizedBox(height: AppSpacing.md),
              _buildInfoCard(
                icon: Icons.logout_rounded,
                title: isOfficer ? 'Time Out' : 'Check-out Window',
                content: TimeFormatter.formatTimeRange(event.timeOutStart, event.timeOutEnd),
                color: Colors.orange,
              ),
            ],
          ],
        );
      },
      loading: () => const Center(child: FlickrLoader()),
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
    final isOnline = ref.watch(connectivityProvider).value ?? true;
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
            if (isOnline && !isLimitReached && _selectedImages.length < remainingSlots)
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
              : (isOnline
                  ? 'Share your favorite moments (Remaining slots: $remainingSlots)'
                  : 'Highlights upload is unavailable offline.'),
          style: AppTextStyles.bodySmall.copyWith(
            color: isLimitReached ? Colors.orange : (isOnline ? Colors.grey[600] : Colors.orange),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (!isOnline && !isLimitReached)
          Container(
            width: double.infinity,
            height: 160,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.05)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off_rounded, color: AppColors.textGrey, size: 36),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Upload Offline Mode',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textGrey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Connecting to the internet is required to upload highlights.',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey),
                ),
              ],
            ),
          )
        else ...[
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
      ],
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
                  ? const FlickrLoader()
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

  Widget _buildOfficerPastEventActions(BuildContext context, EventModel event, {required bool isMemberOfCreatorOrg}) {
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
                      eventId: event.id!,
                      eventName: event.name,
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
                      event: event,
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
                  if (isMemberOfCreatorOrg) ...[
                    highlightsButton,
                    const SizedBox(height: AppSpacing.md),
                  ],
                  attendanceButton,
                ],
              );
            }

            return Row(
              children: [
                if (isMemberOfCreatorOrg) ...[
                  Expanded(child: highlightsButton),
                  const SizedBox(width: AppSpacing.md),
                ],
                Expanded(child: attendanceButton),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildMyScansAction(BuildContext context, EventModel event, String? currentUserId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.xxl),
        Text(
          'My Scans',
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.bold, 
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'View students you scanned for this event.',
          style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AttendanceHistoryPage(
                  eventId: event.id!,
                  eventName: event.name,
                  scannedByUserId: currentUserId,
                  event: event,
                ),
              ),
            ),
            icon: const Icon(Icons.history_rounded),
            label: Text(
              'View My Scans',
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
        ),
      ],
    );
  }

  Widget _buildStudentExcuseAction(BuildContext context, EventModel event, {required bool isOfficer}) {
    final isPast = event.isPastTimeout;
    
    if (!isPast) return const SizedBox.shrink();
    
    if (isOfficer) return const SizedBox.shrink();

    final isOnline = ref.watch(connectivityProvider).value ?? true;
    if (!isOnline) {
      return SizedBox(
        width: double.infinity,
        height: 54,
        child: FilledButton.icon(
          onPressed: null,
          icon: const Icon(Icons.wifi_off_rounded),
          label: Text(
            'Excuse requests are unavailable offline',
            style: AppTextStyles.labelLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.grey.shade400,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      );
    }

    final attendanceAsync = ref.watch(userEventAttendanceProvider(event.id!));
    
    return attendanceAsync.when(
      data: (attendance) {
        final isAbsent = attendance == null || attendance.status == 'Absent';
        if (!isAbsent) return const SizedBox.shrink();

        final excuseAsync = ref.watch(studentEventExcuseProvider(event.id!));
        
        return excuseAsync.when(
          data: (excuse) {
            final excuseStatus = excuse?.status;
            final submissionCount = excuse?.submissionCount ?? 0;
            final chancesLeft = 2 - submissionCount;
            
            String buttonText = 'Submit Excuse Request ($chancesLeft chances left)';
            bool showButton = true;
            bool isBtnEnabled = true;
            
            if (excuseStatus == 'Pending' || excuseStatus == 'Pending Review') {
              buttonText = 'Excuse Request Pending';
              showButton = false;
            } else if (excuseStatus == 'Approved') {
              buttonText = 'Excuse Approved';
              showButton = false;
            } else if (excuseStatus == 'Rejected') {
              if (chancesLeft <= 0) {
                buttonText = 'Submit Excuse Request (0 chances left)';
                showButton = true;
                isBtnEnabled = false;
              } else {
                buttonText = 'Resubmit Excuse Request ($chancesLeft chance left)';
                showButton = true;
                isBtnEnabled = true;
              }
            } else if (excuseStatus == 'Needs Revision') {
              buttonText = 'Update Excuse (Needs Revision)';
              showButton = true;
              isBtnEnabled = true;
            }
            
            if (!showButton) {
              return Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: excuseStatus == 'Approved' ? AppColors.success.withValues(alpha: 0.1) : AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: excuseStatus == 'Approved' ? AppColors.success.withValues(alpha: 0.3) : AppColors.warning.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      excuseStatus == 'Approved' ? Icons.check_circle_outline_rounded : Icons.access_time_rounded,
                      color: excuseStatus == 'Approved' ? AppColors.success : AppColors.warning,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        excuseStatus == 'Approved' 
                            ? 'Your excuse request has been approved. This event is cleared.'
                            : 'Your excuse request has been submitted and is currently pending review.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: excuseStatus == 'Approved' ? AppColors.success : AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            Widget? rejectionAlert;
            if (excuseStatus == 'Rejected' && excuse?.rejectionReason != null && excuse!.rejectionReason!.isNotEmpty) {
              rejectionAlert = Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.error_outline_rounded, color: AppColors.error),
                        const SizedBox(width: 8),
                        Text(
                          'Excuse Request Rejected',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Remarks: ${excuse.rejectionReason!}',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
                    ),
                  ],
                ),
              );
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (rejectionAlert != null) rejectionAlert,
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton.icon(
                    onPressed: isBtnEnabled 
                      ? () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ExcuseRequestFormPage(
                              event: event,
                            ),
                          ),
                        ).then((_) {
                          ref.invalidate(studentEventExcuseProvider(event.id!));
                        })
                      : null,
                    icon: const Icon(Icons.note_alt_rounded),
                    label: Text(
                      buttonText,
                      style: AppTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: isBtnEnabled ? AppColors.primary : Colors.grey.shade400,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: FlickrLoader()),
          error: (err, _) => Text('Error loading excuse status: $err'),
        );
      },
      loading: () => const Center(child: FlickrLoader()),
      error: (err, _) => Text('Error loading attendance: $err'),
    );
  }
}
