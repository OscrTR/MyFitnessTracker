import 'dart:async';
import 'dart:math';

import 'package:fl_location/fl_location.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:pausable_timer/pausable_timer.dart';

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

class MyTaskHandler extends TaskHandler {
  static const String startTimerCommand = 'startTimer';
  static const String pauseTimerCommand = 'pauseTimer';
  static const String unpauseTimerCommand = 'unpauseTimer';
  static const String clearTimersCommand = 'clearTimers';
  static const String cancelTimerCommand = 'cancelTimer';

  final Map<String, PausableTimer> timers = {};
  String? secondaryTimerId;
  bool isLocationInitialized = false;
  StreamSubscription<Location>? _locationSubscription;
  Location? lastLocation;
  double totalDistance = 0.0;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {}

  @override
  void onRepeatEvent(DateTime timestamp) {}

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    _stopLocationTracking();
  }

  @override
  Future<void> onReceiveData(Object data) async {
    if (data is Map<String, dynamic>) {
      final String command = data['command'];
      final String timerId = data['timerId'] ?? '';
      final bool isRunTimer = data['isRunTimer'] ?? false;

      switch (command) {
        case startTimerCommand:
          _stopLocationTracking();
          _startTimer(timerId);
          if (isRunTimer) {
            _startLocationTracking();
          }
          break;
        case clearTimersCommand:
          _clearTimers();
          break;
        case pauseTimerCommand:
          _pauseTimers();
          break;
        case unpauseTimerCommand:
          _unpauseTimers(timerId);
          break;
        case cancelTimerCommand:
          _cancelTimer(timerId);
          _stopLocationTracking();
          break;
      }
    }
  }

  void _startLocationTracking() {
    _locationSubscription = FlLocation.getLocationStream().listen(
      (location) {
        _updateLocationAndDistance(location);
      },
      onError: (error) {
        _stopLocationTracking();
      },
    );
  }

  void _stopLocationTracking() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
    lastLocation = null;
    totalDistance = 0.0;
  }

  void _updateLocationAndDistance(Location currentLocation) {
    // Vérifier si la position est différente avant de l'envoyer
    if (lastLocation == null ||
        lastLocation!.latitude != currentLocation.latitude ||
        lastLocation!.longitude != currentLocation.longitude) {
      if (lastLocation != null) {
        final double distanceInMeters = _calculateDistance(
          lastLocation!.latitude,
          lastLocation!.longitude,
          currentLocation.latitude,
          currentLocation.longitude,
        );
        totalDistance += distanceInMeters;
      }

      lastLocation = currentLocation;

      // Envoyer les données uniquement si la position a changé
      FlutterForegroundTask.sendDataToMain({
        'timerId': secondaryTimerId,
        'locationData': {'locationData': currentLocation.toJson()},
      });
    }
  }

  double _calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    var earthRadius = 6378137.0;
    var dLat = _toRadians(endLatitude - startLatitude);
    var dLon = _toRadians(endLongitude - startLongitude);
    var a = pow(sin(dLat / 2), 2) +
        pow(sin(dLon / 2), 2) *
            cos(_toRadians(startLatitude)) *
            cos(_toRadians(endLatitude));
    var c = 2 * asin(sqrt(a));
    return earthRadius * c;
  }

  double _toRadians(double degree) {
    return degree * pi / 180;
  }

  void _clearTimers() {
    for (var timer in timers.values) {
      timer.cancel();
    }
    timers.clear();
    isLocationInitialized = false;
  }

  void _pauseTimers() {
    for (var timer in timers.values) {
      timer.pause();
    }
  }

  void _unpauseTimers(String timerId) {
    timers['primaryTimer']?.start();
    timers[timerId]?.start();
  }

  void _cancelTimer(String timerId) {
    if (timers.containsKey(timerId)) {
      timers[timerId]?.cancel();
      timers.remove(timerId);
    }
  }

  void _startTimer(String timerId) {
    if (timers.containsKey(timerId)) {
      _cancelTimer(timerId);
    }

    timers[timerId] = PausableTimer.periodic(const Duration(seconds: 1), () {
      // Envoie les données à chaque tick du timer
      FlutterForegroundTask.sendDataToMain({
        'timerId': timerId,
        'totalDistance': totalDistance,
      });
    });

    if (timerId != 'primaryTimer') {
      secondaryTimerId = timerId;
    }

    _pauseTimers();

    timers[timerId]?.start();
    timers['primaryTimer']!.start();
  }
}
