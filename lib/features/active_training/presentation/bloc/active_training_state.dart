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

  const ActiveTrainingLoaded(this.timers, this.isPaused);

  ActiveTrainingLoaded copyWith({
    Map<String, int>? timers,
    bool? isPaused,
  }) {
    return ActiveTrainingLoaded(
      timers ?? this.timers,
      isPaused ?? this.isPaused,
    );
  }

  @override
  List<Object?> get props => [timers, isPaused];
}
