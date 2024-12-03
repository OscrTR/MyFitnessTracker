part of 'active_training_bloc.dart';

abstract class ActiveTrainingEvent extends Equatable {
  const ActiveTrainingEvent();

  @override
  List<Object?> get props => [];
}

class StartTimer extends ActiveTrainingEvent {
  final String timerId;
  final int duration;
  final bool isCountDown;
  final VoidCallback? onComplete;

  const StartTimer(
      {required this.timerId,
      this.duration = 0,
      this.isCountDown = false,
      this.onComplete});

  @override
  List<Object?> get props => [timerId, duration, isCountDown, onComplete];
}

class TickSecondaryTimer extends ActiveTrainingEvent {
  final String timerId;
  final bool isCountDown;

  const TickSecondaryTimer({required this.timerId, this.isCountDown = false});

  @override
  List<Object?> get props => [timerId, isCountDown];
}

class PauseTimer extends ActiveTrainingEvent {
  final String? timerId;

  const PauseTimer(this.timerId);

  @override
  List<Object?> get props => [timerId];
}
