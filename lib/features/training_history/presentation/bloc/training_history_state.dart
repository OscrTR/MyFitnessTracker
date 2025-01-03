part of 'training_history_bloc.dart';

abstract class TrainingHistoryState extends Equatable {
  const TrainingHistoryState();

  @override
  List<Object> get props => [];
}

class TrainingHistoryInitial extends TrainingHistoryState {}

class TrainingHistoryLoading extends TrainingHistoryState {}

class TrainingHistoryLoaded extends TrainingHistoryState {
  final List<HistoryEntry> historyEntries;

  const TrainingHistoryLoaded({required this.historyEntries});

  TrainingHistoryLoaded copyWith({List<HistoryEntry>? historyEntries}) {
    return TrainingHistoryLoaded(
        historyEntries: historyEntries ?? this.historyEntries);
  }

  @override
  List<Object> get props => [historyEntries];
}

class TrainingHistoryFailure extends TrainingHistoryState {}
