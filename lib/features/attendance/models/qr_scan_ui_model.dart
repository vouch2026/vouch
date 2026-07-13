class QrScanUIModel {
  final String name;
  final String studentId;
  final String program;
  final String time;
  final String status; // 'success' | 'pending' | 'error'
  final String type; // 'Time In' | 'Time Out'
  final String? studentUuid;
  final String? scannedByUserId;

  QrScanUIModel({
    required this.name,
    required this.studentId,
    required this.program,
    required this.time,
    required this.status,
    required this.type,
    this.studentUuid,
    this.scannedByUserId,
  });

  bool get isError => status == 'error';
  bool get isPending => status == 'pending';
  
  String get badgeLabel {
    if (status == 'success') return type.toUpperCase();
    if (status == 'pending') return 'PENDING';
    return 'FAILED';
  }

  QrScanUIModel copyWith({
    String? name,
    String? studentId,
    String? program,
    String? time,
    String? status,
    String? type,
    String? studentUuid,
    String? scannedByUserId,
  }) {
    return QrScanUIModel(
      name: name ?? this.name,
      studentId: studentId ?? this.studentId,
      program: program ?? this.program,
      time: time ?? this.time,
      status: status ?? this.status,
      type: type ?? this.type,
      studentUuid: studentUuid ?? this.studentUuid,
      scannedByUserId: scannedByUserId ?? this.scannedByUserId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'studentId': studentId,
      'program': program,
      'time': time,
      'status': status,
      'type': type,
      'studentUuid': studentUuid,
      'scannedByUserId': scannedByUserId,
    };
  }

  factory QrScanUIModel.fromJson(Map<String, dynamic> json) {
    return QrScanUIModel(
      name: json['name'] as String,
      studentId: json['studentId'] as String,
      program: json['program'] as String,
      time: json['time'] as String,
      status: json['status'] as String,
      type: json['type'] as String,
      studentUuid: json['studentUuid'] as String?,
      scannedByUserId: json['scannedByUserId'] as String?,
    );
  }
}
