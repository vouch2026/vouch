import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    try {
      final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));
    } catch (e) {
      debugPrint('Error initializing local timezone: $e');
    }

    try {
      await Permission.notification.request();
      if (await Permission.scheduleExactAlarm.isDenied) {
        await Permission.scheduleExactAlarm.request();
      }
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('logo_notif');

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(settings: initSettings);

    // Explicitly create notification channel for Android
    try {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        const AndroidNotificationChannel channel = AndroidNotificationChannel(
          'schedule_channel',
          'Schedule Reminders',
          description: 'Reminders for school schedules and classes',
          importance: Importance.max,
        );
        await androidImplementation.createNotificationChannel(channel);
      }
    } catch (e) {
      debugPrint('Error creating Android notification channel: $e');
    }
  }



  static Future<void> scheduleWeeklyNotification({
    required int id,
    required String title,
    required String body,
    required String dayOfWeek,
    required String timeStr,
    required int offsetMinutes,
  }) async {
    if (offsetMinutes <= 0) return; // No reminder needed
    
    final parsedTime = _parseTime(timeStr);
    if (parsedTime == null) return;

    final targetWeekday = _getDayOfWeekIndex(dayOfWeek);
    
    // Calculate final time with offset (e.g. 15 or 30 minutes before)
    DateTime tempDate = DateTime(2020, 1, 1, parsedTime.hour, parsedTime.minute);
    tempDate = tempDate.subtract(Duration(minutes: offsetMinutes));
    
    final scheduledHour = tempDate.hour;
    final scheduledMinute = tempDate.minute;

    final tz.TZDateTime scheduledTZDate =
        _nextInstanceOfDayOfWeekAndTime(targetWeekday, scheduledHour, scheduledMinute);

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'schedule_channel',
      'Schedule Reminders',
      channelDescription: 'Reminders for school schedules and classes',
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledTZDate,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    } catch (e) {
      debugPrint('Exact alarm scheduling failed, falling back to inexact alarm: $e');
      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledTZDate,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id: id);
  }

  static Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  static int _getDayOfWeekIndex(String day) {
    switch (day.toLowerCase()) {
      case 'monday':
        return DateTime.monday;
      case 'tuesday':
        return DateTime.tuesday;
      case 'wednesday':
        return DateTime.wednesday;
      case 'thursday':
        return DateTime.thursday;
      case 'friday':
        return DateTime.friday;
      case 'saturday':
        return DateTime.saturday;
      case 'sunday':
        return DateTime.sunday;
      default:
        return DateTime.monday;
    }
  }

  static tz.TZDateTime _nextInstanceOfDayOfWeekAndTime(
      int dayOfWeek, int hour, int minute) {
    tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    while (scheduledDate.weekday != dayOfWeek || scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  static TimeOfDay? _parseTime(String timeStr) {
    try {
      final format = DateFormat.jm(); // e.g. "9:00 AM" or "09:00 AM"
      final dt = format.parse(timeStr);
      return TimeOfDay(hour: dt.hour, minute: dt.minute);
    } catch (_) {
      try {
        final normalized = timeStr.toUpperCase().replaceAll('.', '');
        final isPm = normalized.contains('PM');
        final isAm = normalized.contains('AM');
        
        final cleanTime = normalized.replaceAll(RegExp(r'[^0-9:]'), '').trim();
        final parts = cleanTime.split(':');
        int hour = int.parse(parts[0]);
        final int minute = int.parse(parts[1]);

        if (isPm && hour < 12) {
          hour += 12;
        } else if (isAm && hour == 12) {
          hour = 0;
        }
        return TimeOfDay(hour: hour, minute: minute);
      } catch (_) {
        return null;
      }
    }
  }
}
