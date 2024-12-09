part of 'active_training_bloc.dart';

abstract class ActiveTrainingState extends Equatable {
  const ActiveTrainingState();

  @override
  List<Object?> get props => [];
}

class ActiveTrainingInitial extends ActiveTrainingState {}

class ActiveTrainingLoaded extends ActiveTrainingState {
  final Map<String, int> timers;
  final bool isPaused;
  final String? activeRunTimer;
  final double distance;

  const ActiveTrainingLoaded(
      {required this.timers,
      this.isPaused = false,
      this.activeRunTimer,
      this.distance = 0});

  ActiveTrainingLoaded copyWith({
    Map<String, int>? timers,
    bool? isPaused,
    String? activeRunTimer,
    double? distance,
  }) {
    return ActiveTrainingLoaded(
      timers: timers ?? this.timers,
      isPaused: isPaused ?? this.isPaused,
      activeRunTimer: activeRunTimer ?? this.activeRunTimer,
      distance: distance ?? this.distance,
    );
  }

  @override
  List<Object?> get props => [timers, isPaused, activeRunTimer, distance];
}
