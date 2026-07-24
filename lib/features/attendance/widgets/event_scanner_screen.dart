import 'package:vouch_v2/core/widgets/loaders/flickr_loader.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/enums/attendance_mode.dart';
import '../../../shared/layouts/responsive_layout.dart';
import '../../events/models/event_model.dart';
import '../providers/attendance_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/qr_scan_ui_model.dart';
import '../models/qr_payload.dart';
import 'qr_current_event_card.dart';
import 'qr_recent_scan_card.dart';
import 'qr_scanner_card.dart';
import 'qr_section_header.dart';
import 'qr_count_chip.dart';
import '../views/attendance_history_page.dart';

class EventScannerScreen extends ConsumerStatefulWidget {
  final EventModel event;

  const EventScannerScreen({super.key, required this.event});

  @override
  ConsumerState<EventScannerScreen> createState() => _EventScannerScreenState();
}

class _EventScannerScreenState extends ConsumerState<EventScannerScreen> {
  late MobileScannerController _controller;
  bool _isScanning = true;
  double _zoomLevel = 0.0;
  List<QrScanUIModel> _recentScans = [];
  bool _isLoadingScans = true;

  static const Color primaryColor = AppColors.primary;
  static const Color accentColor = AppColors.accent;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      autoStart: true,
      facing: CameraFacing.back,
      detectionSpeed: DetectionSpeed.normal,
      detectionTimeoutMs: 300,
    );
    _loadRecentScans();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadRecentScans() async {
    if (!mounted) return;
    
    // 1. Load from Hive box first to show scanned results instantly
    final box = Hive.box('attendance_scans');
    final cachedData = box.get('scans_${widget.event.id}');
    if (cachedData != null) {
      try {
        final cachedList = (cachedData as List).map((item) {
          return QrScanUIModel.fromJson(Map<String, dynamic>.from(item as Map));
        }).toList();
        if (mounted) {
          setState(() {
            _recentScans = cachedList;
            _isLoadingScans = false;
          });
        }
      } catch (e) {
        debugPrint('Error decoding cached scans: $e');
      }
    } else {
      setState(() => _isLoadingScans = true);
    }

    // Attempt to sync any pending scans before fetching new ones
    await _syncPendingScans();

    // 2. Fetch from Supabase
    try {
      final repository = ref.read(attendanceRepositoryProvider);
      final rawScans = await repository.getRecentScansForEvent(widget.event.id!);
      
      final List<Map<String, dynamic>> extractedScans = [];
      for (final data in rawScans) {
        final student = data['student'] as Map<String, dynamic>?;
        final firstName = student?['first_name'] ?? 'Unknown';
        final lastName = student?['last_name'] ?? 'Student';
        final studentId = student?['student_id_number'] ?? '-';
        final program = (student?['program'] as Map<String, dynamic>?)?['name'] ?? 'N/A';

        final timeInRaw = data['actual_time_in'];
        final timeOutRaw = data['actual_time_out'];

        if (timeInRaw != null) {
          extractedScans.add({
            'name': '$firstName $lastName',
            'studentId': studentId,
            'program': program,
            'dateTime': DateTime.parse(timeInRaw).toLocal(),
            'type': 'Time In',
          });
        }
        if (timeOutRaw != null) {
          extractedScans.add({
            'name': '$firstName $lastName',
            'studentId': studentId,
            'program': program,
            'dateTime': DateTime.parse(timeOutRaw).toLocal(),
            'type': 'Time Out',
          });
        }
      }

      // Sort extractedScans by dateTime descending (newest first)
      extractedScans.sort((a, b) => (b['dateTime'] as DateTime).compareTo(a['dateTime'] as DateTime));

      final remoteScans = extractedScans.map((scanData) {
        return QrScanUIModel(
          name: scanData['name'] as String,
          studentId: scanData['studentId'] as String,
          program: scanData['program'] as String,
          time: DateFormat('h:mm a').format(scanData['dateTime'] as DateTime),
          status: 'success',
          type: scanData['type'] as String,
        );
      }).toList();

      // Merge remote scans with pending local scans
      final pendingScans = _recentScans.where((s) => s.isPending).toList();
      
      final List<QrScanUIModel> merged = [...pendingScans];
      for (final remote in remoteScans) {
        final isDuplicated = merged.any((p) => p.studentId == remote.studentId && p.type == remote.type);
        if (!isDuplicated) {
          merged.add(remote);
        }
      }

      if (mounted) {
        setState(() {
          _recentScans = merged;
          _isLoadingScans = false;
        });
        
        await box.put('scans_${widget.event.id}', _recentScans.map((s) => s.toJson()).toList());
      }
    } catch (e) {
      debugPrint('Error loading recent scans from Supabase: $e');
      if (mounted) {
        setState(() => _isLoadingScans = false);
      }
    }
  }

  Future<void> _syncPendingScans() async {
    final pending = _recentScans.where((s) => s.isPending).toList();
    if (pending.isEmpty) return;

    final repository = ref.read(attendanceRepositoryProvider);
    final box = Hive.box('attendance_scans');

    List<QrScanUIModel> updatedScans = List.from(_recentScans);
    bool anySynced = false;

    for (final scan in pending) {
      if (scan.scannedByUserId == null) continue;
      try {
        await repository.recordAttendance(
          eventId: widget.event.id!,
          studentId: scan.studentUuid ?? scan.studentId,
          scannedByUserId: scan.scannedByUserId!,
          isTimeIn: scan.type == 'Time In',
        );

        // Update status to success
        final index = updatedScans.indexWhere((s) => s.studentId == scan.studentId && s.type == scan.type && s.isPending);
        if (index != -1) {
          updatedScans[index] = updatedScans[index].copyWith(status: 'success');
          anySynced = true;
        }
      } catch (e) {
        debugPrint('Failed to sync pending scan for ${scan.name}: $e');
      }
    }

    if (anySynced && mounted) {
      setState(() {
        _recentScans = updatedScans;
      });
      await box.put('scans_${widget.event.id}', _recentScans.map((s) => s.toJson()).toList());
    }
  }

  Future<void> _handleScan(BarcodeCapture capture) async {
    if (!_isScanning) return;

    final mode = widget.event.currentAttendanceMode;
    if (mode == AttendanceMode.closed) {
      _showError('Scanning is currently closed for this event.');
      return;
    }

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final String? rawValue = barcode.rawValue;
      if (rawValue != null) {
        setState(() => _isScanning = false);
        _controller.stop();
        _showActionModal(rawValue, mode);
        break;
      }
    }
  }

  void _showActionModal(String rawValue, AttendanceMode mode) {
    final payload = QrPayload.fromRawValue(rawValue);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _VerificationModal(
        payload: payload,
        mode: mode,
        onConfirm: () async {
          Navigator.pop(context);
          await _processAttendance(payload, mode == AttendanceMode.timeIn);
        },
        onReject: () {
          Navigator.pop(context);
          _resumeScanning();
        },
      ),
    );
  }

  Future<void> _processAttendance(QrPayload payload, bool isTimeIn) async {
    final officer = ref.read(userProfileProvider).value;
    if (officer == null || officer.id == null) {
       _showError('Officer profile not found or invalid');
       _resumeScanning();
       return;
    }

    final newScan = QrScanUIModel(
      name: payload.fullName,
      studentId: payload.studentId,
      program: payload.program,
      time: DateFormat('h:mm a').format(DateTime.now()),
      status: 'pending',
      type: isTimeIn ? 'Time In' : 'Time Out',
      studentUuid: payload.databaseId,
      scannedByUserId: officer.id,
    );

    if (mounted) {
      setState(() {
        _recentScans = [newScan, ..._recentScans];
      });
      final box = Hive.box('attendance_scans');
      await box.put('scans_${widget.event.id}', _recentScans.map((s) => s.toJson()).toList());
    }

    try {
      final repository = ref.read(attendanceRepositoryProvider);
      
      await repository.recordAttendance(
        eventId: widget.event.id!,
        studentId: payload.databaseId ?? payload.studentId,
        scannedByUserId: officer.id!,
        isTimeIn: isTimeIn,
      );

      if (mounted) {
        setState(() {
          final index = _recentScans.indexWhere((s) => s.studentId == newScan.studentId && s.type == newScan.type && s.isPending);
          if (index != -1) {
            _recentScans[index] = _recentScans[index].copyWith(status: 'success');
          }
        });
        
        final box = Hive.box('attendance_scans');
        await box.put('scans_${widget.event.id}', _recentScans.map((s) => s.toJson()).toList());
        
        _showSuccess(newScan.copyWith(status: 'success'));
      }
    } catch (e) {
      String msg = e.toString();
      if (msg.startsWith('Exception: ')) {
        msg = msg.substring('Exception: '.length);
      } else if (msg.startsWith('Exception')) {
        msg = msg.replaceFirst('Exception', 'Error');
      }

      final isNetworkError = msg.contains('SocketException') || msg.contains('Failed host lookup') || msg.contains('connection') || msg.contains('network');
      
      if (isNetworkError) {
        _showWarning('Saved Offline: Scan recorded locally. Will sync when connection is restored.');
      } else {
        if (mounted) {
          setState(() {
            _recentScans.removeWhere((s) => s.studentId == newScan.studentId && s.type == newScan.type && s.isPending);
          });
          final box = Hive.box('attendance_scans');
          await box.put('scans_${widget.event.id}', _recentScans.map((s) => s.toJson()).toList());
        }
        _showError(msg);
      }
      
      _resumeScanning();
    }
  }

  void _showSuccess(QrScanUIModel scan) async {
    await HapticFeedback.mediumImpact();
    SystemSound.play(SystemSoundType.click);
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(LucideIcons.checkCircle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text('Recorded ${scan.type} for ${scan.name}')),
          ],
        ),
        backgroundColor: const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
    _resumeScanning();
  }

  void _showWarning(String message) async {
    await HapticFeedback.mediumImpact();
    SystemSound.play(SystemSoundType.click);
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(LucideIcons.wifiOff, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFE65100),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showError(String message) async {
    await HapticFeedback.heavyImpact();
    SystemSound.play(SystemSoundType.alert);
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFC62828),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _resumeScanning() {
    if (mounted) {
      setState(() => _isScanning = true);
      _controller.start().then((_) {
        _controller.setZoomScale(_zoomLevel);
      });
    }
  }

  void _toggleZoom() {
    setState(() {
      _zoomLevel = _zoomLevel == 0.0 ? 0.5 : 0.0;
    });
    _controller.setZoomScale(_zoomLevel);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme);

    return Theme(
      data: Theme.of(context).copyWith(textTheme: textTheme),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              // Custom AppBar (matches other screens)
              _buildCustomAppBar(),
              Expanded(
                child: ResponsiveLayout(
                  mobile: _buildMobileView(),
                  tablet: _buildDesktopView(isTablet: true),
                  desktop: _buildDesktopView(isTablet: false),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAppBar() {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;
    final isTablet = size.width >= 768 && size.width < 1024;

    final double topMargin = isMobile ? 8.0 : (isTablet ? 12.0 : 16.0);
    final double bottomMargin = isMobile ? 4.0 : (isTablet ? 6.0 : 8.0);
    final double horizontalMargin = isMobile ? 8.0 : (isTablet ? 12.0 : 16.0);
    final double borderRadius = isMobile ? 12.0 : 16.0;

    return Container(
      margin: EdgeInsets.only(
        top: topMargin,
        left: horizontalMargin,
        right: horizontalMargin,
        bottom: bottomMargin,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.1),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16.0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: isMobile ? 52.0 : 60.0,
        leading: Center(
          child: Padding(
            padding: EdgeInsets.only(left: isMobile ? 6.0 : 10.0),
            child: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: Container(
                width: isMobile ? 34 : 38,
                height: isMobile ? 34 : 38,
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.primary,
                  size: isMobile ? 18 : 20,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        titleSpacing: isMobile ? 4.0 : 8.0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Attendance Scanner',
              style: GoogleFonts.poppins(
                fontSize: isMobile ? 15 : (isTablet ? 16 : 18),
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              widget.event.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: isMobile ? 11 : 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textGrey,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: isMobile ? 12.0 : 16.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.12),
                  ),
                ),
                child: Text(
                  '${_recentScans.length} Scanned',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileView() {
    return Stack(
      children: [
        // Scanner View
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Calculate a safe scanner size
                final double minDimension = constraints.maxHeight < constraints.maxWidth 
                    ? constraints.maxHeight 
                    : constraints.maxWidth;
                final double scannerSize = minDimension * 0.7;

                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: MobileScanner(
                        controller: _controller,
                        onDetect: _handleScan,
                        fit: BoxFit.cover,
                      ),
                    ),
                    _buildOverlay(scannerSize),
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildScannerStatusIndicator(),
                          const SizedBox(height: 12),
                          _buildZoomControl(),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        
        // Draggable Info Panel
        DraggableScrollableSheet(
          initialChildSize: 0.45,
          minChildSize: 0.25,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 15,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: CustomScrollView(
                controller: scrollController,
                slivers: [
                  // Drag Handle
                  SliverToBoxAdapter(
                    child: Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 12, bottom: 8),
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                      child: QrCurrentEventCard(
                        event: widget.event,
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverToBoxAdapter(
                      child: QrSectionHeader(
                        title: 'Recent Scans',
                        subtitle: '${_recentScans.length} latest entries',
                        horizontalPadding: 0,
                        trailing: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AttendanceHistoryPage(
                                  eventId: widget.event.id!,
                                  eventName: widget.event.name,
                                  event: widget.event,
                                ),
                              ),
                            );
                          },
                          child: const Text(
                            'View All',
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  _buildRecentScansList(),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDesktopView({required bool isTablet}) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Side: Scanner
          Expanded(
            flex: isTablet ? 6 : 7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                QrSectionHeader(
                  title: 'Camera Preview',
                  subtitle: 'Auto-detecting QR Codes',
                  horizontalPadding: 0,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildZoomControl(),
                      const SizedBox(width: 12),
                      _buildScannerStatusIndicator(),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: QrScannerCard(
                    scannerController: _controller,
                    onCodeDetected: (val) {
                      final mode = widget.event.currentAttendanceMode;
                      if (mode == AttendanceMode.closed) {
                        _showError('Scanning is currently closed for this event.');
                        return;
                      }
                      _showActionModal(val, mode);
                    },
                    onRetryTap: () => _resumeScanning(),
                    isProcessing: !_isScanning,
                    scanModeLabel: 'Mode: ${widget.event.currentAttendanceMode.label}',
                  ),
                ),
                const SizedBox(height: 24),
                _buildDesktopInstructions(),
              ],
            ),
          ),
          const SizedBox(width: 24),
          // Right Side: Sidebar
          Expanded(
            flex: isTablet ? 4 : 3,
            child: Column(
              children: [
                QrCurrentEventCard(
                  event: widget.event,
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.black.withOpacity(0.05)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Session History', 
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            Row(
                              children: [
                                QrCountChip(label: 'Total', count: _recentScans.length),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(LucideIcons.refreshCcw, size: 18, color: primaryColor),
                                  onPressed: _loadRecentScans,
                                  constraints: const BoxConstraints(),
                                  padding: EdgeInsets.zero,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Expanded(
                          child: _isLoadingScans 
                            ? const Center(child: FlickrLoader())
                            : _recentScans.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(LucideIcons.clock, size: 42, color: primaryColor.withOpacity(0.1)),
                                      const SizedBox(height: 12),
                                      Text(
                                        'No scans yet', 
                                        style: GoogleFonts.poppins(
                                          color: Colors.black.withOpacity(0.3), 
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _recentScans.length,
                                  itemBuilder: (context, index) => QrRecentScanCard(scan: _recentScans[index]),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentScansList() {
    if (_isLoadingScans) {
      return const SliverFillRemaining(child: Center(child: FlickrLoader()));
    }
    if (_recentScans.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(LucideIcons.qrCode, size: 48, color: primaryColor.withOpacity(0.2)),
              ),
              const SizedBox(height: 16),
              Text(
                'No scans yet this session', 
                style: GoogleFonts.poppins(
                  color: Colors.black.withOpacity(0.4),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => QrRecentScanCard(scan: _recentScans[index]),
          childCount: _recentScans.length,
        ),
      ),
    );
  }

  Widget _buildZoomControl() {
    return GestureDetector(
      onTap: _toggleZoom,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Text(
              _zoomLevel == 0.0 ? '1x' : '2x',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScannerStatusIndicator() {
    final mode = widget.event.currentAttendanceMode;
    final isClosed = mode == AttendanceMode.closed;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isClosed
                ? const Color(0xFFC62828).withOpacity(0.85)
                : _isScanning
                    ? const Color(0xFF2E7D32).withOpacity(0.85)
                    : const Color(0xFFC62828).withOpacity(0.85),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                isClosed
                    ? 'CLOSED'
                    : _isScanning
                        ? 'LIVE: ${mode.label.toUpperCase()}'
                        : 'PAUSED',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopInstructions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryColor.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.info, color: primaryColor),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Operator Instructions', 
                  style: GoogleFonts.poppins(
                    color: primaryColor, 
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '1. Position student QR code in the frame. 2. Verify student info in the popup. 3. Select appropriate attendance action.',
                  style: GoogleFonts.poppins(
                    color: Colors.black.withOpacity(0.5),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlay(double size) {
    return Container(
      decoration: ShapeDecoration(
        shape: QrScannerOverlayShape(
          borderColor: accentColor,
          borderRadius: 24,
          borderLength: 30,
          borderWidth: 6,
          cutOutSize: size,
        ),
      ),
    );
  }
}

class _VerificationModal extends StatelessWidget {
  final QrPayload payload;
  final AttendanceMode mode;
  final VoidCallback onConfirm;
  final VoidCallback onReject;

  const _VerificationModal({
    required this.payload,
    required this.mode,
    required this.onConfirm,
    required this.onReject,
  });

  static const Color primaryColor = AppColors.primary;
  static const Color accentColor = AppColors.accent;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isSmallScreen = screenWidth < 360;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 24),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with accent
            Container(
              padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 16 : 20),
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, Color(0xFF002D7A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      LucideIcons.qrCode,
                      color: accentColor,
                      size: isSmallScreen ? 28 : 32,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Scan Confirmation',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  isSmallScreen ? 16 : 24, 
                  isSmallScreen ? 16 : 24, 
                  isSmallScreen ? 16 : 24, 
                  16,
                ),
                child: Column(
                  children: [
                    // Student Profile Info
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: isSmallScreen ? 56 : 64,
                          height: isSmallScreen ? 56 : 64,
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: primaryColor.withOpacity(0.1),
                            ),
                          ),
                          child: Icon(
                            LucideIcons.user,
                            color: primaryColor,
                            size: isSmallScreen ? 28 : 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                payload.fullName,
                                style: GoogleFonts.poppins(
                                  fontSize: isSmallScreen ? 15 : 17,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                payload.studentId,
                                style: GoogleFonts.poppins(
                                  fontSize: isSmallScreen ? 12 : 13,
                                  fontWeight: FontWeight.w600,
                                  color: primaryColor,
                                ),
                              ),
                              Text(
                                payload.program,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: isSmallScreen ? 11 : 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isSmallScreen ? 20 : 28),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: (mode == AttendanceMode.timeIn ? const Color(0xFF2E7D32) : const Color(0xFFC62828)).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: (mode == AttendanceMode.timeIn ? const Color(0xFF2E7D32) : const Color(0xFFC62828)).withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            mode == AttendanceMode.timeIn ? LucideIcons.logIn : LucideIcons.logOut,
                            color: mode == AttendanceMode.timeIn ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Recording ${mode.label}',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    color: mode == AttendanceMode.timeIn ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                                  ),
                                ),
                                Text(
                                  'Automatically determined by system time',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Actions
            Padding(
              padding: EdgeInsets.fromLTRB(
                isSmallScreen ? 16 : 24, 
                8, 
                isSmallScreen ? 16 : 24, 
                isSmallScreen ? 16 : 24,
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Confirm Attendance',
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 14 : 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: onReject,
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        side: BorderSide(
                          color: Colors.grey.shade300,
                        ),
                        foregroundColor: Colors.black87,
                      ),
                      child: Text(
                        'Reject / Cancel',
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 14 : 15,
                          fontWeight: FontWeight.w600,
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
}

class QrScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  const QrScannerOverlayShape({
    this.borderColor = Colors.white,
    this.borderWidth = 10,
    this.borderRadius = 0,
    this.borderLength = 40,
    this.cutOutSize = 250,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => Path();

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) => Path()..addRect(rect);

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final height = rect.height;

    final paint = Paint()
      ..color = Colors.black.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    // Ensure cutOutRect doesn't exceed the widget's boundaries
    final double actualSize = cutOutSize > 0 ? cutOutSize : 250.0;
    final double safeWidth = actualSize > width ? width * 0.8 : actualSize;
    final double safeHeight = actualSize > height ? height * 0.8 : actualSize;
    final double safeSize = safeWidth < safeHeight ? safeWidth : safeHeight;

    final cutOutRect = Rect.fromCenter(
      center: Offset(width / 2, (height / 2) ),
      width: safeSize,
      height: safeSize,
    );

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(rect),
        Path()..addRRect(RRect.fromRectAndRadius(cutOutRect, Radius.circular(borderRadius))),
      ),
      paint,
    );

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round;

    final borderPath = Path();
    
    // Top Left
    borderPath.moveTo(cutOutRect.left, cutOutRect.top + borderLength);
    borderPath.lineTo(cutOutRect.left, cutOutRect.top);
    borderPath.lineTo(cutOutRect.left + borderLength, cutOutRect.top);

    // Top Right
    borderPath.moveTo(cutOutRect.right - borderLength, cutOutRect.top);
    borderPath.lineTo(cutOutRect.right, cutOutRect.top);
    borderPath.lineTo(cutOutRect.right, cutOutRect.top + borderLength);

    // Bottom Right
    borderPath.moveTo(cutOutRect.right, cutOutRect.bottom - borderLength);
    borderPath.lineTo(cutOutRect.right, cutOutRect.bottom);
    borderPath.lineTo(cutOutRect.right - borderLength, cutOutRect.bottom);

    // Bottom Left
    borderPath.moveTo(cutOutRect.left + borderLength, cutOutRect.bottom);
    borderPath.lineTo(cutOutRect.left, cutOutRect.bottom);
    borderPath.lineTo(cutOutRect.left, cutOutRect.bottom - borderLength);

    canvas.drawPath(borderPath, borderPaint);
  }

  @override
  ShapeBorder scale(double t) => QrScannerOverlayShape(
        borderColor: borderColor,
        borderWidth: borderWidth,
        borderRadius: borderRadius,
        borderLength: borderLength,
        cutOutSize: cutOutSize,
      );
}
