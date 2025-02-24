part of 'active_training_bloc.dart';

abstract class ActiveTrainingState extends Equatable {
  const ActiveTrainingState();

  @override
  List<Object?> get props => [];
}

class ActiveTrainingInitial extends ActiveTrainingState {}

class ActiveTrainingLoaded extends ActiveTrainingState {
  final Training? activeTraining;
  final int? activeTrainingMostRecentVersionId;
  final String? lastStartedTimerId;

  final List<TimerState> timersStateList;

  const ActiveTrainingLoaded({
    this.lastStartedTimerId,
    this.activeTraining,
    this.activeTrainingMostRecentVersionId,
    this.timersStateList = const [],
  });

  ActiveTrainingLoaded copyWith({
    Training? activeTraining,
    int? activeTrainingMostRecentVersionId,
    String? lastStartedTimerId,
    List<TimerState>? timersStateList,
  }) {
    return ActiveTrainingLoaded(
      activeTraining: activeTraining ?? this.activeTraining,
      activeTrainingMostRecentVersionId: activeTrainingMostRecentVersionId ??
          this.activeTrainingMostRecentVersionId,
      lastStartedTimerId: lastStartedTimerId ?? this.lastStartedTimerId,
      timersStateList: timersStateList != null
          ? List.unmodifiable(
              timersStateList..sort((a, b) => a.timerId.compareTo(b.timerId)),
            )
          : this.timersStateList,
    );
  }

  @override
  List<Object?> get props => [
        activeTraining,
        activeTrainingMostRecentVersionId,
        lastStartedTimerId,
        timersStateList
      ];
}

class TimerState extends Equatable {
  final String timerId;
  final bool isActive;
  final bool isStarted;
  final bool isRunTimer;
  final bool isCountDown;
  final bool isAutostart;
  final int timerValue;
  final int countDownValue;
  final int targetDistance;
  final int targetDuration;
  final int targetPace;
  final double distance;
  final double pace;
  final int nextKmMarker;
  final GlobalKey exerciseGlobalKey;
  final int trainingId;
  final int exerciseId;
  final int setNumber;
  final int? intervalNumber;
  final int trainingVersionId;

  const TimerState({
    required this.timerId,
    required this.isActive,
    required this.isStarted,
    required this.isCountDown,
    required this.isRunTimer,
    required this.timerValue,
    required this.isAutostart,
    required this.exerciseGlobalKey,
    required this.trainingId,
    required this.exerciseId,
    required this.setNumber,
    required this.intervalNumber,
    required this.trainingVersionId,
    this.countDownValue = 0,
    this.targetDistance = 0,
    this.targetDuration = 0,
    this.targetPace = 0,
    this.distance = 0,
    this.pace = 0,
    this.nextKmMarker = 1,
  });

  TimerState copyWith({
    String? timerId,
    bool? isActive,
    bool? isStarted,
    bool? isRunTimer,
    bool? isCountDown,
    bool? isAutostart,
    int? timerValue,
    int? countDownValue,
    int? targetDistance,
    int? targetDuration,
    int? targetPace,
    double? distance,
    double? pace,
    int? nextKmMarker,
    GlobalKey? exerciseGlobalKey,
    int? trainingId,
    int? exerciseId,
    int? setNumber,
    int? intervalNumber,
    int? trainingVersionId,
  }) {
    return TimerState(
      timerId: timerId ?? this.timerId,
      isActive: isActive ?? this.isActive,
      isStarted: isStarted ?? this.isStarted,
      isRunTimer: isRunTimer ?? this.isRunTimer,
      isCountDown: isCountDown ?? this.isCountDown,
      isAutostart: isAutostart ?? this.isAutostart,
      timerValue: timerValue ?? this.timerValue,
      countDownValue: countDownValue ?? this.countDownValue,
      targetDistance: targetDistance ?? this.targetDistance,
      targetDuration: targetDuration ?? this.targetDuration,
      targetPace: targetPace ?? this.targetPace,
      distance: distance ?? this.distance,
      pace: pace ?? this.pace,
      nextKmMarker: nextKmMarker ?? this.nextKmMarker,
      exerciseGlobalKey: exerciseGlobalKey ?? this.exerciseGlobalKey,
      trainingId: trainingId ?? this.trainingId,
      exerciseId: exerciseId ?? this.exerciseId,
      setNumber: setNumber ?? this.setNumber,
      intervalNumber: intervalNumber ?? this.intervalNumber,
      trainingVersionId: trainingVersionId ?? this.trainingVersionId,
    );
  }

  @override
  List<Object?> get props {
    return [
      timerId,
      isActive,
      isStarted,
      isRunTimer,
      isCountDown,
      isAutostart,
      timerValue,
      countDownValue,
      targetDistance,
      targetDuration,
      targetPace,
      distance,
      pace,
      nextKmMarker,
      exerciseGlobalKey,
      trainingId,
      exerciseId,
      setNumber,
      intervalNumber,
      trainingVersionId,
    ];
  }
}
