import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:fl_location/fl_location.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:my_fitness_tracker/features/training_management/presentation/bloc/training_management_bloc.dart';
import 'package:my_fitness_tracker/features/active_training/presentation/foreground_service.dart';
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
    int? lastTimerValue;

    Future<void> playCountdown() async {
      await audioPlayer.play(AssetSource('sounds/countdown.mp3'));
    }

    Future<void> speak(String string) async {
      await flutterTts.speak(string);
    }

    void saveTrainingHistory(TimerState currentTimerState) {
      final registeredId =
          (sl<TrainingHistoryBloc>().state as TrainingHistoryLoaded)
              .historyEntries
              .firstWhereOrNull((el) =>
                  el.trainingExerciseId == currentTimerState.tExerciseId &&
                  el.setNumber == currentTimerState.setNumber &&
                  el.trainingId == currentTimerState.trainingId &&
                  el.multisetSetNumber == currentTimerState.multisetSetNumber)
              ?.id;

      int cals = 0;

      final trainingManagementState =
          (sl<TrainingManagementBloc>().state as TrainingManagementLoaded);

      final listOfTExercises = [
        ...trainingManagementState.activeTraining!.trainingExercises
      ];
      for (var multiset in trainingManagementState.activeTraining!.multisets) {
        listOfTExercises.addAll([...multiset.trainingExercises!]);
      }

      final matchingTExercise = listOfTExercises.firstWhere(
          (tExercise) => tExercise.id == currentTimerState.tExerciseId);

      cals = getCalories(
          intensity: matchingTExercise.intensity,
          duration: currentTimerState.isCountDown
              ? matchingTExercise.duration
              : currentTimerState.timerValue);

      sl<TrainingHistoryBloc>().add(
        CreateOrUpdateHistoryEntry(
          historyEntry: HistoryEntry(
            id: registeredId,
            trainingId: currentTimerState.trainingId,
            trainingExerciseId: currentTimerState.tExerciseId,
            setNumber: currentTimerState.setNumber,
            multisetSetNumber: currentTimerState.multisetSetNumber,
            date: DateTime.now(),
            duration: currentTimerState.isCountDown
                ? currentTimerState.countDownValue
                : currentTimerState.timerValue,
            distance: currentTimerState.distance.toInt(),
            pace: currentTimerState.pace.toInt(),
            calories: cals,
            trainingType: trainingManagementState.activeTraining!.type,
            trainingExerciseType: matchingTExercise.trainingExerciseType,
            trainingNameAtTime: trainingManagementState.activeTraining!.name,
            exerciseNameAtTime: findExerciseName(matchingTExercise),
            intensity: matchingTExercise.intensity,
          ),
        ),
      );
    }

    on<LoadDefaultActiveTraining>((event, emit) async {
      emit(const ActiveTrainingLoaded(timersStateList: []));
    });

    on<ClearTimers>((event, emit) async {
      await sl<ForegroundService>().stopService();
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
            if (!timerId.contains('rest')) {
              saveTrainingHistory(currentTimerState);
            }
            sl<ForegroundService>().cancelTimer(timerId);

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
          }

          // RUN DISTANCE
          if (currentState.timersStateList[currentTimerIndex].distance > 0) {
            // Check if the current distance equals the objective distance
            if (currentTimerState.targetDistance > 0 &&
                currentDistance >= currentTimerState.targetDistance) {
              sl<ForegroundService>().cancelTimer(timerId);

              if (currentTimerState.isRunTimer) {
                add(UpdateDistance(
                    timerId: timerId, distance: currentDistance));
                if (!timerId.contains('rest')) {
                  saveTrainingHistory(currentTimerState);
                }
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
              sl<ForegroundService>().cancelTimer(timerId);

              if (!timerId.contains('rest')) {
                saveTrainingHistory(currentTimerState);
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
        }
      }
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
        emit(currentState.copyWith(timersStateList: currentTimersList));
      }
    });

    on<UpdateDataFromForeground>((event, emit) async {
      if (state is ActiveTrainingLoaded) {
        if (event.timerId != null && event.totalDistance != null) {
          add(UpdateTimer(
              timerId: event.timerId!, runDistance: event.totalDistance!));
        }
        if (event.locationData != null && event.timerId != null) {
          final timerState =
              (sl<ActiveTrainingBloc>().state as ActiveTrainingLoaded)
                  .timersStateList
                  .firstWhereOrNull(
                      (el) => el.isActive && el.timerId != 'primaryTimer');

          if (timerState != null) {
            await sl<Database>().insert(
              'run_locations',
              {
                'training_id': timerState.trainingId,
                'training_exercise_id': timerState.tExerciseId,
                'set_number': timerState.setNumber,
                'multiset_set_number': timerState.multisetSetNumber,
                'latitude': event.locationData!.latitude,
                'longitude': event.locationData!.longitude,
                'altitude': event.locationData!.altitude,
                'timestamp': DateTime.now().millisecondsSinceEpoch,
                'accuracy': event.locationData!.accuracy,
                'speed': event.locationData!.speed,
              },
            );
          }
        }
      }
    });

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

        final startingValue = currentTimerState != null
            ? currentTimerState.isCountDown
                ? currentTimerState.countDownValue
                : 0
            : 0;

        await sl<ForegroundService>().initService();
        sl<ForegroundService>()
            .startTimer(timerId, currentTimerState?.isRunTimer ?? false);

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

        sl<ForegroundService>().updateNotificationText(
          'Timer: ${formatDurationToMinutesSeconds(lastTimerValue)}${event.totalDistance > 0 ? '\nDistance : ${event.totalDistance.floor()}m' : ''} ',
        );

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

        sl<ForegroundService>().pauseTimer();
      }
      // Start last active timer + primaryTimer
      else {
        final primaryTimerIndex = currentTimersStateList
            .indexWhere((el) => el.timerId == 'primaryTimer');
        final lastTimerIndex = currentTimersStateList
            .indexWhere((el) => el.timerId == currentState.lastStartedTimerId);

        sl<ForegroundService>()
            .unpauseTimer(currentState.lastStartedTimerId ?? '');

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
