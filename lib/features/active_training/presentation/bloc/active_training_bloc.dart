import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pausable_timer/pausable_timer.dart';

part 'active_training_event.dart';
part 'active_training_state.dart';

class ActiveTrainingBloc
    extends Bloc<ActiveTrainingEvent, ActiveTrainingState> {
  final Map<String, PausableTimer> _timers = {};

  ActiveTrainingBloc() : super(ActiveTrainingInitial()) {
    on<StartTimer>((event, emit) async {
      final currentTimers = state is ActiveTrainingLoaded
          ? (state as ActiveTrainingLoaded).timers
          : {};

      final timerId = event.timerId;
      _timers[timerId]?.cancel();

      int timerValue =
          event.isCountDown ? event.duration : (currentTimers[timerId] ?? 0);

      final timer = PausableTimer.periodic(
        const Duration(seconds: 1),
        () {
          if (event.isCountDown) {
            if (timerValue > 0) {
              timerValue--;
              add(TickTimer(timerId: timerId, isCountDown: true));
            } else {
              _timers[timerId]?.cancel();
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
              //TODO: check if current duration equals to objective
              // Check if the current duration equals the objective duration

              if (event.duration > 0 && timerValue >= event.duration) {
                _timers[timerId]?.cancel();
                event.completer?.complete('Duration ended.');
              } else {
                timerValue++;
                add(TickTimer(timerId: timerId)); // Update the timer value
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
        emit(ActiveTrainingLoaded({
          ...currentTimers,
          timerId: timerValue,
        }, false, event.activeRunTimer));
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
