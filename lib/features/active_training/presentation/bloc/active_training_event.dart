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
  final Completer<String>? completer;

  const StartTimer(
      {required this.timerId,
      this.activeRunTimer,
      this.duration = 0,
      this.isCountDown = false,
      this.isDistance = false,
      this.completer});

  @override
  List<Object?> get props =>
      [timerId, activeRunTimer, duration, isCountDown, isDistance, completer];
}

class TickTimer extends ActiveTrainingEvent {
  final String timerId;
  final bool isCountDown;

  const TickTimer({required this.timerId, this.isCountDown = false});

  @override
  List<Object?> get props => [timerId, isCountDown];
}

class PauseTimer extends ActiveTrainingEvent {}

class ResetSecondaryTimer extends ActiveTrainingEvent {}
