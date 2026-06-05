import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/layouts/responsive_layout.dart';
import '../../events/models/event_model.dart';
import '../repositories/attendance_repository.dart';
import '../providers/attendance_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/qr_scan_ui_model.dart';
import '../models/qr_payload.dart';
import 'qr_current_event_card.dart';
import 'qr_recent_scan_card.dart';
import 'qr_scanner_card.dart';
import 'qr_section_header.dart';
import 'qr_count_chip.dart';
import '../../../core/utils/time_formatter.dart';
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
  List<QrScanUIModel> _recentScans = [];
  bool _isLoadingScans = true;

  static const Color primaryColor = Color(0xFF003DA5);
  static const Color accentColor = Color(0xFFFFC107);

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
    setState(() => _isLoadingScans = true);
    try {
      final repository = ref.read(attendanceRepositoryProvider);
      final rawScans = await repository.getRecentScansForEvent(widget.event.id!);
      
      final scans = rawScans.map((data) {
        final student = data['student'] as Map<String, dynamic>?;
        final firstName = student?['first_name'] ?? 'Unknown';
        final lastName = student?['last_name'] ?? 'Student';
        final studentId = student?['student_id_number'] ?? '-';
        final program = (student?['program'] as Map<String, dynamic>?)?['name'] ?? 'N/A';
        
        final timeIn = data['actual_time_in'];
        final timeOut = data['actual_time_out'];
        final time = timeOut ?? timeIn;
        final formattedTime = time != null 
            ? DateFormat('h:mm a').format(DateTime.parse(time).toLocal())
            : '-';
            
        return QrScanUIModel(
          name: '$firstName $lastName',
          studentId: studentId,
          program: program,
          time: formattedTime,
          status: 'success',
          type: timeOut != null ? 'Time Out' : 'Time In',
        );
      }).toList();

      if (mounted) {
        setState(() {
          _recentScans = scans;
          _isLoadingScans = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingScans = false);
      }
    }
  }

  Future<void> _handleScan(BarcodeCapture capture) async {
    if (!_isScanning) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final String? rawValue = barcode.rawValue;
      if (rawValue != null) {
        setState(() => _isScanning = false);
        _controller.stop();
        _showActionModal(rawValue);
        break;
      }
    }
  }

  void _showActionModal(String rawValue) {
    final payload = QrPayload.fromRawValue(rawValue);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _VerificationModal(
        payload: payload,
        onAction: (isTimeIn) async {
          Navigator.pop(context);
          await _processAttendance(payload, isTimeIn);
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

    try {
      final repository = ref.read(attendanceRepositoryProvider);
      
      await repository.recordAttendance(
        eventId: widget.event.id!,
        studentId: payload.studentId,
        scannedByUserId: officer.id!,
        isTimeIn: isTimeIn,
      );

      // Add to local recent scans
      final newScan = QrScanUIModel(
        name: payload.fullName,
        studentId: payload.studentId,
        program: payload.program,
        time: DateFormat('h:mm a').format(DateTime.now()),
        status: 'success',
        type: isTimeIn ? 'Time In' : 'Time Out',
      );

      if (mounted) {
        setState(() {
          _recentScans = [newScan, ..._recentScans];
        });
        _showSuccess(newScan);
      }
    } catch (e) {
      _showError('Error: $e');
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
      _controller.start();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme);

    return Theme(
      data: Theme.of(context).copyWith(textTheme: textTheme),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: [
              // Decorative Backgrounds
              Positioned(
                top: 80,
                right: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
              Positioned(
                bottom: 200,
                left: -30,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(75),
                  ),
                ),
              ),
              Column(
                children: [
                  // Custom AppBar
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: Colors.white,
      child: Column(
        children: [
          SizedBox(
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
                    icon: const Icon(
                      LucideIcons.arrowLeft,
                      color: primaryColor,
                      size: 21,
                    ),
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
                        text: 'Attendance ',
                        style: TextStyle(color: primaryColor),
                      ),
                      TextSpan(
                        text: 'Scanner',
                        style: TextStyle(color: accentColor),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: primaryColor.withOpacity(0.12),
                      ),
                    ),
                    child: Text(
                      '${_recentScans.length}',
                      style: const TextStyle(
                        color: primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.event.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: Colors.black.withOpacity(0.4),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileView() {
    return Column(
      children: [
        // Top Half: Scanner
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: MobileScanner(
                    controller: _controller,
                    onDetect: _handleScan,
                    fit: BoxFit.cover,
                  ),
                ),
                _buildOverlay(),
                Positioned(
                  top: 16,
                  right: 16,
                  child: _buildScannerStatusIndicator(),
                ),
              ],
            ),
          ),
        ),
        // Bottom Half: Info & History
        Expanded(
          flex: 5,
          child: Container(
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
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                    child: QrCurrentEventCard(
                      event: widget.event,
                      isTimeInActive: true,
                      onRecordTimeIn: () {},
                      onRecordTimeOut: () {},
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
          ),
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
                  trailing: _buildScannerStatusIndicator(),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: QrScannerCard(
                    scannerController: _controller,
                    onCodeDetected: (val) => _showActionModal(val),
                    onRetryTap: () => _resumeScanning(),
                    isProcessing: !_isScanning,
                    scanModeLabel: 'Auto-detecting QR Codes',
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
                  isTimeInActive: true,
                  onRecordTimeIn: () {},
                  onRecordTimeOut: () {},
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
                            ? const Center(child: CircularProgressIndicator(color: primaryColor))
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
      return const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: primaryColor)));
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

  Widget _buildScannerStatusIndicator() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _isScanning 
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
                _isScanning ? 'LIVE' : 'PAUSED',
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5),
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

  Widget _buildOverlay() {
    return Container(
      decoration: const ShapeDecoration(
        shape: QrScannerOverlayShape(
          borderColor: Colors.white,
          borderRadius: 24,
          borderLength: 40,
          borderWidth: 8,
          cutOutSize: 260,
        ),
      ),
    );
  }
}

class _VerificationModal extends StatelessWidget {
  final QrPayload payload;
  final Function(bool) onAction;
  final VoidCallback onReject;

  const _VerificationModal({
    required this.payload,
    required this.onAction,
    required this.onReject,
  });

  static const Color primaryColor = Color(0xFF003DA5);
  static const Color accentColor = Color(0xFFFFC107);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
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
              padding: const EdgeInsets.symmetric(vertical: 20),
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
                    child: const Icon(
                      LucideIcons.qrCode,
                      color: accentColor,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Scan Confirmation',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Column(
                  children: [
                    // Student Profile Info
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: primaryColor.withOpacity(0.1),
                            ),
                          ),
                          child: const Icon(
                            LucideIcons.user,
                            color: primaryColor,
                            size: 32,
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
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                payload.studentId,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: primaryColor,
                                ),
                              ),
                              Text(
                                payload.program,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Select Attendance Mode',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Improved Mode Selector
                    Row(
                      children: [
                        Expanded(
                          child: _buildModeOption(
                            label: 'Time In',
                            icon: LucideIcons.logIn,
                            color: const Color(0xFF2E7D32),
                            onTap: () => onAction(true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildModeOption(
                            label: 'Time Out',
                            icon: LucideIcons.logOut,
                            color: const Color(0xFFC62828),
                            onTap: () => onAction(false),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Actions
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onReject,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
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
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeOption({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
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

    final cutOutRect = Rect.fromCenter(
      center: Offset(width / 2, height / 2),
      width: cutOutSize,
      height: cutOutSize,
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
