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
  final List<HistoryTraining> historyTrainings;

  const TrainingHistoryLoaded({
    required this.historyEntries,
    required this.historyTrainings,
  });

  TrainingHistoryLoaded copyWith({
    List<HistoryEntry>? historyEntries,
    List<HistoryTraining>? historyTrainings,
  }) {
    return TrainingHistoryLoaded(
      historyEntries: historyEntries ?? this.historyEntries,
      historyTrainings: historyTrainings ?? this.historyTrainings,
    );
  }

  @override
  List<Object> get props => [historyEntries, historyTrainings];
}

class TrainingHistoryFailure extends TrainingHistoryState {}
