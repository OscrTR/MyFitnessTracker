import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:my_fitness_tracker/background_service.dart';

import 'package:uuid/uuid.dart';

part 'active_training_event.dart';
part 'active_training_state.dart';

const uuid = Uuid();

class ActiveTrainingBloc
    extends Bloc<ActiveTrainingEvent, ActiveTrainingState> {
  ActiveTrainingBloc() : super(ActiveTrainingInitial()) {
    on<LoadDefaultActiveTraining>((event, emit) async {
      emit(const ActiveTrainingLoaded(timersStateList: []));
    });

    // FlutterBackgroundService().on('updateTimer').listen((data) {
    //   if (data != null && data['timerId'] != null) {
    //     add(UpdateTimer(
    //       timerId: data['timerId'],
    //       runDistance: data['runDistance'].toDouble(),
    //     ));
    //   }
    // });

    // FlutterBackgroundService().on('startTimer').listen((data) {
    //   if (data != null && data['timerId'] != null) {
    //     add(StartTimer(timerId: data['timerId']));
    //   }
    // });

    // FlutterBackgroundService().on('pauseTimer').listen((data) {
    //   add(PauseTimer());
    // });

    on<UpdateTimer>((event, emit) async {
      final timerId = event.timerId;

      if (state is ActiveTrainingLoaded) {
        final currentState = state as ActiveTrainingLoaded;

        final currentTimerIndex = currentState.timersStateList
            .indexWhere((el) => el.timerId == timerId);
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

        if (currentTimerState.isCountDown) {
          if (currentTimerValue > 0) {
            if (currentTimerValue == 2) {
              // service.invoke('playCountDown');
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
            // service.invoke('cancelTimer', {'timerId': timerId});
            if (currentTimerState.isRunTimer) {
              // service.invoke('stopLocationTracking');
            }
            // Start next timer if autostart
            if (nextTimerId != null) {
              final autostart = currentState
                  .timersStateList[currentTimerIndex + 1].isAutostart;

              if (autostart) {
                // service.invoke('startTracking', {'timerId': nextTimerId});
              }
            } else {
              // service.invoke('pauseTracking', {'timerId': ''});
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
              // service.invoke('speak', {
              //   'message': tr('active_training_pace_faster', args: [
              //     '$paceMinutes',
              //     '$paceSeconds',
              //     '$targetPaceMinutes',
              //     '$targetPaceSeconds'
              //   ])
              // });
            }
            if (pace >
                currentTimerState.targetPace +
                    (currentTimerState.targetPace * 0.05)) {
              // service.invoke('speak', {
              //   'message': tr('active_training_pace_slower', args: [
              //     '$paceMinutes',
              //     '$paceSeconds',
              //     '$targetPaceMinutes',
              //     '$targetPaceSeconds'
              //   ])
              // });
            }
          }

          if (currentDistance > 0 && currentDistance / 1000 >= nextKmMarker) {
            // service.invoke('speak', {
            //   'message': tr('active_training_pace',
            //       args: ['$nextKmMarker', '$paceMinutes', '$paceSeconds'])
            // });
            add(UpdateNextKmMarker(
                timerId: timerId, nextKmMarker: nextKmMarker + 1));
          }

          if (currentState.timersStateList[currentTimerIndex].distance > 0) {
            // Check if the current distance equals the objective distance
            if (currentTimerState.targetDistance > 0 &&
                currentDistance >= currentTimerState.targetDistance) {
              // service.invoke('cancelTimer', {'timerId': timerId});

              if (currentTimerState.isRunTimer) {
                add(UpdateDistance(
                    timerId: timerId, distance: currentDistance));
                // service.invoke('stopLocationTracking');
              }

              // Start next timer if autostart
              if (nextTimerId != null) {
                final autostart = currentState
                    .timersStateList[currentTimerIndex + 1].isAutostart;

                if (autostart) {
                  // service.invoke('startTracking', {'timerId': nextTimerId});
                }
              } else {
                // service.invoke('pauseTracking', {'timerId': ''});
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
          } else {
            // Check if the current duration equals the objective duration
            if (currentTimerState.targetDuration > 0 &&
                currentTimerValue >= currentTimerState.targetDuration) {
              // service.invoke('cancelTimer', {'timerId': timerId});
              if (currentTimerState.isRunTimer) {
                // service.invoke('stopLocationTracking');
              }

              // Start next timer if autostart
              if (nextTimerId != null) {
                final autostart = currentState
                    .timersStateList[currentTimerIndex + 1].isAutostart;
                if (autostart) {
                  // service.invoke('startTracking', {'timerId': nextTimerId});
                }
              } else {
                // service.invoke('pauseTracking', {'timerId': ''});
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

        // Mettre en pause tous les autres timers sauf primary
        for (var i = 0; i < currentTimersStateList.length; i++) {
          if (currentTimersStateList[i].isActive == true &&
              currentTimersStateList[i].timerId != 'primaryTimer') {
            updatedTimersStateList[i] =
                currentTimersStateList[i].copyWith(isActive: false);
          }
        }
        final startingValue = currentTimerState!.isCountDown
            ? currentTimerState.countDownValue
            : 0;
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
              updatedTimersStateList.firstWhere(
                  (e) => e.timerId == timerId))] = updatedTimerState;
        }

        emit(currentState.copyWith(
            lastStartedTimerId: currentTimerState.timerId,
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
      if (currentState.timersStateList.any((el) => el.isActive)) {
        currentState.timersStateList.asMap().forEach((index, el) {
          currentTimersStateList[index] =
              currentTimersStateList[index].copyWith(isActive: false);
        });
      } else {
        final primaryTimerIndex = currentTimersStateList
            .indexWhere((el) => el.timerId == 'primaryTimer');
        final lastTimerIndex = currentTimersStateList
            .indexWhere((el) => el.timerId == currentState.lastStartedTimerId);

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
