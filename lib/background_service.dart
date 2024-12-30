import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pausable_timer/pausable_timer.dart';

final service = FlutterBackgroundService();

Future<void> initializeBackgroundService() async {
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: true,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
    ),
  );

  await service.startService();
}

void onStart(ServiceInstance service) async {
  final AudioPlayer audioPlayer = AudioPlayer();
  final FlutterTts flutterTts = FlutterTts();
  final RunTracker runTracker = RunTracker();

  final Map<String, PausableTimer> timers = {};

  Future<void> playCountdown() async {
    await audioPlayer.play(AssetSource('sounds/countdown.mp3'));
  }

  Future<void> speak(String string) async {
    await flutterTts.speak(string);
  }

  service.on('speak').listen((event) {
    speak(event!['message']);
  });

  service.on('playCountDown').listen((event) {
    playCountdown();
  });

  service.on('startLocationTracking').listen((event) {
    runTracker.startTracking();
  });

  service.on('stopLocationTracking').listen((event) {
    runTracker.stopTracking();
  });

  service.on('cancelTimer').listen((event) {
    timers[event!['timerId']]?.cancel();
  });

  service.on('startTracking').listen((event) {
    final String timerId = event!['timerId'];

    runTracker.stopTracking();
    runTracker.startTracking();

    timers[timerId]?.cancel();

    final timer = PausableTimer.periodic(const Duration(seconds: 1), () async {
      service.invoke('updateTimer', {
        'timerId': timerId,
        'runDistance': runTracker.totalDistance,
      });
    });

    timers[timerId] = timer;
    timer.start();
    if (timers['primaryTimer']!.isPaused) {
      timers['primaryTimer']!.start();
    }
    service.invoke('startTimer', {
      'timerId': timerId,
    });
  });

  service.on('pauseTracking').listen((event) {
    final String timerId = event!['timerId'];

    if (timers['primaryTimer']!.isActive) {
      timers['primaryTimer']!.pause();
    } else if (timers['primaryTimer']!.isPaused) {
      timers['primaryTimer']!.start();
    }

    if (timers[timerId] != null &&
        timerId != 'primaryTimer' &&
        timers[timerId]!.isPaused) {
      timers[timerId]?.start();
    } else if (timers[timerId] != null &&
        timerId != 'primaryTimer' &&
        timers[timerId]!.isActive) {
      for (var timer in timers.values) {
        timer.pause();
      }
    }
    service.invoke('pauseTimer');
  });

  service.on('stopTracking').listen((event) async {
    for (var timer in timers.values) {
      timer.cancel();
    }
    runTracker.stopTracking();
    timers.clear();
  });
}

class RunTracker {
  StreamSubscription<Position>? _positionStreamSubscription;
  Position? _previousPosition;
  double totalDistance = 0.0; // In meters

  void startTracking() async {
    try {
      await Geolocator.getCurrentPosition();
      // Start listening to position updates
      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5, // Notify every 5 meters
        ),
      ).listen((Position position) {
        if (_previousPosition != null) {
          totalDistance += Geolocator.distanceBetween(
            _previousPosition!.latitude,
            _previousPosition!.longitude,
            position.latitude,
            position.longitude,
          );
        }
        _previousPosition = position;
      });
    } catch (e) {
      print('error: $e');
    }
  }

  void stopTracking() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    _previousPosition = null;
    totalDistance = 0.0;
  }
}
