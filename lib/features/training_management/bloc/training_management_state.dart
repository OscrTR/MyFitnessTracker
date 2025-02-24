part of 'training_management_bloc.dart';

abstract class TrainingManagementState extends Equatable {
  const TrainingManagementState();

  @override
  List<Object?> get props => [];
}

class TrainingManagementInitial extends TrainingManagementState {}

class TrainingManagementLoaded extends TrainingManagementState {
  final List<Training> trainings;
  final Training selectedTraining;
  final Map<int, int?> daysSinceLastTraining;

  static const emptyTraining = Training(
    name: '',
    trainingType: TrainingType.workout,
    objectives: '',
    trainingDays: [],
    exercises: [],
    multisets: [],
    baseExercises: [],
  );

  const TrainingManagementLoaded({
    this.trainings = const [],
    this.selectedTraining = const Training(
      name: '',
      trainingType: TrainingType.workout,
      objectives: '',
      trainingDays: [],
      exercises: [],
      multisets: [],
      baseExercises: [],
    ),
    this.daysSinceLastTraining = const {},
  });

  TrainingManagementLoaded copyWith({
    List<Training>? trainings,
    Training? selectedTraining,
    bool? isSelected,
    String? name,
    TrainingType? type,
    List<Exercise>? exercises,
    List<Multiset>? multisets,
    Map<int, int?>? daysSinceLastTraining,
    bool resetSelectedTraining = false,
  }) {
    return TrainingManagementLoaded(
      trainings: trainings ?? this.trainings,
      daysSinceLastTraining:
          daysSinceLastTraining ?? this.daysSinceLastTraining,
      selectedTraining: resetSelectedTraining
          ? Training(
              name: '',
              trainingType: TrainingType.workout,
              objectives: '',
              trainingDays: [],
              exercises: [],
              multisets: [],
              baseExercises: [],
            )
          : (selectedTraining ?? this.selectedTraining).copyWith(
              name: selectedTraining?.name ?? this.selectedTraining.name,
              trainingType: selectedTraining?.trainingType ??
                  this.selectedTraining.trainingType,
              exercises: selectedTraining?.exercises ??
                  this
                      .selectedTraining
                      .exercises
                      .map((e) => e.copyWith())
                      .toList(),
              multisets: selectedTraining?.multisets ??
                  this
                      .selectedTraining
                      .multisets
                      .map((e) => e.copyWith())
                      .toList(),
            ),
    );
  }

  @override
  List<Object?> get props => [
        trainings,
        selectedTraining,
        daysSinceLastTraining,
      ];
}
