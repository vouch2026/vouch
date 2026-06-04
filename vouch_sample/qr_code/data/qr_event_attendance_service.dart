import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/data/local/database_helper.dart';
import '../domain/qr_scan_record_entity.dart';

enum AttendanceScanMode { timeIn, timeOut }

class AttendanceScanResult {
  const AttendanceScanResult({
    required this.success,
    required this.alreadyScanned,
    required this.message,
    this.scannedAt,
  });

  final bool success;
  final bool alreadyScanned;
  final String message;
  final DateTime? scannedAt;
}

class EventAttendanceSummary {
  const EventAttendanceSummary({
    required this.totalScans,
    required this.recentScans,
  });

  final int totalScans;
  final List<QrScanRecordEntity> recentScans;
}

class QrEventAttendanceService {
  QrEventAttendanceService._();

  static final QrEventAttendanceService instance = QrEventAttendanceService._();

  final SupabaseClient _client = Supabase.instance.client;
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  static const String _attendanceTable = 'event_attendance';
  static const String _studentsTable = 'students';
  static const String _scanModeTimeIn = 'time_in';
  static const String _scanModeTimeOut = 'time_out';
  static const String _historyCachePrefix = 'cached_event_scan_history_v1_';
  static const String _summaryCachePrefix = 'cached_event_scan_summary_v1_';

  Timer? _backgroundSyncTimer;
  bool _isSyncingPendingScans = false;

  void startBackgroundSync({
    Duration interval = const Duration(seconds: 30),
  }) {
    if (_backgroundSyncTimer != null) {
      return;
    }

    _backgroundSyncTimer = Timer.periodic(interval, (_) {
      unawaited(syncOfflineScans());
    });

    unawaited(syncOfflineScans());
  }

  Future<AttendanceScanResult> recordScan({
    required int eventId,
    required String studentId,
    required AttendanceScanMode mode,
    String? studentName,
    String? studentProgram,
  }) async {
    final normalizedStudentId = studentId.trim();
    if (normalizedStudentId.isEmpty) {
      return const AttendanceScanResult(
        success: false,
        alreadyScanned: false,
        message: 'Student ID is missing from QR payload.',
      );
    }

    final scannedAt = DateTime.now().toUtc();

    final connectivityResult = await Connectivity().checkConnectivity();
    final isOffline = connectivityResult == ConnectivityResult.none;

    if (isOffline) {
      final duplicateOffline = await _isDuplicateOfflineScan(
        eventId: eventId,
        studentId: normalizedStudentId,
        mode: mode,
      );
      if (duplicateOffline) {
        return AttendanceScanResult(
          success: false,
          alreadyScanned: true,
          scannedAt: scannedAt,
          message: _duplicateMessage(mode),
        );
      }

      await _databaseHelper.insertPendingScan(
        eventId: eventId,
        studentId: normalizedStudentId,
        mode: _serializeMode(mode),
        scannedAt: scannedAt.toIso8601String(),
      );

      await _appendScanToLocalCache(
        eventId: eventId,
        studentId: normalizedStudentId,
        mode: mode,
        scannedAt: scannedAt,
        studentName: studentName,
        studentProgram: studentProgram,
      );

      return AttendanceScanResult(
        success: true,
        alreadyScanned: false,
        scannedAt: scannedAt,
        message: 'Offline: Scan saved locally. Will sync when connected.',
      );
    }

    try {
      await syncOfflineScans();

      return await _recordScanOnline(
        eventId: eventId,
        studentId: normalizedStudentId,
        mode: mode,
        scannedAt: scannedAt,
      );
    } catch (error) {
      if (error is PostgrestException && !_isConnectivityError(error)) {
        final message = error.message.trim();
        return AttendanceScanResult(
          success: false,
          alreadyScanned: false,
          message: message.isEmpty
              ? 'Failed to save attendance record.'
              : message,
        );
      }

      final duplicateOffline = await _isDuplicateOfflineScan(
        eventId: eventId,
        studentId: normalizedStudentId,
        mode: mode,
      );
      if (duplicateOffline) {
        return AttendanceScanResult(
          success: false,
          alreadyScanned: true,
          scannedAt: scannedAt,
          message: _duplicateMessage(mode),
        );
      }

      await _databaseHelper.insertPendingScan(
        eventId: eventId,
        studentId: normalizedStudentId,
        mode: _serializeMode(mode),
        scannedAt: scannedAt.toIso8601String(),
      );

      await _appendScanToLocalCache(
        eventId: eventId,
        studentId: normalizedStudentId,
        mode: mode,
        scannedAt: scannedAt,
        studentName: studentName,
        studentProgram: studentProgram,
      );

      return AttendanceScanResult(
        success: true,
        alreadyScanned: false,
        scannedAt: scannedAt,
        message: 'Network error. Scan saved locally.',
      );
    }
  }

