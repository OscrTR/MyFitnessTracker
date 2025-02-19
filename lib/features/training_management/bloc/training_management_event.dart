part of 'training_management_bloc.dart';

abstract class TrainingManagementEvent extends Equatable {
  const TrainingManagementEvent();

  @override
  List<Object?> get props => [];
}

class StartTrainingEvent extends TrainingManagementEvent {
  final int trainingId;

  const StartTrainingEvent(this.trainingId);

  @override
  List<Object> get props => [trainingId];
}

//! Trainings
class FetchTrainingsEvent extends TrainingManagementEvent {}

class LoadDaysSinceTrainingEvent extends TrainingManagementEvent {}

class DeleteTrainingEvent extends TrainingManagementEvent {
  final Training training;

  const DeleteTrainingEvent(this.training);

  @override
  List<Object> get props => [training];
}

class GetTrainingEvent extends TrainingManagementEvent {
  final int id;

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
  final List<TrainingExercise>? trainingExercises;
  final String? objectives;
  final List<Multiset>? multisets;
  final List<WeekDay>? trainingDays;

  const UpdateSelectedTrainingProperty({
    this.id,
    this.name,
    this.type,
    this.isSelected,
    this.trainingExercises,
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
        trainingExercises,
        multisets,
        objectives,
        trainingDays
      ];
}

//! Training exercises
class CreateOrUpdateTrainingExerciseEvent extends TrainingManagementEvent {
  final TrainingExercise trainingExercise;
  final Training training;

  const CreateOrUpdateTrainingExerciseEvent(
      {required this.trainingExercise, required this.training});

  @override
  List<Object> get props => [trainingExercise, training];
}

class RemoveTrainingExerciseEvent extends TrainingManagementEvent {
  final String trainingExerciseKey;

  const RemoveTrainingExerciseEvent(this.trainingExerciseKey);

  @override
  List<Object> get props => [trainingExerciseKey];
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

class CreateOrUpdateMultisetExerciseEvent extends TrainingManagementEvent {
  final String multisetKey;
  final TrainingExercise trainingExercise;

  const CreateOrUpdateMultisetExerciseEvent(
      {required this.multisetKey, required this.trainingExercise});

  @override
  List<Object> get props => [multisetKey, trainingExercise];
}

class RemoveMultisetExerciseEvent extends TrainingManagementEvent {
  final String multisetKey;
  final String exerciseKey;

  const RemoveMultisetExerciseEvent(
      {required this.multisetKey, required this.exerciseKey});

  @override
  List<Object> get props => [multisetKey, exerciseKey];
}
