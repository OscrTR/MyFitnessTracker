part of 'training_history_bloc.dart';

abstract class TrainingHistoryEvent extends Equatable {
  const TrainingHistoryEvent();

  @override
  List<Object?> get props => [];
}

class FetchHistoryEntriesEvent extends TrainingHistoryEvent {
  final bool isWeekSelected;

  const FetchHistoryEntriesEvent([this.isWeekSelected = true]);

  @override
  List<Object?> get props => [isWeekSelected];
}

class CreateOrUpdateHistoryEntry extends TrainingHistoryEvent {
  final HistoryEntry? historyEntry;
  final TimerState? timerState;
  final int reps;
  final int weight;

  const CreateOrUpdateHistoryEntry({
    required this.historyEntry,
    required this.timerState,
    this.reps = 0,
    this.weight = 0,
  });

  @override
  List<Object?> get props => [
        historyEntry,
        timerState,
        reps,
        weight,
      ];
}

class CreateOrUpdateHistoryAfterwardsEntry extends TrainingHistoryEvent {
  final HistoryEntry historyEntry;

  const CreateOrUpdateHistoryAfterwardsEntry({required this.historyEntry});

  @override
  List<Object> get props => [historyEntry];
}

class DeleteHistoryEntryEvent extends TrainingHistoryEvent {
  final int id;

  const DeleteHistoryEntryEvent({required this.id});

  @override
  List<Object> get props => [id];
}

class DeleteHistoryTrainingEvent extends TrainingHistoryEvent {
  final HistoryTraining historyTraining;

  const DeleteHistoryTrainingEvent({required this.historyTraining});

  @override
  List<Object> get props => [historyTraining];
}

class SetNewDateHistoryDateEvent extends TrainingHistoryEvent {
  final DateTime startDate;
  final DateTime? endDate;

  const SetNewDateHistoryDateEvent({required this.startDate, this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}

class SelectHistoryTrainingEntryEvent extends TrainingHistoryEvent {
  final HistoryTraining historyTraining;

  const SelectHistoryTrainingEntryEvent(this.historyTraining);

  @override
  List<Object> get props => [historyTraining];
}

class SelectTrainingTypeEvent extends TrainingHistoryEvent {
  final TrainingType trainingType;
  final bool isSelected;

  const SelectTrainingTypeEvent(this.trainingType, this.isSelected);

  @override
  List<Object> get props => [trainingType, isSelected];
}

class SelectExercisesEvent extends TrainingHistoryEvent {
  final bool isExercisesSelected;

  const SelectExercisesEvent(this.isExercisesSelected);

  @override
  List<Object> get props => [isExercisesSelected];
}

class SelectBaseExerciseEvent extends TrainingHistoryEvent {
  final BaseExercise? baseExercise;

  const SelectBaseExerciseEvent(this.baseExercise);

  @override
  List<Object?> get props => [baseExercise];
}

class SelectTrainingEvent extends TrainingHistoryEvent {
  final Training? training;

  const SelectTrainingEvent(this.training);

  @override
  List<Object?> get props => [training];
}
