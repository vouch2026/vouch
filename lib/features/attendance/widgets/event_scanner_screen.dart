import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart' hide TextDirection;

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

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController();
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
            ? DateFormat.jm().format(DateTime.parse(time).toLocal())
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
        time: DateFormat.jm().format(DateTime.now()),
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

  void _showSuccess(QrScanUIModel scan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text('Recorded ${scan.type} for ${scan.name}')),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
    _resumeScanning();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Attendance Scanner', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(widget.event.name, style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(LucideIcons.history),
            onPressed: () => _loadRecentScans(),
            tooltip: 'Refresh History',
          ),
        ],
      ),
      body: ResponsiveLayout(
        mobile: _buildMobileView(),
        tablet: _buildDesktopView(isTablet: true),
        desktop: _buildDesktopView(isTablet: false),
      ),
    );
  }

  Widget _buildMobileView() {
    return Column(
      children: [
        // Top Half: Scanner
        Expanded(
          flex: 4,
          child: Stack(
            children: [
              MobileScanner(
                controller: _controller,
                onDetect: _handleScan,
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
        // Bottom Half: Info & History
        Expanded(
          flex: 5,
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: QrCurrentEventCard(
                      event: widget.event,
                      isTimeInActive: true, // Not used in this screen anymore but required by widget
                      onRecordTimeIn: () {}, // Not used
                      onRecordTimeOut: () {}, // Not used
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Recent Scans', style: AppTextStyles.headlineSmall),
                        Text('${_recentScans.length} total', style: AppTextStyles.labelSmall),
                      ],
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
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Camera Preview', style: AppTextStyles.headlineMedium),
                  const SizedBox(height: 16),
                  AspectRatio(
                    aspectRatio: 16 / 9,
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
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Session History', style: AppTextStyles.headlineSmall),
                            IconButton(
                              icon: Icon(LucideIcons.refreshCw, size: 16),
                              onPressed: _loadRecentScans,
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Expanded(
                          child: _isLoadingScans 
                            ? const Center(child: CircularProgressIndicator())
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
      return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
    }
    if (_recentScans.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.qrCode, size: 48, color: AppColors.textGrey.withOpacity(0.3)),
              const SizedBox(height: 12),
              Text('No scans yet this session', style: AppTextStyles.labelLarge),
            ],
          ),
        ),
      );
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: QrRecentScanCard(scan: _recentScans[index]),
        ),
        childCount: _recentScans.length,
      ),
    );
  }

  Widget _buildScannerStatusIndicator() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _isScanning ? AppColors.success.withOpacity(0.8) : AppColors.error.withOpacity(0.8),
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
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopInstructions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.info, color: AppColors.info),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Operator Instructions', style: AppTextStyles.headlineSmall.copyWith(color: AppColors.info)),
                const SizedBox(height: 4),
                Text(
                  '1. Position student QR code in the frame. 2. Verify student info in the popup. 3. Select appropriate attendance action.',
                  style: AppTextStyles.bodySmall,
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
          borderRadius: 20,
          borderLength: 40,
          borderWidth: 8,
          cutOutSize: 250,
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(LucideIcons.userCheck, color: AppColors.primary, size: 40),
            ),
            const SizedBox(height: 16),
            const Text(
              'Verify Student',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              payload.fullName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.primary),
              textAlign: TextAlign.center,
            ),
            Text(
              '${payload.studentId} • ${payload.program}',
              style: TextStyle(color: AppColors.textGrey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const Text(
              'Select Attendance Action:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => onAction(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Time In', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => onAction(false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Time Out', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onReject,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Reject / Cancel'),
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
      ..color = Colors.black.withOpacity(0.5)
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
