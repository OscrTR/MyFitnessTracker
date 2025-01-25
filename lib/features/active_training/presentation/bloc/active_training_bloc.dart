import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:location/location.dart';
import 'package:pausable_timer/pausable_timer.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../../../helper_functions.dart';
import '../../../../injection_container.dart';
import '../../../training_history/domain/entities/history_entry.dart';
import '../../../training_history/presentation/bloc/training_history_bloc.dart';

part 'active_training_event.dart';
part 'active_training_state.dart';

const uuid = Uuid();

class ActiveTrainingBloc
    extends Bloc<ActiveTrainingEvent, ActiveTrainingState> {
  ActiveTrainingBloc() : super(ActiveTrainingInitial()) {
    final AudioPlayer audioPlayer = AudioPlayer();
    final FlutterTts flutterTts = FlutterTts();
    final RunTracker runTracker = RunTracker();
    int? notificationId;
    late StreamController<int> timerStreamController;
    late Stream<int> timerStream;
    int? lastTimerValue;

    final Map<String, PausableTimer> timers = {};

    Future<void> playCountdown() async {
      await audioPlayer.play(AssetSource('sounds/countdown.mp3'));
    }

    Future<void> speak(String string) async {
      await flutterTts.speak(string);
    }

    on<LoadDefaultActiveTraining>((event, emit) async {
      emit(const ActiveTrainingLoaded(timersStateList: []));
    });

    on<ClearTimers>((event, emit) async {
      for (var timer in timers.values) {
        timer.cancel();
      }
      timers.clear();
      runTracker.stopTracking();
      emit(const ActiveTrainingLoaded(timersStateList: []));
    });

    on<UpdateTimer>((event, emit) async {
      final timerId = event.timerId;
      if (state is ActiveTrainingLoaded) {
        final currentState = state as ActiveTrainingLoaded;

        final currentTimerIndex = currentState.timersStateList
            .indexWhere((el) => el.timerId == timerId);
        if (currentTimerIndex == -1) {
          return;
        }
        String? nextTimerId;
        if (currentTimerIndex + 1 < (currentState.timersStateList.length - 2)) {
          nextTimerId =
              currentState.timersStateList[currentTimerIndex + 1].timerId;
        }

        final currentTimerState =
            currentState.timersStateList[currentTimerIndex];
        final currentTimerValue = currentTimerState.timerValue;

        final targetPace = currentTimerState.targetPace;
        final targetPaceMinutes = targetPace ~/ 60;
        final targetPaceSeconds = targetPace % 60;

        // COUNTDOWN
        if (currentTimerState.isCountDown) {
          if (currentTimerValue > 0) {
            if (currentTimerValue == 2) {
              await playCountdown();
            }
            if (currentTimerState.isRunTimer) {
              add(TickTimer(
                  timerId: timerId,
                  isCountDown: true,
                  isRunTimer: true,
                  totalDistance: event.runDistance));
            } else {
              add(TickTimer(timerId: timerId, isCountDown: true));
            }
          } else {
            // Register history entry
            if (!timerId.contains('rest') &&
                currentTimerState.tExerciseId != null) {
              // Récupérer l'id de l'entrée existante
              final registeredId = (sl<TrainingHistoryBloc>().state
                      as TrainingHistoryLoaded)
                  .historyEntries
                  .firstWhereOrNull((el) =>
                      el.trainingExerciseId == currentTimerState.tExerciseId &&
                      el.setNumber == currentTimerState.setNumber &&
                      el.trainingId == currentTimerState.trainingId &&
                      el.multisetSetNumber ==
                          currentTimerState.multisetSetNumber)
                  ?.id;
              sl<TrainingHistoryBloc>().add(CreateOrUpdateHistoryEntry(
                  historyEntry: HistoryEntry(
                      id: registeredId,
                      trainingId: currentTimerState.trainingId,
                      trainingExerciseId: currentTimerState.tExerciseId,
                      setNumber: currentTimerState.setNumber,
                      multisetSetNumber: currentTimerState.multisetSetNumber,
                      date: DateTime.now(),
                      duration: currentTimerState.countDownValue)));
            }
            runTracker.stopTracking();
            timers[timerId]?.cancel();
            // Start next timer if autostart
            if (nextTimerId != null) {
              final autostart = currentState
                  .timersStateList[currentTimerIndex + 1].isAutostart;

              if (autostart) {
                add(StartTimer(timerId: nextTimerId));
              }
            } else {
              add(PauseTimer());
            }
          }
        } else {
          final currentDistance = currentTimerState.distance;
          final nextKmMarker = currentTimerState.nextKmMarker;
          int paceMinutes = 0;
          int paceSeconds = 0;
          double pace = 0;
          if (currentDistance > 0) {
            pace = currentTimerValue / 60 / (currentDistance / 1000);
            paceMinutes = pace.floor();
            paceSeconds = ((pace - paceMinutes) * 60).round();
          }

          // Check pace every 30 seconds if pace is tracked
          if (currentTimerState.targetPace > 0 && currentTimerValue % 30 == 0) {
            // Check if 5% slower
            if (pace <
                currentTimerState.targetPace -
                    (currentTimerState.targetPace * 0.05)) {
              speak(tr('active_training_pace_faster', args: [
                '$paceMinutes',
                '$paceSeconds',
                '$targetPaceMinutes',
                '$targetPaceSeconds'
              ]));
            }
            if (pace >
                currentTimerState.targetPace +
                    (currentTimerState.targetPace * 0.05)) {
              speak(tr('active_training_pace_slower', args: [
                '$paceMinutes',
                '$paceSeconds',
                '$targetPaceMinutes',
                '$targetPaceSeconds'
              ]));
            }
          }

          // NOTIFY EVERY KM
          if (currentDistance > 0 && currentDistance / 1000 >= nextKmMarker) {
            speak(tr('active_training_pace',
                args: ['$nextKmMarker', '$paceMinutes', '$paceSeconds']));
            add(UpdateNextKmMarker(
                timerId: timerId, nextKmMarker: nextKmMarker + 1));
            if (!timerId.contains('rest')) {
              sl<TrainingHistoryBloc>().add(CreateOrUpdateHistoryEntry(
                  historyEntry: HistoryEntry(
                trainingId: currentTimerState.trainingId,
                trainingExerciseId: currentTimerState.tExerciseId,
                setNumber: currentTimerState.setNumber,
                multisetSetNumber: currentTimerState.multisetSetNumber,
                date: DateTime.now(),
                duration: currentTimerState.timerValue,
                distance: currentTimerState.distance.toInt(),
                pace: currentTimerState.pace.toInt(),
              )));
            }
          }

          // RUN DISTANCE
          if (currentState.timersStateList[currentTimerIndex].distance > 0) {
            // Check if the current distance equals the objective distance
            if (currentTimerState.targetDistance > 0 &&
                currentDistance >= currentTimerState.targetDistance) {
              timers[timerId]?.cancel();
              if (currentTimerState.isRunTimer) {
                add(UpdateDistance(
                    timerId: timerId, distance: currentDistance));
                if (!timerId.contains('rest')) {
                  // Récupérer l'id de l'entrée existante
                  final registeredId =
                      (sl<TrainingHistoryBloc>().state as TrainingHistoryLoaded)
                          .historyEntries
                          .firstWhereOrNull((el) =>
                              el.trainingExerciseId ==
                                  currentTimerState.tExerciseId &&
                              el.setNumber == currentTimerState.setNumber &&
                              el.trainingId == currentTimerState.trainingId &&
                              el.multisetSetNumber ==
                                  currentTimerState.multisetSetNumber)
                          ?.id;
                  sl<TrainingHistoryBloc>().add(CreateOrUpdateHistoryEntry(
                      historyEntry: HistoryEntry(
                    id: registeredId,
                    trainingId: currentTimerState.trainingId,
                    trainingExerciseId: currentTimerState.tExerciseId,
                    setNumber: currentTimerState.setNumber,
                    multisetSetNumber: currentTimerState.multisetSetNumber,
                    date: DateTime.now(),
                    duration: currentTimerState.timerValue,
                    distance: currentTimerState.distance.toInt(),
                    pace: currentTimerState.pace.toInt(),
                  )));
                }
                runTracker.stopTracking();
              }

              // Start next timer if autostart
              if (nextTimerId != null) {
                final autostart = currentState
                    .timersStateList[currentTimerIndex + 1].isAutostart;

                if (autostart) {
                  add(StartTimer(timerId: nextTimerId));
                }
              } else {
                add(PauseTimer());
              }
            } else {
              if (currentTimerState.isRunTimer) {
                add(TickTimer(
                    timerId: timerId,
                    isRunTimer: true,
                    totalDistance: event.runDistance));
              } else {
                add(TickTimer(timerId: timerId));
              }
            }
          }
          // RUN DURATION
          else {
            // Check if the current duration equals the objective duration
            if (currentTimerState.targetDuration > 0 &&
                currentTimerValue >= currentTimerState.targetDuration) {
              timers[timerId]?.cancel();
              if (!timerId.contains('rest')) {
                // Récupérer l'id de l'entrée existante
                final registeredId =
                    (sl<TrainingHistoryBloc>().state as TrainingHistoryLoaded)
                        .historyEntries
                        .firstWhereOrNull((el) =>
                            el.trainingExerciseId ==
                                currentTimerState.tExerciseId &&
                            el.setNumber == currentTimerState.setNumber &&
                            el.trainingId == currentTimerState.trainingId &&
                            el.multisetSetNumber ==
                                currentTimerState.multisetSetNumber)
                        ?.id;
                sl<TrainingHistoryBloc>().add(CreateOrUpdateHistoryEntry(
                    historyEntry: HistoryEntry(
                  id: registeredId,
                  trainingId: currentTimerState.trainingId,
                  trainingExerciseId: currentTimerState.tExerciseId,
                  setNumber: currentTimerState.setNumber,
                  multisetSetNumber: currentTimerState.multisetSetNumber,
                  date: DateTime.now(),
                  duration: currentTimerState.timerValue,
                  distance: currentTimerState.distance.toInt(),
                  pace: currentTimerState.pace.toInt(),
                )));
              }
              runTracker.stopTracking();

              // Start next timer if autostart
              if (nextTimerId != null) {
                final autostart = currentState
                    .timersStateList[currentTimerIndex + 1].isAutostart;
                if (autostart) {
                  add(StartTimer(timerId: nextTimerId));
                }
              } else {
                add(PauseTimer());
              }
            } else {
              if (currentTimerState.isRunTimer) {
                add(TickTimer(
                    timerId: timerId,
                    isRunTimer: true,
                    totalDistance: event.runDistance));
              } else {
                add(TickTimer(timerId: timerId));
              }
            }
          }
        }
      }
    });

    Future<void> cancelTimer(String timerId) async {
      if (timers.containsKey(timerId)) {
        timers[timerId]?.cancel();
        timers.remove(timerId);
      }
    }

    Future<void> startTimer(String timerId, void Function() callback) async {
      if (timers.containsKey(timerId)) {
        await cancelTimer(timerId);
      }
      timers[timerId] =
          PausableTimer.periodic(const Duration(seconds: 1), () async {
        callback();
      });

      timers[timerId]?.start();
    }

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
        emit(currentState.copyWith(timersStateList: currentTimersList));
      }
    });

    void showNotification() async {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails('your_channel_id', 'your_channel_name',
              importance: Importance.low,
              priority: Priority.low,
              ongoing: true,
              onlyAlertOnce: true,
              ticker: 'ticker');
      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);
      await sl<FlutterLocalNotificationsPlugin>().show(
          notificationId ?? 0,
          'Timer Update',
          'Timer: ${formatDurationToMinutesSeconds(lastTimerValue)}${runTracker._locationSubscription != null ? '\nDistance : ${runTracker.totalDistance.floor()}m' : ''} ',
          platformChannelSpecifics,
          payload: 'item x');
    }

    on<StartTimer>((event, emit) async {
      final timerId = event.timerId;

      if (state is ActiveTrainingLoaded) {
        final currentState = state as ActiveTrainingLoaded;
        final currentTimersStateList =
            List<TimerState>.from(currentState.timersStateList);

        final currentTimerState = currentState.timersStateList
            .firstWhereOrNull((el) => el.timerId == timerId);

        final updatedTimersStateList =
            List<TimerState>.from(currentState.timersStateList);

        // Pause all timers except primary
        for (var i = 0; i < currentTimersStateList.length; i++) {
          if (currentTimersStateList[i].isActive == true &&
              currentTimersStateList[i].timerId != 'primaryTimer') {
            updatedTimersStateList[i] =
                currentTimersStateList[i].copyWith(isActive: false);
          }
        }

        runTracker.stopTracking();
        if (currentTimerState != null && currentTimerState.isRunTimer) {
          runTracker.startTracking();
        }

        if (notificationId == null) {
          notificationId = await runTracker.initTracker();
          timerStreamController = StreamController<int>();
          timerStream = timerStreamController.stream;

          timerStreamController.stream.listen((int value) {
            showNotification();
          });
        }

        await startTimer(timerId, () {
          timerStreamController.add(0);
          add(UpdateTimer(
              timerId: timerId, runDistance: runTracker.totalDistance));
        });

        if (timers['primaryTimer'] != null &&
            timers['primaryTimer']!.isPaused) {
          timers['primaryTimer']!.start();
        }

        final startingValue = currentTimerState != null
            ? currentTimerState.isCountDown
                ? currentTimerState.countDownValue
                : 0
            : 0;

        if (updatedTimersStateList.any((e) => e.timerId == timerId)) {
          final currentTimerState =
              updatedTimersStateList.firstWhere((e) => e.timerId == timerId);

          final updatedTimerState = currentTimerState.copyWith(
            isActive: true,
            isStarted: true,
            timerValue: startingValue,
          );
          updatedTimersStateList[updatedTimersStateList.indexOf(
              updatedTimersStateList.firstWhere(
                  (e) => e.timerId == timerId))] = updatedTimerState;
        }

        emit(currentState.copyWith(
            lastStartedTimerId: currentTimerState?.timerId,
            timersStateList: updatedTimersStateList));
      }
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

    on<UpdateNextKmMarker>((event, emit) {
      final currentState = state as ActiveTrainingLoaded;
      final currentTimersStateList =
          List<TimerState>.from(currentState.timersStateList);
      final currentTimerState =
          currentTimersStateList.firstWhere((e) => e.timerId == event.timerId);

      final int newMarker = event.nextKmMarker;

      final updatedTimerState = currentTimerState.copyWith(
        nextKmMarker: newMarker,
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

        final currentTimersStateList =
            List<TimerState>.from(currentState.timersStateList);

        final currentTimerState = currentTimersStateList
            .firstWhere((e) => e.timerId == event.timerId);

        lastTimerValue = currentState.timersStateList
            .firstWhereOrNull(
                (el) => el.timerId == currentState.lastStartedTimerId)
            ?.timerValue;

        final newTimerValue = event.isCountDown
            ? currentTimerState.timerValue - 1
            : currentTimerState.timerValue + 1;

        final double newDistance = event.totalDistance;

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
      }
    });

    on<PauseTimer>((event, emit) {
      final currentState = state as ActiveTrainingLoaded;
      final currentTimersStateList =
          List<TimerState>.from(currentState.timersStateList);

      // Pause all timers
      if (currentState.timersStateList.any((el) => el.isActive)) {
        currentState.timersStateList.asMap().forEach((index, el) {
          currentTimersStateList[index] =
              currentTimersStateList[index].copyWith(isActive: false);
        });
        for (var timer in timers.values) {
          timer.pause();
        }
      }
      // Start last active timer + primaryTimer
      else {
        final primaryTimerIndex = currentTimersStateList
            .indexWhere((el) => el.timerId == 'primaryTimer');
        final lastTimerIndex = currentTimersStateList
            .indexWhere((el) => el.timerId == currentState.lastStartedTimerId);

        timers['primaryTimer']?.start();
        timers[currentState.lastStartedTimerId]?.start();

        currentTimersStateList[primaryTimerIndex] =
            currentTimersStateList[primaryTimerIndex].copyWith(isActive: true);
        currentTimersStateList[lastTimerIndex] =
            currentTimersStateList[lastTimerIndex].copyWith(isActive: true);
      }

      emit(
        currentState.copyWith(
          timersStateList: currentTimersStateList,
        ),
      );
    });
  }
}

