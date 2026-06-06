enum AttendanceMode {
  timeIn,
  timeOut,
  closed,
}

extension AttendanceModeExtension on AttendanceMode {
  String get label {
    switch (this) {
      case AttendanceMode.timeIn:
        return 'Time In';
      case AttendanceMode.timeOut:
        return 'Time Out';
      case AttendanceMode.closed:
        return 'Closed';
    }
  }

  bool get isClosed => this == AttendanceMode.closed;
}
