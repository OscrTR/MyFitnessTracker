part of 'training_management_bloc.dart';

abstract class TrainingManagementState extends Equatable {
  const TrainingManagementState();

  @override
  List<Object?> get props => [];
}

class TrainingManagementInitial extends TrainingManagementState {}

class TrainingManagementLoaded extends TrainingManagementState {
  final List<Training> trainings;
  final Training? selectedTraining;
  final Training? activeTraining;
  final Map<int, int?> daysSinceLastTraining;

  const TrainingManagementLoaded({
    this.trainings = const [],
    this.activeTraining,
    this.selectedTraining,
    this.daysSinceLastTraining = const {},
  });

  TrainingManagementLoaded copyWith({
    List<Training>? trainings,
    Training? selectedTraining,
    Training? activeTraining,
    bool? isSelected,
    String? name,
    TrainingType? type,
    List<TrainingExercise>? trainingExercises,
    List<Multiset>? multisets,
    Map<int, int?>? daysSinceLastTraining,
    bool resetSelectedTraining = false,
  }) {
    return TrainingManagementLoaded(
      trainings: trainings ?? this.trainings,
      daysSinceLastTraining:
          daysSinceLastTraining ?? this.daysSinceLastTraining,
      activeTraining: activeTraining ?? this.activeTraining,
      selectedTraining: resetSelectedTraining
          ? null
          : (selectedTraining ?? this.selectedTraining)?.copyWith(
              name: selectedTraining?.name ?? this.selectedTraining?.name,
              type: selectedTraining?.type ?? this.selectedTraining?.type,
              trainingExercises: selectedTraining?.trainingExercises ??
                  this
                      .selectedTraining
                      ?.trainingExercises
                      .map((e) => e.copyWith())
                      .toList(),
              multisets: selectedTraining?.multisets ??
                  this
                      .selectedTraining
                      ?.multisets
                      .map((e) => e.copyWith())
                      .toList(),
            ),
    );
  }

  bool get hasExercisesOrMultisets {
    if (selectedTraining == null) {
      return false;
    }
    // Check if trainingExercises is not empty
    if (selectedTraining!.trainingExercises.isNotEmpty) {
      return true;
    }
    // Check if at least one multiset has non-empty trainingExercises
    for (final multiset in selectedTraining!.multisets) {
      if (multiset.trainingExercises.isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  @override
  List<Object?> get props => [
        trainings,
        selectedTraining,
        activeTraining,
        daysSinceLastTraining,
      ];
}
