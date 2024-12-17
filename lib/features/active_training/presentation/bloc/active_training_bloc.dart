import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pausable_timer/pausable_timer.dart';
import 'package:uuid/uuid.dart';

part 'active_training_event.dart';
part 'active_training_state.dart';

const uuid = Uuid();

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
    on<LoadDefaultActiveTraining>((event, emit) async {
      emit(const ActiveTrainingLoaded(timersStateList: []));
    });

    on<CreateTimer>((event, emit) async {
      if (state is ActiveTrainingLoaded) {
        final currentState = state as ActiveTrainingLoaded;

        final List<TimerState> currentTimersList =
            List.from(currentState.timersStateList);

        final timerId = event.timerState.timerId;

        for (var timer in currentTimersList) {
          if (timer.timerId == timerId) {
            return;
          }
        }

        currentTimersList.add(event.timerState);

        emit(ActiveTrainingLoaded(timersStateList: currentTimersList));
      }
    });

    on<StartTimer>((event, emit) async {
      final timerId = event.timerId;
      _timers[timerId]?.cancel();
      final currentState = state as ActiveTrainingLoaded;
      final timerState = currentState.timersStateList
          .firstWhere((el) => el.timerId == timerId);

      if (timerState.isRunTimer) {
        _runTracker.stopTracking();
        _runTracker.startTracking();
        _distance = 0;
        _nextKmMarker = 1;
        _paceMinutes = 0;
        _paceSeconds = 0;
        _pace = 0;
      }

      final targetPace = timerState.targetPace;
      final targetPaceMinutes = targetPace.floor();
      final targetPaceSeconds = ((targetPace - targetPaceMinutes) * 60).round();

      int timerValue = timerState.isCountDown
          ? timerState.countDownValue
          : (currentState.timersStateList
                  .firstWhereOrNull((e) => e.timerId == timerId)
                  ?.timerValue ??
              0);

      final currentTimerIndex = currentState.timersStateList
          .indexWhere((el) => el.timerId == timerId);
      String? nextTimerId;
      if (currentTimerIndex + 1 < currentState.timersStateList.length) {
        nextTimerId =
            currentState.timersStateList[currentTimerIndex + 1].timerId;
      }

      final timer = PausableTimer.periodic(
        const Duration(seconds: 1),
        () {
          if (timerState.isCountDown) {
            if (timerValue > 0) {
              timerValue--;
              if (timerValue == 2) {
                playCountdown();
              }
              if (timerState.isRunTimer) {
                _distance = _runTracker.totalDistance;
                add(TickTimer(
                    timerId: timerId, isCountDown: true, isRunTimer: true));
              } else {
                add(TickTimer(timerId: timerId, isCountDown: true));
              }
            } else {
              _timers[timerId]?.cancel();
              if (timerState.isRunTimer) {
                _runTracker.stopTracking();
              }
              event.completer?.complete('Countdown ended.');
              // Start next timer if autostart
              if (nextTimerId != null) {
                final autostart = currentState
                    .timersStateList[currentTimerIndex + 1].isAutostart;
                if (autostart) {
                  add(StartTimer(timerId: nextTimerId));
                }
              }
            }
          } else {
            if (_distance > 0) {
              _pace = timerValue / 60 / (_distance / 1000);
              _paceMinutes = _pace.floor();
              _paceSeconds = ((_pace - _paceMinutes) * 60).round();
            }

            // Check pace every 30 seconds if pace is tracked
            if (timerState.pace > 0 && timerValue % 30 == 0) {
              // Check if 5% slower
              if (_pace < timerState.pace - (timerState.pace * 0.05)) {
                _speak(
                    'Rythme actuel $_paceMinutes $_paceSeconds. Rythme cible $targetPaceMinutes $targetPaceSeconds. Accélérez.');
              }
              if (_pace > timerState.pace + (timerState.pace * 0.05)) {
                _speak(
                    'Rythme actuel $_paceMinutes $_paceSeconds. Rythme cible $targetPaceMinutes $targetPaceSeconds. Ralentissez.');
              }
            }

            if (_distance > 0 && _distance / 1000 >= _nextKmMarker) {
              _speak(
                  '$_nextKmMarker kilomètre. Rythme $_paceMinutes $_paceSeconds par kilomètre.');
              _nextKmMarker++;
            }
            if (timerState.distance > 0) {
              // Check if the current distance equals the objective distance
              if (_distance >= timerState.distance) {
                _timers[timerId]?.cancel();
                if (timerState.isRunTimer) {
                  _runTracker.stopTracking();
                  _distance = 0.0;
                }
                event.completer?.complete('Distance reached.');
                // Start next timer if autostart
                if (nextTimerId != null) {
                  final autostart = currentState
                      .timersStateList[currentTimerIndex + 1].isAutostart;

                  if (autostart) {
                    add(StartTimer(timerId: nextTimerId));
                  }
                }
              } else {
                timerValue++;
                if (timerState.isRunTimer) {
                  _distance = _runTracker.totalDistance;
                  add(TickTimer(timerId: timerId, isRunTimer: true));
                } else {
                  add(TickTimer(timerId: timerId));
                }
              }
            } else {
              // Check if the current duration equals the objective duration
              if (timerState.targetDuration > 0 &&
                  timerValue >= timerState.targetDuration) {
                _timers[timerId]?.cancel();
                if (timerState.isRunTimer) {
                  _runTracker.stopTracking();
                  _distance = 0.0;
                }
                event.completer?.complete('Duration ended.');
                // Start next timer if autostart
                if (nextTimerId != null) {
                  final autostart = currentState
                      .timersStateList[currentTimerIndex + 1].isAutostart;
                  if (autostart) {
                    add(StartTimer(timerId: nextTimerId));
                  }
                }
              } else {
                timerValue++;
                if (timerState.isRunTimer) {
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

      final currentTimersStateList =
          List<TimerState>.from(currentState.timersStateList);

      final updatedTimersStateList =
          List<TimerState>.from(currentState.timersStateList);

      // Mettre en pause tous les autres timers sauf primary
      for (var i = 0; i < currentTimersStateList.length; i++) {
        if (currentTimersStateList[i].isActive == true &&
            currentTimersStateList[i].timerId != 'primaryTimer') {
          updatedTimersStateList[i] =
              currentTimersStateList[i].copyWith(isActive: false);
        }
      }
      final startingValue =
          timerState.isCountDown ? timerState.countDownValue : 0;
      // Mettre à jour la liste avec le timer qui est démarré
      if (updatedTimersStateList.any((e) => e.timerId == timerId)) {
        final currentTimerState =
            updatedTimersStateList.firstWhere((e) => e.timerId == timerId);

        final updatedTimerState = currentTimerState.copyWith(
          isActive: true,
          isStarted: true,
          timerValue: startingValue,
        );
        updatedTimersStateList[updatedTimersStateList.indexOf(
            updatedTimersStateList
                .firstWhere((e) => e.timerId == timerId))] = updatedTimerState;
      }
      emit(currentState.copyWith(
        activeRunTimer: timerId,
        isPaused: false,
        timersStateList: updatedTimersStateList,
      ));
    });

    on<TickTimer>((event, emit) {
      if (state is ActiveTrainingLoaded) {
        final currentState = state as ActiveTrainingLoaded;
        final timerId = event.timerId;

        final currentTimersStateList =
            List<TimerState>.from(currentState.timersStateList);

        final currentTimerState = currentTimersStateList
            .firstWhere((e) => e.timerId == event.timerId);

        final newTimerValue = event.isCountDown
            ? currentTimerState.timerValue - 1
            : currentTimerState.timerValue + 1;

        final double newDistance = _runTracker.totalDistance;

        final double newPace =
            newDistance > 0 ? newDistance / 60 / (newDistance / 1000) : 0;

        // Calculer la distance, le temps écoulé, le pace
        if (timerId != 'primaryTimer') {
          print(
              'Timer: $timerId, time: $newTimerValue, distance: $newDistance, pace: $newPace');
        }

        final updatedTimerState = currentTimerState.copyWith(
          timerValue: newTimerValue,
          distance: newDistance,
          pace: newPace,
        );
        currentTimersStateList[currentTimersStateList.indexOf(
            currentTimersStateList.firstWhere(
                (e) => e.timerId == event.timerId))] = updatedTimerState;
        emit(
          currentState.copyWith(
            distance: event.isRunTimer ? _distance : null,
            timersStateList: currentTimersStateList,
          ),
        );
      }
    });

    on<PauseTimer>((event, emit) {
      final currentState = state as ActiveTrainingLoaded;
      final activeTimer = currentState.activeRunTimer;

      if (currentState.isPaused) {
        _timers['primaryTimer']?.start();
        _timers[activeTimer]?.start();
        emit(currentState.copyWith(isPaused: false));
      } else {
        for (var timer in _timers.entries) {
          timer.value.pause();
        }
        emit(currentState.copyWith(isPaused: true));
      }
    });

    on<ResetTimer>((event, emit) {
      if (state is ActiveTrainingLoaded) {
        final currentState = state as ActiveTrainingLoaded;

        _timers['secondaryTimer']?.cancel();
        _distance = 0;

        final currentTimersStateList =
            List<TimerState>.from(currentState.timersStateList);

        final currentTimerState = currentTimersStateList
            .firstWhere((e) => e.timerId == event.timerId);

        final updatedTimerState = currentTimerState.copyWith(
          timerValue: 0,
        );
        currentTimersStateList[currentTimersStateList.indexOf(
            currentTimersStateList.firstWhere(
                (e) => e.timerId == event.timerId))] = updatedTimerState;

        emit(currentState.copyWith(
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
