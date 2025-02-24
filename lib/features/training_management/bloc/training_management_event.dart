part of 'training_management_bloc.dart';

abstract class TrainingManagementEvent extends Equatable {
  const TrainingManagementEvent();

  @override
  List<Object?> get props => [];
}

//! Trainings
class FetchTrainingsEvent extends TrainingManagementEvent {
  final bool hasToResetSelectedTraining;

  const FetchTrainingsEvent([this.hasToResetSelectedTraining = false]);

  @override
  List<Object?> get props => [hasToResetSelectedTraining];
}

class LoadDaysSinceTrainingEvent extends TrainingManagementEvent {}

class DeleteTrainingEvent extends TrainingManagementEvent {
  final int id;

  const DeleteTrainingEvent(this.id);

  @override
  List<Object> get props => [id];
}

class GetTrainingEvent extends TrainingManagementEvent {
  final int? id;

  const GetTrainingEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

class ClearSelectedTrainingEvent extends TrainingManagementEvent {}

class CreateOrUpdateTrainingEvent extends TrainingManagementEvent {
  final Training training;

  const CreateOrUpdateTrainingEvent(this.training);

  @override
  List<Object?> get props => [training];
}

class CreateOrUpdateSelectedTrainingEvent extends TrainingManagementEvent {
  final Training training;

  const CreateOrUpdateSelectedTrainingEvent(this.training);

  @override
  List<Object?> get props => [training];
}

class UpdateSelectedTrainingProperty extends TrainingManagementEvent {
  final int? id;
  final String? name;
  final TrainingType? type;
  final bool? isSelected;
  final List<Exercise>? exercises;
  final String? objectives;
  final List<Multiset>? multisets;
  final List<TrainingDay>? trainingDays;

  const UpdateSelectedTrainingProperty({
    this.id,
    this.name,
    this.type,
    this.isSelected,
    this.exercises,
    this.objectives,
    this.multisets,
    this.trainingDays,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        isSelected,
        exercises,
        multisets,
        objectives,
        trainingDays
      ];
}

//! Training exercises
class CreateOrUpdateExerciseEvent extends TrainingManagementEvent {
  final Exercise exercise;
  final BaseExercise? baseExercise;

  const CreateOrUpdateExerciseEvent(
      {required this.exercise, required this.baseExercise});

  @override
  List<Object?> get props => [exercise, baseExercise];
}

class RemoveExerciseEvent extends TrainingManagementEvent {
  final Exercise exercise;

  const RemoveExerciseEvent(this.exercise);

  @override
  List<Object> get props => [exercise];
}

//! Multiset
class CreateOrUpdateMultisetEvent extends TrainingManagementEvent {
  final Multiset multiset;
  final Training training;

  const CreateOrUpdateMultisetEvent(
      {required this.multiset, required this.training});

  @override
  List<Object> get props => [multiset, training];
}

class RemoveMultisetEvent extends TrainingManagementEvent {
  final Multiset multiset;

  const RemoveMultisetEvent({required this.multiset});

  @override
  List<Object> get props => [multiset];
}

class CreateOrUpdateMultisetExerciseEvent extends TrainingManagementEvent {
  final String multisetKey;
  final Exercise exercise;
  final BaseExercise? baseExercise;

  const CreateOrUpdateMultisetExerciseEvent({
    required this.multisetKey,
    required this.exercise,
    required this.baseExercise,
  });

  @override
  List<Object?> get props => [multisetKey, exercise, baseExercise];
}

class RemoveMultisetExerciseEvent extends TrainingManagementEvent {
  final Exercise exercise;

  const RemoveMultisetExerciseEvent({required this.exercise});

  @override
  List<Object> get props => [exercise];
}