  Future<int> syncOfflineScans() async {
    if (_isSyncingPendingScans) {
      return 0;
    }

    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return 0;
    }

    _isSyncingPendingScans = true;
    var syncedCount = 0;

    try {
      final pendingScans = await _databaseHelper.getPendingScans();
      if (pendingScans.isEmpty) {
        return 0;
      }

      for (final scan in pendingScans) {
        try {
          final id = scan['id'] as int?;
          final eventId = scan['event_id'] as int?;
          final studentId = scan['student_id']?.toString().trim() ?? '';
          final modeString = (scan['mode'] ?? scan['scan_mode'])?.toString().trim() ?? '';
          final scannedAtStr = scan['scanned_at']?.toString().trim() ?? '';

          if (id == null || eventId == null || studentId.isEmpty || modeString.isEmpty || scannedAtStr.isEmpty) {
            if (id != null) {
              await _databaseHelper.deletePendingScan(id);
            }
            continue;
          }

          final mode = _deserializeMode(modeString);
          if (mode == null) {
            await _databaseHelper.deletePendingScan(id);
            continue;
          }

          final scannedAt = DateTime.tryParse(scannedAtStr)?.toUtc() ?? DateTime.now().toUtc();

          await _pushToSupabase(eventId, studentId, mode, scannedAt);
          await _databaseHelper.deletePendingScan(id);
          syncedCount += 1;
        } catch (_) {
          continue;
        }
      }
    } finally {
      _isSyncingPendingScans = false;
    }

