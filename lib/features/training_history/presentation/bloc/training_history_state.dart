part of 'training_history_bloc.dart';

abstract class TrainingHistoryState extends Equatable {
  const TrainingHistoryState();

  @override
  List<Object?> get props => [];
}

class TrainingHistoryInitial extends TrainingHistoryState {}

class TrainingHistoryLoading extends TrainingHistoryState {}

class TrainingHistoryLoaded extends TrainingHistoryState {
  final List<HistoryEntry> historyEntries;
  final List<HistoryTraining> historyTrainings;
  final DateTime startDate;
  final DateTime endDate;
  final HistoryTraining? selectedTrainingEntry;

  const TrainingHistoryLoaded({
    required this.historyEntries,
    required this.historyTrainings,
    required this.startDate,
    required this.endDate,
    this.selectedTrainingEntry,
  });

  TrainingHistoryLoaded copyWith({
    List<HistoryEntry>? historyEntries,
    List<HistoryTraining>? historyTrainings,
    DateTime? startDate,
    DateTime? endDate,
    HistoryTraining? selectedTrainingEntry,
  }) {
    return TrainingHistoryLoaded(
      historyEntries: historyEntries ?? this.historyEntries,
      historyTrainings: historyTrainings ?? this.historyTrainings,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      selectedTrainingEntry:
          selectedTrainingEntry ?? this.selectedTrainingEntry,
    );
  }

  @override
  List<Object?> get props => [
        historyEntries,
        historyTrainings,
        startDate,
        endDate,
        selectedTrainingEntry,
      ];
}

class TrainingHistoryFailure extends TrainingHistoryState {}
