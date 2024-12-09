import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pausable_timer/pausable_timer.dart';

part 'active_training_event.dart';
part 'active_training_state.dart';

class ActiveTrainingBloc
    extends Bloc<ActiveTrainingEvent, ActiveTrainingState> {
  final Map<String, PausableTimer> _timers = {};
  final RunTracker _runTracker = RunTracker();
  double _distance = 0.0;

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
      }

      int timerValue =
          event.isCountDown ? event.duration : (currentTimers[timerId] ?? 0);

      final timer = PausableTimer.periodic(
        const Duration(seconds: 1),
        () {
          if (event.isCountDown) {
            if (timerValue > 0) {
              timerValue--;
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
            if (event.isDistance) {
              //TODO: Check if current distance equals to objective
              // Check if the current distance equals the objective distance
              //     final currentDistance = getCurrentDistance(timerId); // Replace with your logic
              // if (currentDistance >= event.duration) {
              //   _timers[timerId]?.cancel();
              //   if (event.onComplete != null) {
              //     event.onComplete!(); // Call onComplete when distance goal is reached
              //   }
              // completer.complete();
            } else {
              // Check if the current duration equals the objective duration
              if (event.duration > 0 && timerValue >= event.duration) {
                _timers[timerId]?.cancel();
                if (event.isRunTimer) {
                  _runTracker.stopTracking();
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

        final updatedTimers = Map<String, int>.from(currentTimers);
        updatedTimers['secondaryTimer'] = 0;

        emit(currentState.copyWith(
          timers: updatedTimers,
        ));
      }
    });
  }
  @override
  Future<void> close() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
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
      print('Location services are disabled.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        print('Location permissions are permanently denied.');
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
      print('Distance Traveled: $totalDistance meters');
    });
  }

  void stopTracking() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    _previousPosition = null;
    totalDistance = 0.0;
  }
}