    return syncedCount;
  }

  Future<void> syncPendingScans() {
    return syncOfflineScans();
  }

  Future<void> _pushToSupabase(
    int eventId,
    String studentId,
    AttendanceScanMode mode,
    DateTime scannedAt,
  ) {
    return _recordScanOnline(
      eventId: eventId,
      studentId: studentId,
      mode: mode,
      scannedAt: scannedAt,
    ).then((result) {
      if (!result.success && !result.alreadyScanned) {
        throw Exception(result.message);
      }
    });
  }

  Future<bool> _isDuplicateOfflineScan({
    required int eventId,
    required String studentId,
    required AttendanceScanMode mode,
  }) async {
    final serializedMode = _serializeMode(mode);
    final hasPending = await _databaseHelper.hasPendingScan(
      eventId: eventId,
      studentId: studentId,
      mode: serializedMode,
    );
    if (hasPending) {
      return true;
    }

    final cachedHistory = await _loadCachedEventHistory(eventId);
    final targetType = mode == AttendanceScanMode.timeIn ? 'Time In' : 'Time Out';
    return cachedHistory.any(
      (scan) =>
          scan.studentId.trim().toLowerCase() == studentId.trim().toLowerCase() &&
          scan.type.trim().toLowerCase() == targetType.toLowerCase(),
    );
  }

  String _duplicateMessage(AttendanceScanMode mode) {
    return mode == AttendanceScanMode.timeIn
        ? 'This student already has a Time In scan for this event.'
        : 'This student already has a Time Out scan for this event.';
  }

  Future<AttendanceScanResult> _recordScanOnline({
    required int eventId,
    required String studentId,
    required AttendanceScanMode mode,
    required DateTime scannedAt,
  }) async {
    final normalizedStudentId = studentId.trim();
    final nowIso = scannedAt.toIso8601String();

    final existing = await _client
        .from(_attendanceTable)
        .select('scanned_time_in, scanned_time_out')
        .eq('event_id', eventId)
        .eq('student_id', normalizedStudentId)
        .maybeSingle();

    if (existing == null) {
      final insertPayload = <String, dynamic>{
        'event_id': eventId,
        'student_id': normalizedStudentId,
        'status': 'pending',
      };

      if (mode == AttendanceScanMode.timeIn) {
        insertPayload['scanned_time_in'] = nowIso;
      } else {
        insertPayload['scanned_time_out'] = nowIso;
      }

      await _client.from(_attendanceTable).insert(insertPayload);

      return AttendanceScanResult(
        success: true,
        alreadyScanned: false,
        scannedAt: scannedAt,
        message: mode == AttendanceScanMode.timeIn
            ? 'Time In recorded successfully.'
            : 'Time Out recorded successfully.',
      );
    }

    final hasTimeIn = _parseDateTime(existing['scanned_time_in']) != null;
    final hasTimeOut = _parseDateTime(existing['scanned_time_out']) != null;

    if (mode == AttendanceScanMode.timeIn && hasTimeIn) {
      return const AttendanceScanResult(
        success: false,
        alreadyScanned: true,
        message: 'This student already has a Time In scan for this event.',
      );
    }

    if (mode == AttendanceScanMode.timeOut && hasTimeOut) {
      return const AttendanceScanResult(
        success: false,
        alreadyScanned: true,
        message: 'This student already has a Time Out scan for this event.',
      );
    }

    final updatePayload = <String, dynamic>{
      if (mode == AttendanceScanMode.timeIn) 'scanned_time_in': nowIso,
      if (mode == AttendanceScanMode.timeOut) 'scanned_time_out': nowIso,
    };

    final nextHasTimeIn = hasTimeIn || mode == AttendanceScanMode.timeIn;
    final nextHasTimeOut = hasTimeOut || mode == AttendanceScanMode.timeOut;
    updatePayload['status'] = nextHasTimeIn && nextHasTimeOut
        ? 'completed'
        : 'pending';

    await _client
        .from(_attendanceTable)
        .update(updatePayload)
        .eq('event_id', eventId)
        .eq('student_id', normalizedStudentId);

    return AttendanceScanResult(
      success: true,
      alreadyScanned: false,
      scannedAt: scannedAt,
      message: mode == AttendanceScanMode.timeIn
          ? 'Time In updated successfully.'
          : 'Time Out updated successfully.',
    );
  }

  Future<EventAttendanceSummary> fetchEventAttendanceSummary({
    required int eventId,
    int recentLimit = 12,
  }) async {
    try {
      final response = await _client
          .from(_attendanceTable)
          .select('student_id, scanned_time_in, scanned_time_out')
          .eq('event_id', eventId);

      final attendanceRows = List<Map<String, dynamic>>.from(response);

      final uniqueStudentIds = attendanceRows
          .map((row) => row['student_id']?.toString().trim() ?? '')
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();

      final studentsById = <String, Map<String, dynamic>>{};
      if (uniqueStudentIds.isNotEmpty) {
        final studentsResponse = await _client
            .from(_studentsTable)
            .select('student_id, full_name, program')
            .inFilter('student_id', uniqueStudentIds);

        final studentsRows = List<Map<String, dynamic>>.from(studentsResponse);
        for (final row in studentsRows) {
          final studentId = row['student_id']?.toString().trim() ?? '';
          if (studentId.isNotEmpty) {
            studentsById[studentId] = row;
          }
        }
      }

      final timeline = <_ScanTimelineRecord>[];

      for (final row in attendanceRows) {
        final studentId = row['student_id']?.toString().trim() ?? '';
        if (studentId.isEmpty) {
          continue;
        }

        final student = studentsById[studentId];
        final fullName = student?['full_name']?.toString().trim() ?? studentId;
        final program = student?['program']?.toString().trim() ?? 'N/A';

        final timeIn = _parseDateTime(row['scanned_time_in']);
        final timeOut = _parseDateTime(row['scanned_time_out']);

        if (timeIn != null) {
          timeline.add(
            _ScanTimelineRecord(
              studentId: studentId,
              fullName: fullName,
              program: program,
              scannedAt: timeIn,
              type: 'Time In',
            ),
          );
        }

        if (timeOut != null) {
          timeline.add(
            _ScanTimelineRecord(
              studentId: studentId,
              fullName: fullName,
              program: program,
              scannedAt: timeOut,
              type: 'Time Out',
            ),
          );
        }
      }

      timeline.sort((a, b) => b.scannedAt.compareTo(a.scannedAt));

      final recentScans = timeline
          .take(recentLimit)
          .map(
            (record) => QrScanRecordEntity(
              name: record.fullName,
              studentId: record.studentId,
              program: record.program,
              time: _formatDisplayTime(record.scannedAt.toLocal()),
              status: 'success',
              type: record.type,
            ),
          )
          .toList();

      final summary = EventAttendanceSummary(
        totalScans: attendanceRows.length,
        recentScans: recentScans,
      );

      await _cacheEventSummary(eventId, summary);
      return summary;
    } catch (_) {
      final cached = await _loadCachedEventSummary(eventId);
      if (cached != null) {
        return cached;
      }
      rethrow;
    }
  }

  Future<List<QrScanRecordEntity>> fetchEventAttendanceHistory({
    required int eventId,
  }) async {
    try {
      final response = await _client
          .from(_attendanceTable)
          .select('student_id, scanned_time_in, scanned_time_out')
          .eq('event_id', eventId);

      final attendanceRows = List<Map<String, dynamic>>.from(response);

      final uniqueStudentIds = attendanceRows
          .map((row) => row['student_id']?.toString().trim() ?? '')
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();

      final studentsById = <String, Map<String, dynamic>>{};
      if (uniqueStudentIds.isNotEmpty) {
        final studentsResponse = await _client
            .from(_studentsTable)
            .select('student_id, full_name, program')
            .inFilter('student_id', uniqueStudentIds);

        final studentsRows = List<Map<String, dynamic>>.from(studentsResponse);
        for (final row in studentsRows) {
          final studentId = row['student_id']?.toString().trim() ?? '';
          if (studentId.isNotEmpty) {
            studentsById[studentId] = row;
          }
        }
      }

      final timeline = <_ScanTimelineRecord>[];

      for (final row in attendanceRows) {
        final studentId = row['student_id']?.toString().trim() ?? '';
        if (studentId.isEmpty) {
          continue;
        }

        final student = studentsById[studentId];
        final fullName = student?['full_name']?.toString().trim() ?? studentId;
        final program = student?['program']?.toString().trim() ?? 'N/A';

        final timeIn = _parseDateTime(row['scanned_time_in']);
        final timeOut = _parseDateTime(row['scanned_time_out']);

        if (timeIn != null) {
          timeline.add(
            _ScanTimelineRecord(
              studentId: studentId,
              fullName: fullName,
              program: program,
              scannedAt: timeIn,
              type: 'Time In',
            ),
          );
        }

        if (timeOut != null) {
          timeline.add(
            _ScanTimelineRecord(
              studentId: studentId,
              fullName: fullName,
              program: program,
              scannedAt: timeOut,
              type: 'Time Out',
            ),
          );
        }
      }

      timeline.sort((a, b) => b.scannedAt.compareTo(a.scannedAt));

      final history = timeline
          .map(
            (record) => QrScanRecordEntity(
              name: record.fullName,
              studentId: record.studentId,
              program: record.program,
              time: _formatDisplayTime(record.scannedAt.toLocal()),
              status: 'success',
              type: record.type,
            ),
          )
          .toList();

      await _cacheEventHistory(eventId, history);
      return history;
    } catch (_) {
      return _loadCachedEventHistory(eventId);
    }
  }

  Future<void> _appendScanToLocalCache({
    required int eventId,
    required String studentId,
    required AttendanceScanMode mode,
    required DateTime scannedAt,
    String? studentName,
    String? studentProgram,
  }) async {
    final history = await _loadCachedEventHistory(eventId);
    final name = (studentName?.trim().isNotEmpty ?? false)
        ? studentName!.trim()
        : studentId;
    final program = (studentProgram?.trim().isNotEmpty ?? false)
        ? studentProgram!.trim()
        : 'N/A';

    history.insert(
      0,
      QrScanRecordEntity(
        name: name,
        studentId: studentId,
        program: program,
        time: _formatDisplayTime(scannedAt.toLocal()),
        status: 'success',
        type: mode == AttendanceScanMode.timeIn ? 'Time In' : 'Time Out',
      ),
    );

    await _cacheEventHistory(eventId, history);

    final summary = await _loadCachedEventSummary(eventId);
    if (summary != null) {
      final nextRecent = <QrScanRecordEntity>[history.first, ...summary.recentScans]
          .take(12)
          .toList();
      await _cacheEventSummary(
        eventId,
        EventAttendanceSummary(
          totalScans: summary.totalScans + 1,
          recentScans: nextRecent,
        ),
      );
    }
  }

  String _historyKey(int eventId) => '$_historyCachePrefix$eventId';
  String _summaryKey(int eventId) => '$_summaryCachePrefix$eventId';

  Future<void> _cacheEventHistory(
    int eventId,
    List<QrScanRecordEntity> history,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final rows = history
        .map(
          (scan) => {
            'name': scan.name,
            'studentId': scan.studentId,
            'program': scan.program,
            'time': scan.time,
            'status': scan.status,
            'type': scan.type,
          },
        )
        .toList();
    await prefs.setString(_historyKey(eventId), jsonEncode(rows));
  }

  Future<List<QrScanRecordEntity>> _loadCachedEventHistory(int eventId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyKey(eventId));
    if (raw == null || raw.trim().isEmpty) {
      return <QrScanRecordEntity>[];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return <QrScanRecordEntity>[];
      }

      return decoded
          .whereType<Map>()
          .map((entry) => Map<String, dynamic>.from(entry))
          .map(
            (row) => QrScanRecordEntity(
              name: row['name']?.toString().trim() ?? '-',
              studentId: row['studentId']?.toString().trim() ?? '-',
              program: row['program']?.toString().trim() ?? 'N/A',
              time: row['time']?.toString().trim() ?? '-',
              status: row['status']?.toString().trim() ?? 'success',
              type: row['type']?.toString().trim() ?? 'Time In',
            ),
          )
          .toList();
    } catch (_) {
      return <QrScanRecordEntity>[];
    }
  }

  Future<void> _cacheEventSummary(
    int eventId,
    EventAttendanceSummary summary,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = {
      'totalScans': summary.totalScans,
      'recentScans': summary.recentScans
          .map(
            (scan) => {
              'name': scan.name,
              'studentId': scan.studentId,
              'program': scan.program,
              'time': scan.time,
              'status': scan.status,
              'type': scan.type,
            },
          )
          .toList(),
    };
    await prefs.setString(_summaryKey(eventId), jsonEncode(payload));
  }

  Future<EventAttendanceSummary?> _loadCachedEventSummary(int eventId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_summaryKey(eventId));
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return null;
      }

      final map = Map<String, dynamic>.from(decoded);
      final totalScans = int.tryParse(map['totalScans']?.toString() ?? '') ?? 0;
      final recentRaw = map['recentScans'];
      final recentScans = recentRaw is List
          ? recentRaw
                .whereType<Map>()
                .map((entry) => Map<String, dynamic>.from(entry))
                .map(
                  (row) => QrScanRecordEntity(
                    name: row['name']?.toString().trim() ?? '-',
                    studentId: row['studentId']?.toString().trim() ?? '-',
                    program: row['program']?.toString().trim() ?? 'N/A',
                    time: row['time']?.toString().trim() ?? '-',
                    status: row['status']?.toString().trim() ?? 'success',
                    type: row['type']?.toString().trim() ?? 'Time In',
                  ),
                )
                .toList()
          : <QrScanRecordEntity>[];

      return EventAttendanceSummary(
        totalScans: totalScans,
        recentScans: recentScans,
      );
    } catch (_) {
      return null;
    }
  }

  String _serializeMode(AttendanceScanMode mode) {
    return mode == AttendanceScanMode.timeIn ? 'timeIn' : 'timeOut';
  }

  AttendanceScanMode? _deserializeMode(String value) {
    if (value == 'timeIn' || value == _scanModeTimeIn) {
      return AttendanceScanMode.timeIn;
    }

    if (value == 'timeOut' || value == _scanModeTimeOut) {
      return AttendanceScanMode.timeOut;
    }

    return null;
  }

  bool _isConnectivityError(Object error) {
    if (error is SocketException || error is TimeoutException) {
      return true;
    }

    if (error is PostgrestException) {
      final payload =
          '${error.message} ${error.details ?? ''} ${error.hint ?? ''}'.toLowerCase();
      return payload.contains('socket') ||
          payload.contains('failed host lookup') ||
          payload.contains('timed out') ||
          payload.contains('network');
    }

    final text = error.toString().toLowerCase();
    return text.contains('socketexception') ||
        text.contains('failed host lookup') ||
        text.contains('connection closed') ||
        text.contains('network') ||
        text.contains('timeout');
  }

  DateTime? _parseDateTime(dynamic value) {
    final raw = value?.toString().trim() ?? '';
    if (raw.isEmpty) {
      return null;
    }

    return DateTime.tryParse(raw);
  }

  String _formatDisplayTime(DateTime dateTime) {
    final hour24 = dateTime.hour;
    final minuteText = dateTime.minute.toString().padLeft(2, '0');
    final period = hour24 >= 12 ? 'PM' : 'AM';
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;

    return '$hour12:$minuteText $period';
  }
}

class _ScanTimelineRecord {
  const _ScanTimelineRecord({
    required this.studentId,
    required this.fullName,
    required this.program,
    required this.scannedAt,
    required this.type,
  });

  final String studentId;
  final String fullName;
  final String program;
  final DateTime scannedAt;
  final String type;
}
