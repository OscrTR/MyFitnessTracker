import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:pausable_timer/pausable_timer.dart';

part 'active_training_event.dart';
part 'active_training_state.dart';

class ActiveTrainingBloc
    extends Bloc<ActiveTrainingEvent, ActiveTrainingState> {
  final Map<String, PausableTimer> _timers = {};

  ActiveTrainingBloc() : super(ActiveTrainingInitial()) {
    // Initialize the periodic timer

    on<StartTimer>((event, emit) {
      final currentTimers = state is ActiveTrainingLoaded
          ? (state as ActiveTrainingLoaded).timers
          : {};

      // Initialize or reset the timer for the given timerId
      final timerId = event.timerId;

      _timers[timerId]?.cancel(); // Cancel any existing timer for this ID

      int timerValue =
          event.isCountDown ? event.duration : (currentTimers[timerId] ?? 0);

      final timer = PausableTimer.periodic(
        const Duration(seconds: 1),
        () {
          if (event.isCountDown) {
            if (timerValue > 0) {
              timerValue--;
              add(TickSecondaryTimer(timerId: timerId, isCountDown: true));
            } else {
              _timers[timerId]?.cancel();
              if (event.onComplete != null) {
                event.onComplete!();
              }
            }
          } else {
            timerValue++;
            add(TickSecondaryTimer(timerId: timerId));
          }
        },
      );

      _timers[timerId] = timer;
      timer.start();

      emit(ActiveTrainingLoaded({
        ...currentTimers,
        timerId: timerValue,
      }, false));
    });

    on<TickSecondaryTimer>((event, emit) {
      if (state is ActiveTrainingLoaded) {
        final currentTimers = (state as ActiveTrainingLoaded).timers;
        final timerId = event.timerId;

        if (!currentTimers.containsKey(timerId)) return;

        emit(ActiveTrainingLoaded({
          ...currentTimers,
          timerId: event.isCountDown
              ? currentTimers[timerId]! - 1
              : currentTimers[timerId]! + 1,
        }, (state as ActiveTrainingLoaded).isPaused));
      }
    });

    on<PauseTimer>((event, emit) {
      final currentState = state as ActiveTrainingLoaded;

      if (currentState.isPaused) {
        if (_timers[event.timerId] != null) {
          _timers[event.timerId]?.start();
        }
        _timers['primaryTimer']?.start();
        _timers['secondaryTimer']?.start();
        emit(currentState.copyWith(isPaused: false));
      } else {
        _timers[event.timerId]?.pause();
        _timers['primaryTimer']?.pause();
        _timers['secondaryTimer']?.pause();
        emit(currentState.copyWith(isPaused: true));
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
