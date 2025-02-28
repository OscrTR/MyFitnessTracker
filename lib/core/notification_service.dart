// ignore_for_file: depend_on_referenced_packages

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:my_fitness_tracker/app_colors.dart';
import 'package:my_fitness_tracker/core/database/database_service.dart';
import 'package:my_fitness_tracker/core/messages/toast.dart';
import 'package:my_fitness_tracker/features/training_management/models/reminder.dart';
import 'package:my_fitness_tracker/injection_container.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static Future<void> initializeNotifications() async {
    tz.initializeTimeZones();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_stat_notif');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await sl<FlutterLocalNotificationsPlugin>()
        .initialize(initializationSettings);
    askNotificationPermission();
  }

  static Future<void> askNotificationPermission() async {
    await sl<FlutterLocalNotificationsPlugin>()
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> deleteNotification(id) async {
    await sl<FlutterLocalNotificationsPlugin>().cancel(id);
  }

  static Future<void> showTZ() async {
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    showToastMessage(message: '${tz.local}');
  }

  static Future<void> notify(id) async {
    await sl<FlutterLocalNotificationsPlugin>().show(
      id,
      'Instant notif',
      'nothing here',
      const NotificationDetails(
        android: AndroidNotificationDetails(
            'weekly_channel_id', 'Weekly Notifications',
            channelDescription: 'This channel is for weekly notifications',
            importance: Importance.max,
            priority: Priority.high,
            color: AppColors.folly),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  static Future<void> notifyIn1Min(id) async {
    await sl<FlutterLocalNotificationsPlugin>().zonedSchedule(
        0,
        'scheduled title',
        'scheduled body',
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
        const NotificationDetails(
            android: AndroidNotificationDetails(
                'your channel id', 'your channel name',
                channelDescription: 'your channel description')),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }

  static Future<void> scheduleWeeklyNotification({required Day day}) async {
    // Obtenir la prochaine instance d'un jour spécifique de la semaine
    tz.TZDateTime nextInstanceOfWeekday(Day day) {
      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
      tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        8,
        0,
      );

      return scheduledDate;
    }

    final notificationId =
        DateTime.now().millisecondsSinceEpoch.remainder(100000);

    await sl<FlutterLocalNotificationsPlugin>().zonedSchedule(
      notificationId,
      'Training planned today!',
      "Don't forget to train.",
      nextInstanceOfWeekday(day),
      const NotificationDetails(
        android: AndroidNotificationDetails(
            'weekly_channel_id', 'Weekly Notifications',
            channelDescription: 'This channel is for weekly notifications',
            importance: Importance.max,
            priority: Priority.high,
            color: AppColors.folly),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
    final reminder = Reminder(notificationId: notificationId, day: day);
    await sl<DatabaseService>().createReminder(reminder);
  }
}
