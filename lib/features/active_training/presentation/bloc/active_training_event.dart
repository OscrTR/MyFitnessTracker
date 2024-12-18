part of 'active_training_bloc.dart';

abstract class ActiveTrainingEvent extends Equatable {
  const ActiveTrainingEvent();

  @override
  List<Object?> get props => [];
}

class LoadDefaultActiveTraining extends ActiveTrainingEvent {}

class GenerateActiveTrainingTimers extends ActiveTrainingEvent {
  final List<Map<String, Object>> exercisesAndMultisetsList;

  const GenerateActiveTrainingTimers({required this.exercisesAndMultisetsList});

  @override
  List<Object> get props => [exercisesAndMultisetsList];
}

class CreateTimer extends ActiveTrainingEvent {
  final TimerState timerState;

  const CreateTimer({required this.timerState});

  @override
  List<Object?> get props => [timerState];
}

class StartTimer extends ActiveTrainingEvent {
  final String timerId;
  final Completer<String>? completer;

  const StartTimer({
    required this.timerId,
    this.completer,
  });

  @override
  List<Object?> get props => [
        timerId,
        completer,
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

class ResetTimer extends ActiveTrainingEvent {
  final String timerId;

  const ResetTimer({required this.timerId});
  @override
  List<Object?> get props => [timerId];
}

class UpdateDistance extends ActiveTrainingEvent {
  final String timerId;
  final double distance;

  const UpdateDistance({required this.timerId, required this.distance});

  @override
  List<Object?> get props => [timerId, distance];
}
