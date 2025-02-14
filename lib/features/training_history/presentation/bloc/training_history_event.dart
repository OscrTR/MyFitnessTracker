part of 'training_history_bloc.dart';

abstract class TrainingHistoryEvent extends Equatable {
  const TrainingHistoryEvent();

  @override
  List<Object> get props => [];
}

class FetchHistoryEntriesEvent extends TrainingHistoryEvent {}

class FetchHistoryTrainingsEvent extends TrainingHistoryEvent {}

class CreateOrUpdateHistoryEntry extends TrainingHistoryEvent {
  final HistoryEntry historyEntry;

  const CreateOrUpdateHistoryEntry({required this.historyEntry});

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

class SetDefaultHistoryDateEvent extends TrainingHistoryEvent {
  final bool isWeekSelected;

  const SetDefaultHistoryDateEvent(this.isWeekSelected);

  @override
  List<Object> get props => [isWeekSelected];
}

class SetNewDateHistoryDateEvent extends TrainingHistoryEvent {
  final DateTime startDate;

  const SetNewDateHistoryDateEvent({required this.startDate});

  @override
  List<Object> get props => [startDate];
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
