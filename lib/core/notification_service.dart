// ignore_for_file: depend_on_referenced_packages

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:my_fitness_tracker/app_colors.dart';
import 'package:my_fitness_tracker/core/database/database_service.dart';
import 'package:my_fitness_tracker/core/enums/enums.dart';
import 'package:my_fitness_tracker/features/training_management/models/reminder.dart';
import 'package:my_fitness_tracker/injection_container.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static Future<void> initializeNotifications() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const initializationSettingsAndroid =
        AndroidInitializationSettings('ic_stat_notif');

    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await sl<FlutterLocalNotificationsPlugin>()
        .initialize(initializationSettings);

    askNotificationPermission();
  }

  static Future<bool> areNotificationsEnabled() async {
    return await sl<FlutterLocalNotificationsPlugin>()
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.areNotificationsEnabled() ??
        false;
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

  static Future<void> notify() async {
    const androidNotificationDetails = AndroidNotificationDetails(
        'your channel id', 'your channel name',
        channelDescription: 'your channel description',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker');
    const notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await sl<FlutterLocalNotificationsPlugin>().show(
        0, 'plain title', 'plain body', notificationDetails,
        payload: 'item x');
  }

  static Future<void> scheduleWeeklyNotification(
      {required TrainingDay day}) async {
    tz.TZDateTime nextInstanceOfWeekday(TrainingDay day) {
      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
      final currentDay = now.weekday;

      final int targetDay = (day.index + 1);

      int daysUntilTarget = (targetDay - currentDay + 7) % 7;

      if (daysUntilTarget == 0) {
        daysUntilTarget = 7;
      }

      final nextDay = now.add(Duration(days: daysUntilTarget));

      final scheduledDate = tz.TZDateTime(
          tz.local, nextDay.year, nextDay.month, nextDay.day, 8, 0, 0);
      return scheduledDate;
    }

    print(
        'notif planned ${nextInstanceOfWeekday(day)} while now is ${tz.TZDateTime.now(tz.local)}');

    final notificationId =
        DateTime.now().millisecondsSinceEpoch.remainder(100000);

    await sl<FlutterLocalNotificationsPlugin>().zonedSchedule(
      notificationId,
      'Training planned today!',
      "Don't forget to train.",
      nextInstanceOfWeekday(day),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'weekly notification channel id',
          'weekly notification channel name',
          channelDescription: 'weekly notificationdescription',
          color: AppColors.folly,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );

    final reminder = Reminder(notificationId: notificationId, day: day);
    await sl<DatabaseService>().createReminder(reminder);
  }
}
