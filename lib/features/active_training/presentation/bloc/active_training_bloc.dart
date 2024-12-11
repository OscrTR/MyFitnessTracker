import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pausable_timer/pausable_timer.dart';

part 'active_training_event.dart';
part 'active_training_state.dart';

class ActiveTrainingBloc
    extends Bloc<ActiveTrainingEvent, ActiveTrainingState> {
  final Map<String, PausableTimer> _timers = {};
  final RunTracker _runTracker = RunTracker();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterTts _flutterTts = FlutterTts();
  double _distance = 0.0;
  int _nextKmMarker = 1;
  int _paceMinutes = 0;
  int _paceSeconds = 0;
  double _pace = 0;

  Future<void> _speak(String number) async {
    await _flutterTts.speak(number); // Speak the number
  }

  Future<void> playCountdown() async {
    await _audioPlayer.play(AssetSource('sounds/countdown.mp3'));
  }

  ActiveTrainingBloc() : super(ActiveTrainingInitial()) {
    on<StartTimer>((event, emit) async {
      final currentTimers = state is ActiveTrainingLoaded
          ? (state as ActiveTrainingLoaded).timers
          : {};

      final timerId = event.timerId;
      _timers[timerId]?.cancel();
      if (event.isRunTimer) {
        _runTracker.stopTracking();
        _runTracker.startTracking();
        _distance = 0;
        _nextKmMarker = 1;
        _paceMinutes = 0;
        _paceSeconds = 0;
        _pace = 0;
      }

      final targetPace = event.pace;
      final targetPaceMinutes = targetPace.floor();
      final targetPaceSeconds = ((targetPace - targetPaceMinutes) * 60).round();

      int timerValue =
          event.isCountDown ? event.duration : (currentTimers[timerId] ?? 0);

      final timer = PausableTimer.periodic(
        const Duration(seconds: 1),
        () {
          if (event.isCountDown) {
            if (timerValue > 0) {
              timerValue--;
              if (timerValue == 2) {
                playCountdown();
              }
              if (event.isRunTimer) {
                _distance = _runTracker.totalDistance;
                add(TickTimer(
                    timerId: timerId, isCountDown: true, isRunTimer: true));
              } else {
                add(TickTimer(timerId: timerId, isCountDown: true));
              }
            } else {
              _timers[timerId]?.cancel();
              if (event.isRunTimer) {
                _runTracker.stopTracking();
              }
              event.completer?.complete('Countdown ended.');
            }
          } else {
            if (_distance > 0) {
              _pace = timerValue / 60 / (_distance / 1000);
              _paceMinutes = _pace.floor();
              _paceSeconds = ((_pace - _paceMinutes) * 60).round();
            }

            // Check pace every 30 seconds if pace is tracked
            if (event.pace > 0 && timerValue % 30 == 0) {
              // Check if 5% slower
              if (_pace < event.pace - (event.pace * 0.05)) {
                _speak(
                    'Rythme actuel $_paceMinutes $_paceSeconds. Rythme cible $targetPaceMinutes $targetPaceSeconds. Accélérez.');
              }
              if (_pace > event.pace + (event.pace * 0.05)) {
                _speak(
                    'Rythme actuel $_paceMinutes $_paceSeconds. Rythme cible $targetPaceMinutes $targetPaceSeconds. Ralentissez.');
              }
            }

            if (_distance > 0 && _distance / 1000 >= _nextKmMarker) {
              _speak(
                  '$_nextKmMarker kilomètre. Rythme $_paceMinutes $_paceSeconds par kilomètre.');
              _nextKmMarker++;
            }
            if (event.distance > 0) {
              // Check if the current distance equals the objective distance
              if (_distance >= event.distance) {
                _timers[timerId]?.cancel();
                if (event.isRunTimer) {
                  _runTracker.stopTracking();
                  _distance = 0.0;
                }
                event.completer?.complete('Distance reached.');
              } else {
                timerValue++;
                if (event.isRunTimer) {
                  _distance = _runTracker.totalDistance;
                  add(TickTimer(timerId: timerId, isRunTimer: true));
                } else {
                  add(TickTimer(timerId: timerId));
                }
              }
            } else {
              // Check if the current duration equals the objective duration
              if (event.duration > 0 && timerValue >= event.duration) {
                _timers[timerId]?.cancel();
                if (event.isRunTimer) {
                  _runTracker.stopTracking();
                  _distance = 0.0;
                }
                event.completer?.complete('Duration ended.');
              } else {
                timerValue++;
                if (event.isRunTimer) {
                  _distance = _runTracker.totalDistance;
                  add(TickTimer(timerId: timerId, isRunTimer: true));
                } else {
                  add(TickTimer(timerId: timerId));
                }
              }
            }
          }
        },
      );

      _timers[timerId] = timer;
      timer.start();
      if (_timers['primaryTimer']!.isPaused) {
        _timers['primaryTimer']?.start();
      }

      if (state is ActiveTrainingLoaded) {
        final currentState = state as ActiveTrainingLoaded;
        if (timerId != 'primaryTimer' && timerId != 'secondaryTimer') {
          emit(currentState.copyWith(
            timers: {
              ...currentTimers,
              timerId: timerValue,
            },
            activeRunTimer: event.activeRunTimer,
            isPaused: false,
          ));
        } else {
          emit(currentState.copyWith(
            timers: {
              ...currentTimers,
              timerId: timerValue,
            },
            activeRunTimer: event.activeRunTimer,
            isPaused: false,
          ));
        }
      } else {
        emit(ActiveTrainingLoaded(
          timers: {
            ...currentTimers,
            timerId: timerValue,
          },
          isPaused: false,
          activeRunTimer: event.activeRunTimer,
        ));
      }
    });

    on<TickTimer>((event, emit) {
      if (state is ActiveTrainingLoaded) {
        final currentState = state as ActiveTrainingLoaded;
        final currentTimers = currentState.timers;
        final timerId = event.timerId;

        if (!currentTimers.containsKey(timerId)) return;
        emit(
          currentState.copyWith(
            timers: {
              ...currentTimers,
              timerId: event.isCountDown
                  ? currentTimers[timerId]! - 1
                  : currentTimers[timerId]! + 1,
            },
            distance: event.isRunTimer ? _distance : null,
          ),
        );
      }
    });

    on<PauseTimer>((event, emit) {
      final currentState = state as ActiveTrainingLoaded;

      if (currentState.isPaused) {
        _timers['primaryTimer']?.start();
        _timers['secondaryTimer']?.start();
        emit(currentState.copyWith(isPaused: false));
      } else {
        _timers['primaryTimer']?.pause();
        _timers['secondaryTimer']?.pause();
        emit(currentState.copyWith(isPaused: true));
      }
    });

    on<ResetSecondaryTimer>((event, emit) {
      if (state is ActiveTrainingLoaded) {
        final currentState = state as ActiveTrainingLoaded;
        final currentTimers = currentState.timers;

        _timers['secondaryTimer']?.cancel();
        _distance = 0;

        final updatedTimers = Map<String, int>.from(currentTimers);
        updatedTimers['secondaryTimer'] = 0;

        emit(currentState.copyWith(
          timers: updatedTimers,
          distance: 0,
        ));
      }
    });
  }
  @override
  Future<void> close() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _audioPlayer.dispose();
    _flutterTts.stop();
    return super.close();
  }
}

class RunTracker {
  StreamSubscription<Position>? _positionStreamSubscription;
  Position? _previousPosition;
  double totalDistance = 0.0; // In meters

  void startTracking() async {
    // Check permission
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // print('Location services are disabled.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        // print('Location permissions are permanently denied.');
        return;
      }
    }

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
      // print('Distance Traveled: $totalDistance meters');
    });
  }

  void stopTracking() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    _previousPosition = null;
    totalDistance = 0.0;
  }
}
