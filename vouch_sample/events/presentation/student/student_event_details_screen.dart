import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/services/supabase_storage_service.dart';
import '../../../auth/data/supabase_auth_service.dart';
import '../../../qr_code/presentation/admin/scan_qr_screen.dart';

class EventDetailsScreen extends StatefulWidget {
  final int? eventId;
  final String eventImage;
  final String eventName;
  final String eventDate;
  final String eventTime;
  final String location;
  final String locationSubtitle;
  final String shortDescription;
  final String description;
  final bool isObligatory;
  final bool showHighlights;
  final String? timeInStart;
  final String? timeInEnd;
  final String? timeOutStart;
  final String? timeOutEnd;

  const EventDetailsScreen({
    super.key,
    this.eventId,
    this.eventImage = 'assets/images/event-siglakas.jpg',
    this.eventName = 'Siglakas 2026 Day 2',
    this.eventDate = 'April 11, 2026',
    this.eventTime =
        'Time in: 08:00 AM - 08:15 AM\nTime out: 04:00 PM - 04:15 PM',
    this.location = 'University Campus',
    this.locationSubtitle = '',
    this.shortDescription = 'No short description available for this event.',
    this.description =
        'Join us for SIGLAKAS 2025, the much-awaited annual sports fest that unites Carolinians through friendly competition, teamwork, and the true spirit of sportsmanship. For one exhilarating week, students from different colleges – Engineering, Business, Architecture, Arts and Sciences, Education, and Nursing – will compete across various sports and recreational activities. SIGLAKAS is more than just a tournament — it\'s a celebration of unity, discipline, and pride as students push their limits on and off the field. The event aims to promote physical wellness, camaraderie, and school spirit while reminding everyone that victory is not only about winning medals but about playing with heart.',
    this.isObligatory = true,
    this.showHighlights = true,
    this.timeInStart,
    this.timeInEnd,
    this.timeOutStart,
    this.timeOutEnd,
  });

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  final List<File> _selectedImages = [];
  bool _isUploading = false;
  bool _isLoadingExisting = true;
  int _existingUploadsCount = 0;
  String? _studentRole;
  final ImagePicker _picker = ImagePicker();

  static const Color royalBlue = Color(0xFF003DA5);
  static const Color gold = Color(0xFFFFC107);
  static const Color lightGray = Color(0xFF9CA3AF);

  @override
  void initState() {
    super.initState();
    _checkExistingUploads();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    try {
      final role = await SupabaseAuthService.determineDetailedStudentRole();
      if (mounted) {
        setState(() {
          _studentRole = role;
        });
      }
    } catch (_) {}
  }

