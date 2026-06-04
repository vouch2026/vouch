import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../data/qr_event_attendance_service.dart';
import '../../domain/qr_event_session_entity.dart';
import '../../domain/qr_payload_entity.dart';
import '../../domain/qr_scan_record_entity.dart';
import '../providers/qr_scanner_controller.dart';
import '../widgets/qr_count_chip.dart';
import '../widgets/qr_current_event_card.dart';
import '../widgets/qr_recent_scan_card.dart';
import '../widgets/qr_scanner_card.dart';
import '../widgets/qr_section_header.dart';
import 'event_scans_screen.dart';

enum _ScanMode { timeIn, timeOut }

class _ConfirmationResult {
  final bool accepted;
  final _ScanMode mode;
  _ConfirmationResult(this.accepted, this.mode);
}

class ScanQrScreen extends StatefulWidget {
  final int? eventId;
  final String eventName;
  final String location;
  final String timeWindow;
  final bool isEventActive;
  final String? timeInStart;
  final String? timeInEnd;
  final String? timeOutStart;
  final String? timeOutEnd;

  const ScanQrScreen({
    super.key,
    this.eventId,
    this.eventName = 'Event',
    this.location = 'University Campus',
    this.timeWindow = 'Time in: -  •  Time out: -',
    this.isEventActive = true,
    this.timeInStart,
    this.timeInEnd,
    this.timeOutStart,
    this.timeOutEnd,
  });

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  final QrScannerController _scannerController = QrScannerController();
  late final MobileScannerController _mobileScannerController;
  final QrEventAttendanceService _attendanceService =
      QrEventAttendanceService.instance;

  late QrEventSessionEntity _currentEvent;
  List<QrScanRecordEntity> _recentScans = const [];
  bool _isLoadingAttendance = false;
  bool _isSavingScan = false;
  _ScanMode _scanMode = _ScanMode.timeIn;
  String _lastScannedRawValue = '';
  DateTime? _lastScannedAt;
  bool _showScannerInitHelp = false;
  Timer? _scannerInitTimer;
  Timer? _lockCheckTimer;
  bool _isLocked = false;

  int get totalScans => _currentEvent.totalScans;

