import 'package:intl/intl.dart';

class TimeFormatter {
  TimeFormatter._();

  /// Converts a database time string (HH:mm:ss) to a 12-hour format (h:mm a)
  static String formatDbTimeTo12Hour(String? dbTime) {
    if (dbTime == null || dbTime.isEmpty) return '-';
    
    try {
      // Handle potential formats (HH:mm:ss or HH:mm)
      final format = dbTime.split(':').length == 3 ? 'HH:mm:ss' : 'HH:mm';
      final dateTime = DateFormat(format).parse(dbTime);
      return DateFormat('h:mm a').format(dateTime);
    } catch (e) {
      return dbTime; // Fallback to original if parsing fails
    }
  }

  /// Formats a time range (start to end) in 12-hour format
  static String formatTimeRange(String? start, String? end) {
    final startTime = formatDbTimeTo12Hour(start);
    final endTime = formatDbTimeTo12Hour(end);
    
    if (startTime == '-' && endTime == '-') return '-';
    return '$startTime - $endTime';
  }
}
