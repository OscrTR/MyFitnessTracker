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

  const ActiveTrainingLoaded(
    this.timers,
    this.isPaused,
    this.activeRunTimer,
  );

  ActiveTrainingLoaded copyWith({
    Map<String, int>? timers,
    bool? isPaused,
    String? activeRunTimer,
  }) {
    return ActiveTrainingLoaded(
      timers ?? this.timers,
      isPaused ?? this.isPaused,
      activeRunTimer ?? this.activeRunTimer,
    );
  }

  @override
  List<Object?> get props => [timers, isPaused, activeRunTimer];
}
