part of 'training_management_bloc.dart';

abstract class TrainingManagementEvent extends Equatable {
  const TrainingManagementEvent();

  @override
  List<Object?> get props => [];
}

//! Trainings
class FetchTrainingsEvent extends TrainingManagementEvent {}

class GetTrainingEvent extends TrainingManagementEvent {
  final int trainingId;

  const GetTrainingEvent(this.trainingId);

  @override
  List<Object> get props => [trainingId];
}

class UpdateTrainingEvent extends TrainingManagementEvent {
  final Training training;

  const UpdateTrainingEvent(this.training);

  @override
  List<Object> get props => [training];
}

class DeleteTrainingEvent extends TrainingManagementEvent {
  final int id;

  const DeleteTrainingEvent(this.id);

  @override
  List<Object> get props => [id];
}

//! Selected training
class LoadInitialSelectedTrainingData extends TrainingManagementEvent {
  final TrainingType trainingType;

  const LoadInitialSelectedTrainingData(this.trainingType);

  @override
  List<Object> get props => [trainingType];
}

class ClearSelectedTrainingEvent extends TrainingManagementEvent {
  const ClearSelectedTrainingEvent();
}

class SaveSelectedTrainingEvent extends TrainingManagementEvent {}

class InitializeSelectedTrainingEvent extends TrainingManagementEvent {
  final TrainingType type;

  const InitializeSelectedTrainingEvent({required this.type});
  @override
  List<Object> get props => [type];
}

class UpdateSelectedTrainingProperty extends TrainingManagementEvent {
  final int? id;
  final String? name;
  final TrainingType? type;
  final bool? isSelected;
  final List<TrainingExercise>? trainingExercises;
  final List<Multiset>? multisets;

  const UpdateSelectedTrainingProperty({
    this.id,
    this.name,
    this.type,
    this.isSelected,
    this.trainingExercises,
    this.multisets,
  });

  @override
  List<Object?> get props =>
      [id, name, type, isSelected, trainingExercises, multisets];
}

class AddExerciseToSelectedTrainingEvent extends TrainingManagementEvent {
  final TrainingExercise trainingExercise;

  const AddExerciseToSelectedTrainingEvent(this.trainingExercise);

  @override
  List<Object> get props => [trainingExercise];
}

class RemoveExerciseFromSelectedTrainingEvent extends TrainingManagementEvent {
  final String trainingExerciseKey;

  const RemoveExerciseFromSelectedTrainingEvent(this.trainingExerciseKey);

  @override
  List<Object> get props => [trainingExerciseKey];
}

//! Multiset
class AddMultisetToSelectedTrainingEvent extends TrainingManagementEvent {
  final Multiset multiset;

  const AddMultisetToSelectedTrainingEvent(this.multiset);

  @override
  List<Object> get props => [multiset];
}

class CreateTrainingEvent extends TrainingManagementEvent {
  final Training training;

  const CreateTrainingEvent(this.training);

  @override
  List<Object> get props => [training];
}
