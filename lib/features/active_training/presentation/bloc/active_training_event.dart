part of 'active_training_bloc.dart';

abstract class ActiveTrainingEvent extends Equatable {
  const ActiveTrainingEvent();

  @override
  List<Object?> get props => [];
}

class StartTimer extends ActiveTrainingEvent {
  final String timerId;
  final String? activeRunTimer;
  final int duration;
  final bool isCountDown;
  final int distance;
  final bool isRunTimer;
  final Completer<String>? completer;
  final int pace;

  const StartTimer({
    required this.timerId,
    this.activeRunTimer,
    this.duration = 0,
    this.isCountDown = false,
    this.distance = 0,
    this.isRunTimer = false,
    this.completer,
    this.pace = 0,
  });

  @override
  List<Object?> get props => [
        timerId,
        activeRunTimer,
        duration,
        isCountDown,
        distance,
        isRunTimer,
        completer,
        pace,
      ];
}

class TickTimer extends ActiveTrainingEvent {
  final String timerId;
  final bool isCountDown;
  final bool isRunTimer;

  const TickTimer(
      {required this.timerId,
      this.isCountDown = false,
      this.isRunTimer = false});

  @override
  List<Object?> get props => [timerId, isCountDown, isRunTimer];
}

class PauseTimer extends ActiveTrainingEvent {}

class ResetSecondaryTimer extends ActiveTrainingEvent {}
