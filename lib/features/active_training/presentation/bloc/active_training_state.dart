part of 'active_training_bloc.dart';

abstract class ActiveTrainingState extends Equatable {
  const ActiveTrainingState();

  @override
  List<Object?> get props => [];
}

class ActiveTrainingInitial extends ActiveTrainingState {}

class ActiveTrainingLoaded extends ActiveTrainingState {
  final bool isPaused;
  final String? activeRunTimer;
  final List<TimerState> timersStateList;

  const ActiveTrainingLoaded({
    this.isPaused = false,
    this.activeRunTimer,
    required this.timersStateList,
  });

  ActiveTrainingLoaded copyWith({
    bool? isPaused,
    String? activeRunTimer,
    List<TimerState>? timersStateList,
  }) {
    return ActiveTrainingLoaded(
      isPaused: isPaused ?? this.isPaused,
      activeRunTimer: activeRunTimer ?? this.activeRunTimer,
      timersStateList: timersStateList != null
          ? List.unmodifiable(
              timersStateList..sort((a, b) => a.timerId.compareTo(b.timerId)),
            )
          : this.timersStateList,
    );
  }

  @override
  List<Object?> get props => [isPaused, activeRunTimer, timersStateList];
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

  const TimerState({
    required this.timerId,
    required this.isActive,
    required this.isStarted,
    required this.isCountDown,
    required this.isRunTimer,
    required this.timerValue,
    required this.isAutostart,
    this.countDownValue = 0,
    this.targetDistance = 0,
    this.targetDuration = 0,
    this.targetPace = 0,
    this.distance = 0,
    this.pace = 0,
  });

  TimerState copyWith({
    bool? isActive,
    bool? isStarted,
    int? timerValue,
    double? distance,
    double? pace,
  }) {
    return TimerState(
      timerId: timerId,
      isActive: isActive ?? this.isActive,
      isStarted: isStarted ?? this.isStarted,
      isCountDown: isCountDown,
      isRunTimer: isRunTimer,
      isAutostart: isAutostart,
      timerValue: timerValue ?? this.timerValue,
      countDownValue: countDownValue,
      targetDistance: targetDistance,
      targetDuration: targetDuration,
      targetPace: targetPace,
      distance: distance ?? this.distance,
      pace: pace ?? this.pace,
    );
  }

  @override
  List<Object?> get props => [
        timerId,
        isActive,
        isStarted,
        isCountDown,
        isRunTimer,
        isAutostart,
        timerValue,
        countDownValue,
        targetDistance,
        targetDuration,
        targetPace,
        distance,
        pace
      ];
}