class RunTracker {
  LocationData? _lastLocation;
  final Location _location = Location();
  StreamSubscription<LocationData>? _locationSubscription;
  double totalDistance = 0.0; // In meters

  Future<int> initTracker() async {
    PermissionStatus permission = await _location.hasPermission();
    if (permission == PermissionStatus.granted) {
      _location.enableBackgroundMode(enable: true);
    }
    final notifData = await _location.changeNotificationOptions(
        title: 'Timer Update', subtitle: '');
    return notifData != null ? notifData.notificationId : 0;
  }

  void startTracking() async {
    try {
      _locationSubscription =
          _location.onLocationChanged.listen((LocationData currentLocation) {
        _updateLocationAndDistance(currentLocation);
      });
    } catch (e) {
      print('error: $e');
    }
  }

  void _updateLocationAndDistance(LocationData currentLocation) async {
    if (_lastLocation != null) {
      double distanceInMeters = distanceBetween(
        _lastLocation!.latitude!,
        _lastLocation!.longitude!,
        currentLocation.latitude!,
        currentLocation.longitude!,
      );

      totalDistance += distanceInMeters;
    }
    _lastLocation = currentLocation;

    final trainingId = (sl<ActiveTrainingBloc>().state as ActiveTrainingLoaded)
        .timersStateList
        .firstWhereOrNull((el) => el.isActive && el.timerId != 'primaryTimer')
        ?.trainingId;

    final exerciseId = (sl<ActiveTrainingBloc>().state as ActiveTrainingLoaded)
        .timersStateList
        .firstWhereOrNull((el) => el.isActive && el.timerId != 'primaryTimer')
        ?.tExerciseId;

    if (trainingId != null && exerciseId != null) {
      await sl<Database>().insert('run_locations', {
        'training_id': trainingId,
        'exercise_id': exerciseId,
        'latitude': currentLocation.latitude,
        'longitude': currentLocation.longitude,
        'altitude': currentLocation.altitude,
        'timestamp': DateTime.now().toIso8601String(),
        'accuracy': currentLocation.accuracy,
        'speed': currentLocation.speed,
      });
    }
  }

  double distanceBetween(
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

  static _toRadians(double degree) {
    return degree * pi / 180;
  }

  void stopTracking() {
    _location.enableBackgroundMode(enable: false);
    _locationSubscription?.cancel();
    _locationSubscription = null;
    _lastLocation = null;
    totalDistance = 0.0;
  }
}
