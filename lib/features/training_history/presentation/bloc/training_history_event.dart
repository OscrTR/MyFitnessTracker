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

class SetDefaultHistoryDateEvent extends TrainingHistoryEvent {}

class SetNewDateHistoryDateEvent extends TrainingHistoryEvent {
  final DateTime startDate;
  final bool isWeekSelected;

  const SetNewDateHistoryDateEvent(
      {required this.startDate, required this.isWeekSelected});

  @override
  List<Object> get props => [startDate, isWeekSelected];
}

class SelectHistoryTrainingEntryEvent extends TrainingHistoryEvent {
  final HistoryTraining historyTraining;

  const SelectHistoryTrainingEntryEvent(this.historyTraining);

  @override
  List<Object> get props => [historyTraining];
}
