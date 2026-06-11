import 'dart:convert';

class QrPayload {
  final String? databaseId;
  final String studentId;
  final String fullName;
  final String program;

  QrPayload({
    this.databaseId,
    required this.studentId,
    required this.fullName,
    required this.program,
  });

  factory QrPayload.fromJson(Map<String, dynamic> json) {
    return QrPayload(
      databaseId: json['id']?.toString(),
      studentId: (json['studentId'] ?? '').toString(),
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
