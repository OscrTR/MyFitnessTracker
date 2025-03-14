import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import '../app_colors.dart';
import 'database/database_service.dart';
import 'enums/enums.dart';
import '../features/training_management/models/reminder.dart';
import '../injection_container.dart';
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

  static Future<void> scheduleWeeklyNotification(
      {required TrainingDay day, required int notificationId}) async {
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

    await sl<FlutterLocalNotificationsPlugin>().zonedSchedule(
      notificationId,
      tr('notification_title'),
      tr('notification_content'),
      nextInstanceOfWeekday(day),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'weeklyNotificationChannelId',
          'weeklyNotificationChannel',
          channelDescription:
              "Planned notifications to remind of the current day's trainings.",
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
