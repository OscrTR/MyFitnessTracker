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
  final DateTime startDate;
  final DateTime endDate;

  const TrainingHistoryLoaded({
    required this.historyEntries,
    required this.historyTrainings,
    required this.startDate,
    required this.endDate,
  });

  TrainingHistoryLoaded copyWith({
    List<HistoryEntry>? historyEntries,
    List<HistoryTraining>? historyTrainings,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return TrainingHistoryLoaded(
      historyEntries: historyEntries ?? this.historyEntries,
      historyTrainings: historyTrainings ?? this.historyTrainings,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  @override
  List<Object> get props => [
        historyEntries,
        historyTrainings,
        startDate,
        endDate,
      ];
}

class TrainingHistoryFailure extends TrainingHistoryState {}
