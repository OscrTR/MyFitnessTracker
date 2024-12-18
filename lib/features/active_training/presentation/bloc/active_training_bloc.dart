import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:bloc/bloc.dart';
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
      final initialState = state as ActiveTrainingLoaded;
      final initialTimerState = initialState.timersStateList
          .firstWhere((el) => el.timerId == timerId);

      if (initialTimerState.isRunTimer) {
        _runTracker.stopTracking();
        _runTracker.startTracking();
        _nextKmMarker = 1;
        _paceMinutes = 0;
        _paceSeconds = 0;
        _pace = 0;
      }

      final targetPace = initialTimerState.targetPace;
      final targetPaceMinutes = targetPace.floor();
      final targetPaceSeconds = ((targetPace - targetPaceMinutes) * 60).round();

      final timer = PausableTimer.periodic(
        const Duration(seconds: 1),
        () async {
          final currentState = state as ActiveTrainingLoaded;
          final currentTimerIndex = currentState.timersStateList
              .indexWhere((el) => el.timerId == timerId);
          String? nextTimerId;
          if (currentTimerIndex + 1 < currentState.timersStateList.length) {
            nextTimerId =
                currentState.timersStateList[currentTimerIndex + 1].timerId;
          }
          final currentTimerState =
              currentState.timersStateList[currentTimerIndex];
          final currentTimerValue = currentTimerState.timerValue;

          if (currentTimerState.isCountDown) {
            if (currentTimerValue > 0) {
              if (currentTimerValue == 2) {
                await playCountdown();
              }
              if (currentTimerState.isRunTimer) {
                add(TickTimer(
                    timerId: timerId, isCountDown: true, isRunTimer: true));
              } else {
                add(TickTimer(timerId: timerId, isCountDown: true));
              }
            } else {
              _timers[timerId]?.cancel();
              if (currentTimerState.isRunTimer) {
                _runTracker.stopTracking();
              }
              print('countdown ended');
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
            final currentDistance = currentTimerState.distance;
            if (currentDistance > 0) {
              _pace = currentTimerValue / 60 / (currentDistance / 1000);
              _paceMinutes = _pace.floor();
              _paceSeconds = ((_pace - _paceMinutes) * 60).round();
            }

            // Check pace every 30 seconds if pace is tracked
            if (currentTimerState.pace > 0 && currentTimerValue % 30 == 0) {
              // Check if 5% slower
              if (_pace <
                  initialTimerState.pace - (initialTimerState.pace * 0.05)) {
                await _speak(
                    'Rythme actuel $_paceMinutes $_paceSeconds. Rythme cible $targetPaceMinutes $targetPaceSeconds. Accélérez.');
              }
              if (_pace >
                  initialTimerState.pace + (initialTimerState.pace * 0.05)) {
                await _speak(
                    'Rythme actuel $_paceMinutes $_paceSeconds. Rythme cible $targetPaceMinutes $targetPaceSeconds. Ralentissez.');
              }
            }

            if (currentDistance > 0 &&
                currentDistance / 1000 >= _nextKmMarker) {
              _speak(
                  '$_nextKmMarker kilomètre. Rythme $_paceMinutes $_paceSeconds par kilomètre.');
              _nextKmMarker++;
            }

            if (currentState.timersStateList[currentTimerIndex].distance > 0) {
              // Check if the current distance equals the objective distance
              if (currentDistance >= currentTimerState.targetDistance) {
                _timers[timerId]?.cancel();

                if (currentTimerState.isRunTimer) {
                  add(UpdateDistance(
                      timerId: timerId, distance: currentDistance));
                  _runTracker.stopTracking();
                }
                event.completer?.complete('Distance reached.');
                // TODO update distance

                print('distance reached, starting timer $nextTimerId');
                // Start next timer if autostart
                if (nextTimerId != null) {
                  final autostart = currentState
                      .timersStateList[currentTimerIndex + 1].isAutostart;

                  if (autostart) {
                    add(StartTimer(timerId: nextTimerId));
                  }
                }
              } else {
                if (currentTimerState.isRunTimer) {
                  add(TickTimer(timerId: timerId, isRunTimer: true));
                } else {
                  add(TickTimer(timerId: timerId));
                }
              }
            } else {
              // Check if the current duration equals the objective duration
              if (currentTimerState.targetDuration > 0 &&
                  currentTimerValue >= currentTimerState.targetDuration) {
                _timers[timerId]?.cancel();
                if (currentTimerState.isRunTimer) {
                  _runTracker.stopTracking();
                }
                print('duration ended');
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
                if (currentTimerState.isRunTimer) {
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
          List<TimerState>.from(initialState.timersStateList);

      final updatedTimersStateList =
          List<TimerState>.from(initialState.timersStateList);

      // Mettre en pause tous les autres timers sauf primary
      for (var i = 0; i < currentTimersStateList.length; i++) {
        if (currentTimersStateList[i].isActive == true &&
            currentTimersStateList[i].timerId != 'primaryTimer') {
          updatedTimersStateList[i] =
              currentTimersStateList[i].copyWith(isActive: false);
        }
      }
      final startingValue =
          initialTimerState.isCountDown ? initialTimerState.countDownValue : 0;
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
      emit(initialState.copyWith(
        activeRunTimer: timerId,
        isPaused: false,
        timersStateList: updatedTimersStateList,
      ));
    });

    on<UpdateDistance>((event, emit) {
      final currentState = state as ActiveTrainingLoaded;
      final currentTimersStateList =
          List<TimerState>.from(currentState.timersStateList);
      final currentTimerState =
          currentTimersStateList.firstWhere((e) => e.timerId == event.timerId);

      final newTimerValue = currentTimerState.timerValue;

      final double newDistance = event.distance;

      final double newPace =
          newDistance > 0 ? newTimerValue * 1000 / newDistance : 0;

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
          timersStateList: currentTimersStateList,
        ),
      );
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
            newDistance > 0 ? newTimerValue * 1000 / newDistance : 0;

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
