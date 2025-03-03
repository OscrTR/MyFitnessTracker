import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:fl_location/fl_location.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../../core/enums/enums.dart';
import '../../../core/messages/toast.dart';
import '../../../core/database/database_service.dart';

import '../../training_history/models/history_run_location.dart';
import '../../training_management/models/training.dart';
import '../foreground_service.dart';
import 'package:uuid/uuid.dart';

import '../../../helper_functions.dart';
import '../../../injection_container.dart';
import '../../training_history/models/history_entry.dart';
import '../../training_history/bloc/training_history_bloc.dart';

part 'active_training_event.dart';
part 'active_training_state.dart';

const uuid = Uuid();

class ActiveTrainingBloc
    extends Bloc<ActiveTrainingEvent, ActiveTrainingState> {
  ActiveTrainingBloc() : super(ActiveTrainingInitial()) {
    final AudioPlayer audioPlayer = AudioPlayer()
      ..setReleaseMode(ReleaseMode.stop)
      ..setAudioContext(AudioContext(
        android: const AudioContextAndroid(
          audioFocus: AndroidAudioFocus.gainTransientMayDuck,
        ),
      ))
      ..setSource(AssetSource('sounds/countdown.mp3'));

    final FlutterTts flutterTts = FlutterTts();
    int? lastTimerValue;
    bool halfRunDone = false;

    Future<void> speak(String string) async {
      await flutterTts.speak(string);
    }

    void saveTrainingHistory(TimerState currentTimerState) {
      if (currentTimerState.timerId.contains('rest')) {
        return;
      }
      final historyBlocState = sl<TrainingHistoryBloc>().state;

      if (historyBlocState is TrainingHistoryLoaded) {
        final entries = historyBlocState.historyTrainings
            .where((trainingHistory) =>
                trainingHistory.training.id == currentTimerState.trainingId)
            .toList()
            .sortedBy((entry) => entry.date)
            .lastOrNull
            ?.historyEntries;

        final registeredId = entries
            ?.where((entry) =>
                entry.exerciseId == currentTimerState.exerciseId &&
                entry.setNumber == currentTimerState.setNumber &&
                entry.intervalNumber == currentTimerState.intervalNumber)
            .toList()
            .sortedBy((entry) => entry.date)
            .lastOrNull
            ?.id;

        int cals = 0;

        final activeState =
            (sl<ActiveTrainingBloc>().state as ActiveTrainingLoaded);

        final listOfExercises = activeState.activeTraining!.exercises;

        final matchingExercise = listOfExercises.firstWhere(
            (exercise) => exercise.id == currentTimerState.exerciseId);

        cals = getCalories(
            weight: 0,
            intensity: matchingExercise.intensity,
            duration: currentTimerState.isCountDown
                ? matchingExercise.duration
                : currentTimerState.timerValue);

        sl<TrainingHistoryBloc>().add(
          CreateOrUpdateHistoryEntry(
            historyEntry: HistoryEntry(
              id: registeredId,
              trainingId: currentTimerState.trainingId,
              exerciseId: currentTimerState.exerciseId,
              setNumber: currentTimerState.setNumber,
              date: DateTime.now(),
              duration: currentTimerState.isCountDown
                  ? currentTimerState.countDownValue
                  : currentTimerState.timerValue,
              distance: currentTimerState.distance.toInt(),
              pace: currentTimerState.pace.toInt(),
              calories: cals,
              intervalNumber: currentTimerState.intervalNumber,
              trainingVersionId: currentTimerState.trainingVersionId,
              reps: 0,
              weight: 0,
            ),
            timerState: null,
          ),
        );
      }
    }

    on<StartActiveTraining>((event, emit) async {
      try {
        final training =
            await sl<DatabaseService>().getTrainingById(event.trainingId);
        if (training == null) return;

        final lastTrainingVersion = await sl<DatabaseService>()
            .getMostRecentTrainingVersionForTrainingId(training.id!);

        final lastTrainingVersionId = lastTrainingVersion?.id!;

        if (state is ActiveTrainingLoaded) {
          final currentState = state as ActiveTrainingLoaded;
          emit(currentState.copyWith(
            activeTraining: training,
            activeTrainingMostRecentVersionId: lastTrainingVersionId,
          ));
        } else {
          emit(ActiveTrainingLoaded(
            activeTraining: training,
            activeTrainingMostRecentVersionId: lastTrainingVersionId,
          ));
        }
      } catch (e) {
        showToastMessage(
          message: e.toString(),
          isSuccess: false,
          isLog: true,
          logLevel: LogLevel.error,
          logFunction: 'StartActiveTraining',
        );
      }
    });

    on<ClearTimers>((event, emit) async {
      await sl<ForegroundService>().stopService();
      emit(ActiveTrainingInitial());
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

        final targetSpeed = currentTimerState.targetSpeed;
        final targetPaceMinutes = targetSpeed ~/ 60;
        final targetPaceSeconds = targetSpeed % 60;

        // COUNTDOWN
        if (currentTimerState.isCountDown) {
          if (currentTimerValue > 0) {
            if (currentTimerValue == 2) {
              // await playCountdown();
            }

            add(TickTimer(
                timerId: timerId,
                isCountDown: true,
                totalDistance: event.runDistance));
          } else {
            saveTrainingHistory(currentTimerState);

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

          // Calculate pace if distance > 0
          final isDistanceValid = currentDistance > 0;
          final pace = isDistanceValid
              ? currentTimerValue / 60 / (currentDistance / 1000)
              : 0;
          final paceMinutes = pace.floor();
          final paceSeconds = ((pace - paceMinutes) * 60).round();

          void checkPace() {
            if (currentTimerValue % 30 == 0 &&
                currentTimerState.targetSpeed > 0) {
              final targetPaceMargin = currentTimerState.targetSpeed * 0.05;
              if (pace < currentTimerState.targetSpeed - targetPaceMargin) {
                speak(tr('active_training_pace_faster', args: [
                  '$paceMinutes',
                  '$paceSeconds',
                  '$targetPaceMinutes',
                  '$targetPaceSeconds'
                ]));
              } else if (pace >
                  currentTimerState.targetSpeed + targetPaceMargin) {
                speak(tr('active_training_pace_slower', args: [
                  '$paceMinutes',
                  '$paceSeconds',
                  '$targetPaceMinutes',
                  '$targetPaceSeconds'
                ]));
              }
            }
          }

          void checkHalfRun() {
            final targetDistance = currentTimerState.targetDistance;
            final targetDuration = currentTimerState.targetDuration;

            if (halfRunDone) return;
            if (targetDistance > 0 && currentDistance >= targetDistance / 2) {
              speak(tr('active_training_half_training'));
              halfRunDone = true;
            } else if (targetDistance == 0 &&
                currentTimerValue >= targetDuration / 2) {
              speak(tr('active_training_half_training'));
              halfRunDone = true;
            }
          }

          void notifyKmProgress() {
            if (currentDistance > 0 && currentDistance / 1000 >= nextKmMarker) {
              speak(tr('active_training_pace',
                  args: ['$nextKmMarker', '$paceMinutes', '$paceSeconds']));
              add(UpdateNextKmMarker(
                  timerId: timerId, nextKmMarker: nextKmMarker + 1));
            }
          }

          void handleTimerCompletion() {
            sl<ForegroundService>().cancelTimer(timerId);
            add(UpdateDistance(timerId: timerId, distance: currentDistance));
            saveTrainingHistory(currentTimerState);

            if (nextTimerId != null &&
                currentState
                    .timersStateList[currentTimerIndex + 1].isAutostart) {
              add(StartTimer(timerId: nextTimerId));
            } else {
              add(PauseTimer());
            }
          }

          // DISTANCE TIMER
          if (currentTimerState.distance > 0 &&
              currentTimerState.targetDistance > 0) {
            // Check if the current distance equals the objective distance
            if (currentDistance >= currentTimerState.targetDistance) {
              handleTimerCompletion();
            } else {
              checkPace();
              checkHalfRun();
              notifyKmProgress();

              add(TickTimer(
                  timerId: timerId, totalDistance: event.runDistance));
            }
          }
          // DURATION TIMER
          else {
            // Check if the current duration equals the objective duration
            if (currentTimerState.targetDuration > 0 &&
                currentTimerValue >= currentTimerState.targetDuration) {
              handleTimerCompletion();
            } else {
              if (currentTimerState.distance > 0 &&
                  currentTimerState.targetDuration > 0) {
                checkPace();
                checkHalfRun();
                notifyKmProgress();
              }

              add(TickTimer(
                  timerId: timerId, totalDistance: event.runDistance));
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
            final runLocation = RunLocation(
              trainingId: timerState.trainingId,
              exerciseId: timerState.exerciseId,
              setNumber: timerState.setNumber,
              intervalNumber: timerState.intervalNumber,
              latitude: event.locationData!.latitude,
              longitude: event.locationData!.longitude,
              altitude: event.locationData!.altitude,
              date: DateTime.now().millisecondsSinceEpoch,
              accuracy: event.locationData!.accuracy,
              speed: event.locationData!.speed,
              trainingVersionId: timerState.trainingVersionId,
            );

            sl<DatabaseService>().createRunLocation(runLocation);
          }
        }
      }
    });

    on<StartTimer>((event, emit) async {
      final timerId = event.timerId;

      await audioPlayer.pause();
      audioPlayer.seek(const Duration(milliseconds: 0));

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
      if (state is! ActiveTrainingLoaded) return;
      final currentState = state as ActiveTrainingLoaded;

      final currentTimersStateList =
          List<TimerState>.from(currentState.timersStateList);

      final timerIndex =
          currentTimersStateList.indexWhere((e) => e.timerId == event.timerId);

      final currentTimerState = currentTimersStateList[timerIndex];

      lastTimerValue = currentState.timersStateList
          .firstWhereOrNull(
              (el) => el.timerId == currentState.lastStartedTimerId)
          ?.timerValue;

      final newTimerValue = event.isCountDown
          ? currentTimerState.timerValue - 1
          : currentTimerState.timerValue + 1;

      if (event.isCountDown && newTimerValue == 2) {
        audioPlayer.resume();
      }

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

      currentTimersStateList[timerIndex] = updatedTimerState;

      emit(
        currentState.copyWith(
          timersStateList: currentTimersStateList,
        ),
      );
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
