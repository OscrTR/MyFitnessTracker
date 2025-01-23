part of 'training_management_bloc.dart';

abstract class TrainingManagementEvent extends Equatable {
  const TrainingManagementEvent();

  @override
  List<Object?> get props => [];
}

//! Trainings
class FetchTrainingsEvent extends TrainingManagementEvent {}

class UpdateTrainingEvent extends TrainingManagementEvent {}

class UnselectTrainingEvent extends TrainingManagementEvent {
  final int trainingId;

  const UnselectTrainingEvent(this.trainingId);

  @override
  List<Object> get props => [trainingId];
}

class StartTrainingEvent extends TrainingManagementEvent {
  final int trainingId;

  const StartTrainingEvent(this.trainingId);

  @override
  List<Object> get props => [trainingId];
}

class DeleteTrainingEvent extends TrainingManagementEvent {
  final int id;

  const DeleteTrainingEvent(this.id);

  @override
  List<Object> get props => [id];
}

//! Selected training
class LoadInitialSelectedTrainingData extends TrainingManagementEvent {}

class SelectTrainingEvent extends TrainingManagementEvent {
  final int id;

  const SelectTrainingEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

class ClearSelectedTrainingEvent extends TrainingManagementEvent {
  const ClearSelectedTrainingEvent();
}

class SaveSelectedTrainingEvent extends TrainingManagementEvent {}

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
class AddOrUpdateTrainingExerciseEvent extends TrainingManagementEvent {
  final TrainingExercise trainingExercise;

  const AddOrUpdateTrainingExerciseEvent(this.trainingExercise);

  @override
  List<Object> get props => [trainingExercise];
}

class RemoveTrainingExerciseEvent extends TrainingManagementEvent {
  final String trainingExerciseKey;

  const RemoveTrainingExerciseEvent(this.trainingExerciseKey);

  @override
  List<Object> get props => [trainingExerciseKey];
}

//! Multiset
class AddOrUpdateMultisetEvent extends TrainingManagementEvent {
  final Multiset multiset;

  const AddOrUpdateMultisetEvent(this.multiset);

  @override
  List<Object> get props => [multiset];
}

class AddOrUpdateMultisetExerciseEvent extends TrainingManagementEvent {
  final String multisetKey;
  final TrainingExercise trainingExercise;

  const AddOrUpdateMultisetExerciseEvent(
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
