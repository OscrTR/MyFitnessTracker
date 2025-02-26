import 'package:fl_location/fl_location.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:my_fitness_tracker/app_colors.dart';

import '../../core/messages/bloc/message_bloc.dart';
import '../../injection_container.dart';
import 'bloc/active_training_bloc.dart';
import 'foreground_task_handler.dart';

typedef LocationChanged = void Function(Location location);

class ForegroundService {
  bool isInitialized = false;
  Future<bool> get isRunningService => FlutterForegroundTask.isRunningService;
  static const MethodChannel _methodChannel = MethodChannel('location_service');

  Future<void> requestService() async {
    try {
      await _methodChannel.invokeMethod('requestService');
    } on PlatformException catch (e) {
      print('Erreur lors de la demande de service: ${e.message}');
    }
  }

  Future<void> initService() async {
    if (!isInitialized) {
      FlutterForegroundTask.addTaskDataCallback(onReceiveTaskData);
      FlutterForegroundTask.init(
        androidNotificationOptions: AndroidNotificationOptions(
          channelId: 'foreground_service',
          channelName: 'Foreground Service Notification',
          channelDescription:
              'This notification appears when the foreground service is running.',
          onlyAlertOnce: true,
        ),
        iosNotificationOptions: const IOSNotificationOptions(
          showNotification: false,
          playSound: false,
        ),
        foregroundTaskOptions: ForegroundTaskOptions(
          eventAction: ForegroundTaskEventAction.repeat(1000),
          autoRunOnBoot: false,
          autoRunOnMyPackageReplaced: false,
          allowWakeLock: true,
          allowWifiLock: false,
        ),
      );
      isInitialized = true;
      await startService();
    }
  }

  Future<ServiceRequestResult> stopService() {
    FlutterForegroundTask.sendDataToTask(
        {'command': MyTaskHandler.clearTimersCommand});
    FlutterForegroundTask.removeTaskDataCallback(onReceiveTaskData);
    isInitialized = false;
    return FlutterForegroundTask.stopService();
  }

  Future<ServiceRequestResult> startService() async {
    if (await FlutterForegroundTask.isRunningService) {
      return FlutterForegroundTask.restartService();
    } else {
      return FlutterForegroundTask.startService(
        serviceId: 256,
        notificationTitle: 'Timer update',
        notificationText: 'Tap to return to the app',
        notificationIcon: NotificationIcon(
            metaDataName: 'dev.oscarthiebaut.my_fitness_tracker.NOTIF_ICON',
            backgroundColor: AppColors.folly),
        notificationInitialRoute: '/active_training',
        callback: startCallback,
      );
    }
  }

  Future<ServiceRequestResult> updateNotificationText(String newText) async {
    if (await FlutterForegroundTask.isRunningService) {
      return FlutterForegroundTask.updateService(
        notificationText: newText,
      );
    } else {
      return ServiceRequestFailure(error: 'Service is not running');
    }
  }

  void startTimer(String timerId, bool isRunTimer) {
    FlutterForegroundTask.sendDataToTask({
      'command': MyTaskHandler.startTimerCommand,
      'timerId': timerId,
      'isRunTimer': isRunTimer,
    });
  }

  void pauseTimer() {
    FlutterForegroundTask.sendDataToTask(
        {'command': MyTaskHandler.pauseTimerCommand});
  }

  void unpauseTimer(String timerId) {
    FlutterForegroundTask.sendDataToTask({
      'command': MyTaskHandler.unpauseTimerCommand,
      'timerId': timerId,
    });
  }

  void cancelTimer(String timerId) {
    FlutterForegroundTask.sendDataToTask({
      'command': MyTaskHandler.cancelTimerCommand,
      'timerId': timerId,
    });
  }

  void onReceiveTaskData(Object data) {
    try {
      if (data is Map<String, dynamic>) {
        final locationData = data['locationData'];

        Location? locationInfo;
        if (locationData != null && locationData['locationData'] != null) {
          locationInfo = Location.fromJson(locationData['locationData']);
        }

        sl<ActiveTrainingBloc>().add(
          UpdateDataFromForeground(
            timerId: data['timerId'],
            locationData: locationInfo,
            totalDistance: data['totalDistance'],
          ),
        );
      }
    } catch (e) {
      sl<MessageBloc>().add(AddMessageEvent(message: '$e', isError: true));
    }
  }
}
