import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationsService {
  NotificationsService._internal();
  static final NotificationsService instance = NotificationsService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosInit = DarwinInitializationSettings();
    const InitializationSettings initSettings = InitializationSettings(android: androidInit, iOS: iosInit);

    await _plugin.initialize(initSettings);

    if (Platform.isAndroid) {
      await Permission.notification.request();
    }

    _initialized = true;
  }

  Future<void> scheduleDailyReminder({
    required int id,
    required TimeOfDay time,
    required String title,
    required String body,
  }) async {
    if (!_initialized) await init();

    final androidDetails = const AndroidNotificationDetails(
      'daily_reminders',
      'Daily Reminders',
      channelDescription: 'Daily health & fitness reminders',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const iosDetails = DarwinNotificationDetails();
    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(time),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleWeeklyReminder({
    required int id,
    required Day day,
    required TimeOfDay time,
    required String title,
    required String body,
  }) async {
    if (!_initialized) await init();

    final androidDetails = const AndroidNotificationDetails(
      'weekly_reminders',
      'Weekly Reminders',
      channelDescription: 'Weekly goals & planning reminders',
    );
    const iosDetails = DarwinNotificationDetails();
    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfWeekday(day, time),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  Future<void> showCelebration(String title, String body) async {
    if (!_initialized) await init();

    const androidDetails = AndroidNotificationDetails(
      'celebrations',
      'Celebrations',
      channelDescription: 'Streaks and achievements',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.show(DateTime.now().millisecondsSinceEpoch % 100000, title, body, details);
  }

  Future<void> cancelAll() async {
    if (!_initialized) await init();
    await _plugin.cancelAll();
  }
}

// Helpers
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';

tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
  tz.initializeTimeZones();
  final now = tz.TZDateTime.now(tz.local);
  var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, time.hour, time.minute);
  if (scheduled.isBefore(now)) {
    scheduled = scheduled.add(const Duration(days: 1));
  }
  return scheduled;
}

tz.TZDateTime _nextInstanceOfWeekday(Day day, TimeOfDay time) {
  tz.initializeTimeZones();
  tz.TZDateTime scheduled = _nextInstanceOfTime(time);
  while (scheduled.weekday != _mapDay(day)) {
    scheduled = scheduled.add(const Duration(days: 1));
  }
  return scheduled;
}

int _mapDay(Day day) {
  switch (day) {
    case Day.monday:
      return DateTime.monday;
    case Day.tuesday:
      return DateTime.tuesday;
    case Day.wednesday:
      return DateTime.wednesday;
    case Day.thursday:
      return DateTime.thursday;
    case Day.friday:
      return DateTime.friday;
    case Day.saturday:
      return DateTime.saturday;
    case Day.sunday:
      return DateTime.sunday;
  }
}