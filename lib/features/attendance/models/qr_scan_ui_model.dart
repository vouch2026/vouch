class QrScanUIModel {
  final String name;
  final String studentId;
  final String program;
  final String time;
  final String status; // 'success' | 'error'
  final String type; // 'Time In' | 'Time Out'

  QrScanUIModel({
    required this.name,
    required this.studentId,
    required this.program,
    required this.time,
    required this.status,
    required this.type,
  });

  bool get isError => status == 'error';
  
  String get badgeLabel {
    if (status == 'success') return type.toUpperCase();
    return 'FAILED';
  }
}
