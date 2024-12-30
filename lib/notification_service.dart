import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:my_fitness_tracker/injection_container.dart';

final StreamController<int> timerStreamController = StreamController<int>();

const String navigationActionId = 'id_1';

class NotificationService {
  static Future<void> initializeNotifications() async {
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
}