  Future<void> _checkExistingUploads() async {
    final user = SupabaseAuthService.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoadingExisting = false);
      return;
    }

    try {
      final bucketName =
          dotenv.env['SUPABASE_HIGHLIGHTS_BUCKET'] ?? 'highlight-pictures';
      final folder = 'event_highlights/${widget.eventName}/${user.id}';

      final files = await SupabaseStorageService.instance.listFiles(
        bucketName: bucketName,
        folder: folder,
      );

      if (mounted) {
        setState(() {
          _existingUploadsCount = files.length;
          _isLoadingExisting = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingExisting = false);
      }
    }
  }

  Future<void> _pickImages() async {
    final remainingSlots = 2 - _existingUploadsCount;

    if (remainingSlots <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'You have already uploaded the maximum of 2 images for this event.')),
      );
      return;
    }

    if (_selectedImages.length >= remainingSlots) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('You can only upload $remainingSlots more image(s).')),
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
        setState(() {
          for (var image in images) {
            if (_selectedImages.length < remainingSlots) {
              final file = File(image.path);
              final fileSize = file.lengthSync();
              if (fileSize <= 5 * 1024 * 1024) {
                _selectedImages.add(file);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Image ${image.name} exceeds 5MB limit.'),
                  ),
                );
              }
            }
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking images: $e')),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _uploadHighlights() async {
    final user = SupabaseAuthService.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to upload highlights.')),
      );
      return;
    }

    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one image.')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final bucketName =
          dotenv.env['SUPABASE_HIGHLIGHTS_BUCKET'] ?? 'highlight-pictures';

      for (var file in _selectedImages) {
        await SupabaseStorageService.instance.uploadFile(
          bucketName: bucketName,
          file: file,
          folder: 'event_highlights/${widget.eventName}/${user.id}',
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Highlights uploaded successfully!')),
        );
        _selectedImages.clear();
        await _checkExistingUploads();
        setState(() {
          _isUploading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme);

    return Theme(
      data: Theme.of(context).copyWith(textTheme: textTheme),
      child: Scaffold(
        backgroundColor: Colors.white,
        floatingActionButton: _studentRole == 'council'
            ? FloatingActionButton.extended(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ScanQrScreen(
                        eventId: widget.eventId,
                        eventName: widget.eventName,
                        location: widget.location,
                        timeWindow: widget.eventTime,
                        timeInStart: widget.timeInStart,
                        timeInEnd: widget.timeInEnd,
                        timeOutStart: widget.timeOutStart,
                        timeOutEnd: widget.timeOutEnd,
                      ),
                    ),
                  );
                },
                backgroundColor: royalBlue,
                icon: const Icon(Ionicons.scan_outline, color: Colors.white),
                label: const Text(
                  'Scan Attendance',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            : null,
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
              bottom: 260,
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
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildEventImage(),
                            const SizedBox(height: 16),
                            _buildTitleRow(),
                            const SizedBox(height: 16),
                            _buildInfoCard(
                              icon: Ionicons.calendar,
                              iconBgColor: gold.withOpacity(0.12),
                              iconColor: gold,
                              title: widget.eventDate,
                              subtitle: widget.eventTime,
                              subtitleColor: lightGray,
                            ),
                            const SizedBox(height: 14),
                            _buildInfoCard(
                              icon: Ionicons.location,
                              iconBgColor: royalBlue.withOpacity(0.1),
                              iconColor: royalBlue,
                              title: widget.location,
                              subtitle: widget.locationSubtitle,
                              subtitleColor: lightGray,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Short Description',
                              style: GoogleFonts.poppins(
                                color: royalBlue,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              widget.shortDescription,
                              textAlign: TextAlign.justify,
                              style: GoogleFonts.poppins(
                                color: Colors.black87,
                                fontSize: 14,
                                height: 1.55,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Description',
                              style: GoogleFonts.poppins(
                                color: royalBlue,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              widget.description,
                              textAlign: TextAlign.justify,
                              style: GoogleFonts.poppins(
                                color: Colors.black87,
                                fontSize: 14,
                                height: 1.55,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 30),
                            if (!_isLoadingExisting) _buildHighlightsSection(),
                            if (_isLoadingExisting)
                              const Center(
                                  child: CircularProgressIndicator(
                                      color: royalBlue)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightsSection() {
    if (!widget.showHighlights) return const SizedBox.shrink();

    final remainingSlots = 2 - _existingUploadsCount;
    final isLimitReached = remainingSlots <= 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Event Highlights',
              style: GoogleFonts.poppins(
                color: royalBlue,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (!isLimitReached && _selectedImages.length < remainingSlots)
              TextButton.icon(
                onPressed: _isUploading ? null : _pickImages,
                icon: const Icon(Ionicons.add_circle_outline, size: 20),
                label: Text(
                  'Add Photos',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: royalBlue,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          isLimitReached
              ? 'You have reached the maximum of 2 photos for this event.'
              : 'Share your favorite moments (Remaining slots: $remainingSlots)',
          style: GoogleFonts.poppins(
            color: isLimitReached ? Colors.orange : lightGray,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        if (_selectedImages.isNotEmpty)
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: royalBlue.withOpacity(0.1)),
                          image: DecorationImage(
                            image: FileImage(_selectedImages[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Ionicons.close,
                              color: Colors.white,
                              size: 16,
                            ),
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
            onTap: _pickImages,
            child: Container(
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: royalBlue.withOpacity(0.1),
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Ionicons.images_outline,
                      color: royalBlue.withOpacity(0.5), size: 32),
                  const SizedBox(height: 8),
                  Text(
                    'No photos selected',
                    style: GoogleFonts.poppins(
                      color: lightGray,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (isLimitReached)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: gold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: gold.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Ionicons.checkmark_circle, color: royalBlue),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'You\'ve successfully shared your highlights for this event!',
                    style: GoogleFonts.poppins(
                      color: royalBlue,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 24),
        if (!isLimitReached)
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: (_selectedImages.isEmpty || _isUploading)
                  ? null
                  : _uploadHighlights,
              style: ElevatedButton.styleFrom(
                backgroundColor: royalBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                disabledBackgroundColor: royalBlue.withOpacity(0.6),
              ),
              child: _isUploading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(
                      'Upload Event Highlights',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: Colors.white,
      child: SizedBox(
        height: 32,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Ionicons.arrow_back, color: Color(0xFF003DA5)),
              ),
            ),
            RichText(
              text: TextSpan(
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
                children: const [
                  TextSpan(
                    text: 'Event ',
                    style: TextStyle(color: Color(0xFF003DA5)),
                  ),
                  TextSpan(
                    text: 'Details',
                    style: TextStyle(color: Color(0xFFFFC107)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventImage() {
    final isAssetImage = widget.eventImage.startsWith('assets/');

    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF003DA5).withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: isAssetImage
            ? Image.asset(
                widget.eventImage,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFFE5E7EB),
                    child: const Center(
                      child: Icon(
                        Ionicons.image,
                        color: Color(0xFF9CA3AF),
                        size: 46,
                      ),
                    ),
                  );
                },
              )
            : Image.network(
                widget.eventImage,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFFE5E7EB),
                    child: const Center(
                      child: Icon(
                        Ionicons.image,
                        color: Color(0xFF9CA3AF),
                        size: 46,
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildTitleRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            widget.eventName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: const Color(0xFF003DA5),
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (widget.isObligatory) ...[
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF003DA5),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Text(
              'OBLIGATORY',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Color subtitleColor,
  }) {
    final hasSubtitle = subtitle.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF003DA5).withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (hasSubtitle) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      color: subtitleColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