  @override
  void initState() {
    super.initState();

    _mobileScannerController = MobileScannerController(
      autoStart: true,
      facing: CameraFacing.back,
      detectionSpeed: DetectionSpeed.normal,
      detectionTimeoutMs: 300,
    );
    _mobileScannerController.addListener(_onScannerStateChanged);

    _currentEvent = _buildCurrentEvent(totalScans: 0);
    _loadAttendanceSummary();
    _scheduleScannerInitHelp();
    _checkLockStatus();
    _lockCheckTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _checkLockStatus(),
    );
  }

  void _checkLockStatus() {
    if (!mounted) return;

    final inTimeIn = _isNowBetween(widget.timeInStart, widget.timeInEnd);
    final inTimeOut = _isNowBetween(widget.timeOutStart, widget.timeOutEnd);

    setState(() {
      if (inTimeIn) {
        _isLocked = false;
        _scanMode = _ScanMode.timeIn;
      } else if (inTimeOut) {
        _isLocked = false;
        _scanMode = _ScanMode.timeOut;
      } else {
        // If no time windows are provided, we don't lock (fallback)
        final hasWindows = widget.timeInStart != null ||
            widget.timeInEnd != null ||
            widget.timeOutStart != null ||
            widget.timeOutEnd != null;

        _isLocked = hasWindows;
      }
    });
  }

  bool _isNowBetween(String? start, String? end) {
    if (start == null || end == null || start.isEmpty || end.isEmpty) {
      return false;
    }

    final now = DateTime.now();
    final startTime = _parseTimeString(start);
    final endTime = _parseTimeString(end);

    if (startTime == null || endTime == null) {
      return false;
    }

    final startDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      startTime.hour,
      startTime.minute,
    );
    final endDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      endTime.hour,
      endTime.minute,
    );

    return now.isAfter(startDateTime) && now.isBefore(endDateTime);
  }

  TimeOfDay? _parseTimeString(String timeStr) {
    try {
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    } catch (_) {}
    return null;
  }

  Future<void> _handleDetectedQr(String rawValue) async {
    if (_isLocked) {
      return;
    }
    final normalized = rawValue.trim();
    if (normalized.isEmpty || _isSavingScan) {
      return;
    }

    final now = DateTime.now();
    final lastAt = _lastScannedAt;
    if (lastAt != null &&
        _lastScannedRawValue == normalized &&
        now.difference(lastAt) < const Duration(seconds: 2)) {
      return;
    }

    _lastScannedRawValue = normalized;
    _lastScannedAt = now;

    await _processScannedQr(normalized);
  }

  Future<void> _processScannedQr(String rawValue) async {
    if (_isSavingScan) {
      return;
    }

    final eventId = widget.eventId;
    if (eventId == null) {
      _showSnack(
        message: 'Missing event ID. Open this scanner from Event Details.',
        backgroundColor: const Color(0xFFC62828),
      );
      return;
    }

    setState(() => _isSavingScan = true);

    final isVerified = await _scannerController.verify(rawValue);
    final payload = _scannerController.lastPayload;

    if (!mounted) {
      return;
    }

    if (!isVerified || payload == null) {
      _prependLocalScan(
        QrScanRecordEntity(
          name: 'Unknown Student',
          studentId: '-',
          program: 'N/A',
          time: _formatDisplayTime(DateTime.now()),
          status: 'error',
          type: _scanModeLabel,
        ),
      );

      setState(() => _isSavingScan = false);
      await _emitScanFeedback(success: false);
      _showSnack(
        message: 'Invalid QR code',
        backgroundColor: const Color(0xFFC62828),
      );
      return;
    }

    // Stop scanner preview during confirmation
    try {
      await _mobileScannerController.stop();
    } catch (_) {}

    final confirmation = await _showConfirmationDialog(payload);

    if (confirmation == null || !confirmation.accepted) {
      // Resume scanner if rejected
      try {
        await _mobileScannerController.start();
      } catch (_) {}

      setState(() => _isSavingScan = false);
      // Reset last scanned to allow scanning the same code again immediately if rejected
      _lastScannedRawValue = '';
      _lastScannedAt = null;
      return;
    }

    final result = await _attendanceService.recordScan(
      eventId: eventId,
      studentId: payload.studentId,
      mode: confirmation.mode == _ScanMode.timeIn
          ? AttendanceScanMode.timeIn
          : AttendanceScanMode.timeOut,
      studentName: payload.fullName,
      studentProgram: payload.program,
    );

    // Resume scanner after recording
    try {
      await _mobileScannerController.start();
    } catch (_) {}

    if (!mounted) {
      return;
    }

    _prependLocalScan(
      QrScanRecordEntity(
        name: payload.fullName.isEmpty ? payload.studentId : payload.fullName,
        studentId: payload.studentId,
        program: payload.program.isEmpty ? 'N/A' : payload.program,
        time: _formatDisplayTime(result.scannedAt?.toLocal() ?? DateTime.now()),
        status: result.success ? 'success' : 'error',
        type: confirmation.mode == _ScanMode.timeIn ? 'Time In' : 'Time Out',
      ),
    );

    if (result.success) {
      await _loadAttendanceSummary(showLoader: false);
    }

    setState(() => _isSavingScan = false);
    await _emitScanFeedback(success: result.success);

    _showSnack(
      message: result.message,
      backgroundColor: result.success
          ? const Color(0xFF2E7D32)
          : const Color(0xFFC62828),
    );
  }

  Future<_ConfirmationResult?> _showConfirmationDialog(
    QrPayloadEntity payload,
  ) async {
    _ScanMode selectedMode = _scanMode;
    final inTimeIn = _isNowBetween(widget.timeInStart, widget.timeInEnd);
    final inTimeOut = _isNowBetween(widget.timeOutStart, widget.timeOutEnd);

    return showDialog<_ConfirmationResult>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
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
                          colors: [Color(0xFF003DA5), Color(0xFF002D7A)],
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
                              Ionicons.qr_code,
                              color: Color(0xFFFFC107),
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Scan Confirmation',
                            style: TextStyle(
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
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF003DA5)
                                        .withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xFF003DA5)
                                          .withOpacity(0.1),
                                    ),
                                  ),
                                  child: const Icon(
                                    Ionicons.person,
                                    color: Color(0xFF003DA5),
                                    size: 30,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        payload.fullName,
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        payload.studentId,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF003DA5),
                                        ),
                                      ),
                                      Text(
                                        payload.program,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
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
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Select Attendance Mode',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Improved Mode Selector
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _buildModeOption(
                                      label: 'Time In',
                                      icon: Ionicons.log_in,
                                      isSelected:
                                          selectedMode == _ScanMode.timeIn,
                                      activeColor: const Color(0xFF2E7D32),
                                      isDisabled: inTimeOut,
                                      onTap: () {
                                        if (!inTimeOut) {
                                          setDialogState(
                                            () =>
                                                selectedMode = _ScanMode.timeIn,
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: _buildModeOption(
                                      label: 'Time Out',
                                      icon: Ionicons.log_out,
                                      isSelected:
                                          selectedMode == _ScanMode.timeOut,
                                      activeColor: const Color(0xFFC62828),
                                      isDisabled: inTimeIn,
                                      onTap: () {
                                        if (!inTimeIn) {
                                          setDialogState(
                                            () => selectedMode =
                                                _ScanMode.timeOut,
                                          );
                                        }
                                      },
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
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(
                                _ConfirmationResult(false, selectedMode),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                side: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                                foregroundColor: Colors.black87,
                              ),
                              child: const Text(
                                'Reject',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(
                                _ConfirmationResult(true, selectedMode),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF003DA5),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text(
                                'Accept',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
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
          },
        );
      },
    );
  }

  Widget _buildModeOption({
    required String label,
    required IconData icon,
    required bool isSelected,
    required Color activeColor,
    required VoidCallback onTap,
    bool isDisabled = false,
  }) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white
              : (isDisabled ? Colors.grey.withOpacity(0.05) : Colors.transparent),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
          border: isSelected
              ? Border.all(color: activeColor.withOpacity(0.3), width: 1)
              : Border.all(color: Colors.transparent, width: 1),
        ),
        child: Opacity(
          opacity: isDisabled ? 0.4 : 1.0,
          child: Column(
            children: [
              Icon(
                icon,
                size: 24,
                color: isSelected ? activeColor : Colors.black38,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? activeColor : Colors.black38,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _recordTimeIn() {
    if (_isNowBetween(widget.timeOutStart, widget.timeOutEnd)) {
      _showSnack(
        message: 'Manual switching disabled. Only Time Out is allowed during this period.',
        backgroundColor: const Color(0xFFC62828),
      );
      return;
    }
    setState(() => _scanMode = _ScanMode.timeIn);
    _showSnack(
      message: 'Scanner mode set to Time In',
      backgroundColor: const Color(0xFF003DA5),
    );
  }

  void _recordTimeOut() {
    if (_isNowBetween(widget.timeInStart, widget.timeInEnd)) {
      _showSnack(
        message: 'Manual switching disabled. Only Time In is allowed during this period.',
        backgroundColor: const Color(0xFFC62828),
      );
      return;
    }
    setState(() => _scanMode = _ScanMode.timeOut);
    _showSnack(
      message: 'Scanner mode set to Time Out',
      backgroundColor: const Color(0xFF003DA5),
    );
  }

  Future<void> _loadAttendanceSummary({bool showLoader = true}) async {
    final eventId = widget.eventId;
    if (eventId == null) {
      return;
    }

    if (showLoader && mounted) {
      setState(() => _isLoadingAttendance = true);
    }

    try {
      final summary = await _attendanceService.fetchEventAttendanceSummary(
        eventId: eventId,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _currentEvent = _buildCurrentEvent(totalScans: summary.totalScans);
        _recentScans = summary.recentScans;
        _isLoadingAttendance = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() => _isLoadingAttendance = false);
    }
  }

  QrEventSessionEntity _buildCurrentEvent({required int totalScans}) {
    final normalizedName = widget.eventName.trim();
    final normalizedLocation = widget.location.trim();
    final normalizedTimeWindow = widget.timeWindow.trim();

    return QrEventSessionEntity(
      eventName: normalizedName.isEmpty ? 'Event' : normalizedName,
      location: normalizedLocation.isEmpty
          ? 'University Campus'
          : normalizedLocation,
      timeWindow: normalizedTimeWindow.isEmpty
          ? 'Time in: -  •  Time out: -'
          : normalizedTimeWindow,
      isActive: widget.isEventActive,
      totalScans: totalScans,
    );
  }

  void _prependLocalScan(QrScanRecordEntity scan) {
    setState(() {
      _recentScans = [scan, ..._recentScans].take(12).toList();
    });
  }

  String get _scanModeLabel {
    return _scanMode == _ScanMode.timeIn ? 'Time In' : 'Time Out';
  }

  String _formatDisplayTime(DateTime value) {
    final hour24 = value.hour;
    final minuteText = value.minute.toString().padLeft(2, '0');
    final period = hour24 >= 12 ? 'PM' : 'AM';
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;

    return '$hour12:$minuteText $period';
  }

  void _showSnack({required String message, required Color backgroundColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _emitScanFeedback({required bool success}) async {
    if (success) {
      await HapticFeedback.mediumImpact();
      SystemSound.play(SystemSoundType.click);
      return;
    }

    await HapticFeedback.heavyImpact();
    SystemSound.play(SystemSoundType.alert);
  }

  Future<void> _restartScannerPreview() async {
    _lastScannedRawValue = '';
    _lastScannedAt = null;

    if (mounted) {
      setState(() => _showScannerInitHelp = false);
    }

    _scheduleScannerInitHelp();

    try {
      await _mobileScannerController.stop();
    } catch (_) {}

    try {
      await _mobileScannerController.start();
    } catch (_) {}
  }

  void _scheduleScannerInitHelp() {
    _scannerInitTimer?.cancel();
    _scannerInitTimer = Timer(const Duration(seconds: 6), () {
      if (!mounted) {
        return;
      }

      final state = _mobileScannerController.value;
      if (!state.isInitialized && state.error == null) {
        setState(() => _showScannerInitHelp = true);
      }
    });
  }

  void _onScannerStateChanged() {
    if (!mounted) {
      return;
    }

    final state = _mobileScannerController.value;
    if (state.isInitialized || state.error != null) {
      _scannerInitTimer?.cancel();
      if (_showScannerInitHelp) {
        setState(() => _showScannerInitHelp = false);
      }
    }
  }

  @override
  void dispose() {
    _scannerInitTimer?.cancel();
    _mobileScannerController.removeListener(_onScannerStateChanged);
    _mobileScannerController.dispose();
    _scannerController.dispose();
    super.dispose();
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
              Positioned(
                top: 80,
                right: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC107).withOpacity(0.15),
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
                    color: const Color(0xFF003DA5).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(75),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
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
                                icon: const Icon(
                                  Ionicons.arrow_back,
                                  color: Color(0xFF003DA5),
                                  size: 21,
                                ),
                              ),
                            ),
                            RichText(
                              text: const TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Scan ',
                                    style: TextStyle(
                                      color: Color(0xFF003DA5),
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'QR',
                                    style: TextStyle(
                                      color: Color(0xFFFFC107),
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.eventId == null)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFC62828).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFC62828).withOpacity(0.3),
                                  ),
                                ),
                                child: const Text(
                                  'This scanner was opened without an event context. Go back and open it from Event Details.',
                                  style: TextStyle(
                                    color: Color(0xFFC62828),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          const QrSectionHeader(
                            title: 'Current Event',
                            subtitle: 'Active window for attendance capture',
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: QrCurrentEventCard(
                              event: _currentEvent,
                              isTimeInActive: _scanMode == _ScanMode.timeIn,
                              onRecordTimeIn: _recordTimeIn,
                              onRecordTimeOut: _recordTimeOut,
                            ),
                          ),
                          const SizedBox(height: 22),
                          const QrSectionHeader(
                            title: 'QR Scanner',
                            subtitle:
                                'Position the QR inside the frame and start scan',
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                QrCountChip(label: 'Total', count: totalScans),
                                QrCountChip(
                                  label: 'Successful',
                                  count: _successCount,
                                ),
                                QrCountChip(label: 'Errors', count: _errorCount),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF003DA5).withOpacity(0.08),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFF003DA5).withOpacity(0.12),
                                ),
                              ),
                              child: Text(
                                'Current Scan Mode: $_scanModeLabel',
                                style: const TextStyle(
                                  color: Color(0xFF003DA5),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: QrScannerCard(
                              scannerController: _mobileScannerController,
                              onCodeDetected: _handleDetectedQr,
                              onRetryTap: () {
                                _restartScannerPreview();
                              },
                              isProcessing: _isSavingScan,
                              scanModeLabel: _scanModeLabel,
                              isLocked: _isLocked,
                            ),
                          ),
                          if (_showScannerInitHelp)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFC107).withOpacity(0.14),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xFFFFC107).withOpacity(0.45),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Camera is taking longer than expected to initialize.',
                                      style: TextStyle(
                                        color: Color(0xFF6D4C00),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    const Text(
                                      'Check camera permission, then tap Retry Camera.',
                                      style: TextStyle(
                                        color: Color(0xFF6D4C00),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: OutlinedButton.icon(
                                        onPressed: () {
                                          _restartScannerPreview();
                                        },
                                        icon: const Icon(Ionicons.refresh, size: 16),
                                        label: const Text('Retry Camera'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: const Color(0xFF003DA5),
                                          side: BorderSide(
                                            color: const Color(
                                              0xFF003DA5,
                                            ).withOpacity(0.3),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          const SizedBox(height: 22),
                          QrSectionHeader(
                            title: 'Recent Scans',
                            subtitle: '${_recentScans.length} latest entries',
                            trailing: TextButton(
                              onPressed: () {
                                final eventId = widget.eventId;
                                if (eventId != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EventScansScreen(
                                        eventId: eventId,
                                        eventName: widget.eventName,
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: const Text(
                                'View All',
                                style: TextStyle(
                                  color: Color(0xFF003DA5),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: _isLoadingAttendance && _recentScans.isEmpty
                                ? const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 20),
                                    child: Center(child: CircularProgressIndicator()),
                                  )
                                : _recentScans.isEmpty
                                ? Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(
                                          0xFF003DA5,
                                        ).withOpacity(0.1),
                                      ),
                                    ),
                                    child: const Text(
                                      'No scans recorded yet for this event.',
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  )
                                : Column(
                                    children: _recentScans
                                        .map((scan) => QrRecentScanCard(scan: scan))
                                        .toList(),
                                  ),
                          ),
                        ],
                      ),
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

  int get _successCount {
    return _recentScans.where((scan) => scan.status == 'success').length;
  }

  int get _errorCount {
    return _recentScans.where((scan) => scan.status == 'error').length;
  }
}
