part of 'active_training_bloc.dart';

abstract class ActiveTrainingEvent extends Equatable {
  const ActiveTrainingEvent();

  @override
  List<Object?> get props => [];
}

class StartActiveTraining extends ActiveTrainingEvent {
  final int trainingId;

  const StartActiveTraining({required this.trainingId});

  @override
  List<Object> get props => [trainingId];
}

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
  final List<TimerState>? updatedTimersStateList;

  const StartTimer({
    required this.timerId,
    this.updatedTimersStateList,
  });

  @override
  List<Object?> get props => [timerId, updatedTimersStateList];
}

class TickTimer extends ActiveTrainingEvent {
  final String timerId;
  final bool isCountDown;
  final double totalDistance;

  const TickTimer({
    required this.timerId,
    this.isCountDown = false,
    this.totalDistance = 0,
  });

  @override
  List<Object?> get props => [timerId, isCountDown, totalDistance];
}

class PauseTimer extends ActiveTrainingEvent {}

class ClearTimers extends ActiveTrainingEvent {}

class UpdateDistance extends ActiveTrainingEvent {
  final String timerId;
  final double distance;

  const UpdateDistance({required this.timerId, required this.distance});

  @override
  List<Object?> get props => [timerId, distance];
}

class UpdateNextKmMarker extends ActiveTrainingEvent {
  final String timerId;
  final int nextKmMarker;

  const UpdateNextKmMarker({required this.timerId, required this.nextKmMarker});

  @override
  List<Object?> get props => [timerId, nextKmMarker];
}

class UpdateTimer extends ActiveTrainingEvent {
  final String timerId;
  final double runDistance;

  const UpdateTimer({
    required this.timerId,
    required this.runDistance,
  });

  @override
  List<Object?> get props => [timerId, runDistance];
}

class UpdateDataFromForeground extends ActiveTrainingEvent {
  final String? timerId;
  final Location? locationData;
  final double? totalDistance;

  const UpdateDataFromForeground({
    required this.timerId,
    required this.locationData,
    required this.totalDistance,
  });

  @override
  List<Object?> get props => [
        timerId,
        locationData,
        totalDistance,
      ];
}
