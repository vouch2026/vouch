import 'dart:convert';

class QrPayload {
  final String studentId;
  final String fullName;
  final String program;

  QrPayload({
    required this.studentId,
    required this.fullName,
    required this.program,
  });

  factory QrPayload.fromJson(Map<String, dynamic> json) {
    return QrPayload(
      studentId: (json['studentId'] ?? json['id'] ?? '').toString(),
      fullName: (json['fullName'] ?? json['name'] ?? 'Unknown Student').toString(),
      program: (json['program'] ?? 'N/A').toString(),
    );
  }

  factory QrPayload.fromRawValue(String value) {
    try {
      final data = jsonDecode(value);
      return QrPayload.fromJson(data);
    } catch (_) {
      return QrPayload(
        studentId: value,
        fullName: 'Unknown Student',
        program: 'N/A',
      );
    }
  }
}
