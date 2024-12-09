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
  final bool isDistance;
  final bool isRunTimer;
  final Completer<String>? completer;

  const StartTimer(
      {required this.timerId,
      this.activeRunTimer,
      this.duration = 0,
      this.isCountDown = false,
      this.isDistance = false,
      this.isRunTimer = false,
      this.completer});

  @override
  List<Object?> get props => [
        timerId,
        activeRunTimer,
        duration,
        isCountDown,
        isDistance,
        isRunTimer,
        completer
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
