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
  final int? activeTrainingMostRecentVersionId;
  final Map<int, int?> daysSinceLastTraining;

  const TrainingManagementLoaded({
    this.trainings = const [],
    this.activeTraining,
    this.selectedTraining,
    this.activeTrainingMostRecentVersionId,
    this.daysSinceLastTraining = const {},
  });

  TrainingManagementLoaded copyWith({
    List<Training>? trainings,
    Training? selectedTraining,
    Training? activeTraining,
    bool? isSelected,
    String? name,
    TrainingType? type,
    List<Exercise>? exercises,
    List<Multiset>? multisets,
    int? activeTrainingMostRecentVersionId,
    Map<int, int?>? daysSinceLastTraining,
    bool resetSelectedTraining = false,
  }) {
    return TrainingManagementLoaded(
      trainings: trainings ?? this.trainings,
      daysSinceLastTraining:
          daysSinceLastTraining ?? this.daysSinceLastTraining,
      activeTraining: activeTraining ?? this.activeTraining,
      activeTrainingMostRecentVersionId: activeTrainingMostRecentVersionId ??
          this.activeTrainingMostRecentVersionId,
      selectedTraining: resetSelectedTraining
          ? null
          : (selectedTraining ?? this.selectedTraining)?.copyWith(
              name: selectedTraining?.name ?? this.selectedTraining?.name,
              trainingType: selectedTraining?.trainingType ??
                  this.selectedTraining?.trainingType,
              exercises: selectedTraining?.exercises ??
                  this
                      .selectedTraining
                      ?.exercises
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

  @override
  List<Object?> get props => [
        trainings,
        selectedTraining,
        activeTraining,
        daysSinceLastTraining,
        activeTrainingMostRecentVersionId
      ];
}
