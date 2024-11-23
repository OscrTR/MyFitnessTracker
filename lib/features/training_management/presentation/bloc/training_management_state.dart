part of 'training_management_bloc.dart';

abstract class TrainingManagementState extends Equatable {
  const TrainingManagementState();

  @override
  List<Object?> get props => [];
}

class TrainingManagementInitial extends TrainingManagementState {}

class TrainingManagementLoading extends TrainingManagementState {}

class TrainingManagementLoaded extends TrainingManagementState {
  final List<Training> trainings;
  final Training? selectedTraining;

  const TrainingManagementLoaded({
    this.trainings = const [],
    this.selectedTraining = const Training(
        name: 'Unnamed training',
        type: TrainingType.workout,
        isSelected: true,
        trainingExercises: [],
        multisets: []),
  });

  TrainingManagementLoaded copyWith({
    List<Training>? trainings,
    Training? selectedTraining,
    bool? isSelected,
    String? name,
    TrainingType? type,
    List<TrainingExercise>? trainingExercises,
    List<Multiset>? multisets,
    bool resetSelectedTraining = false,
  }) {
    return TrainingManagementLoaded(
      trainings: trainings ?? this.trainings,
      selectedTraining: resetSelectedTraining
          ? const Training(
              name: 'Unnamed training',
              type: TrainingType.workout,
              isSelected: true,
              trainingExercises: [],
              multisets: [],
            )
          : (selectedTraining ?? this.selectedTraining)?.copyWith(
              name: selectedTraining?.name ?? this.selectedTraining?.name,
              type: selectedTraining?.type ?? this.selectedTraining?.type,
              isSelected: selectedTraining?.isSelected ??
                  this.selectedTraining?.isSelected,
              trainingExercises: selectedTraining?.trainingExercises ??
                  this.selectedTraining?.trainingExercises,
              multisets: selectedTraining?.multisets ??
                  this.selectedTraining?.multisets,
            ),
    );
  }

  TrainingManagementLoaded clearSelectedTraining() {
    return copyWith(
      selectedTraining: null,
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
      if (multiset.trainingExercises!.isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  @override
  List<Object?> get props => [
        trainings,
        selectedTraining,
      ];
}

class TrainingManagementFailure extends TrainingManagementState {
  final String message;

  const TrainingManagementFailure(this.message);

  @override
  List<Object> get props => [message];
}
