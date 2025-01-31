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
