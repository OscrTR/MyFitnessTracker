part of 'training_management_bloc.dart';

abstract class TrainingManagementEvent extends Equatable {
  const TrainingManagementEvent();

  @override
  List<Object> get props => [];
}

class FetchTrainingsEvent extends TrainingManagementEvent {}

class LoadInitialTrainingDataEvent extends TrainingManagementEvent {}

class LoadInitialSelectedTrainingData extends TrainingManagementEvent {
  final TrainingType trainingType;

  const LoadInitialSelectedTrainingData(this.trainingType);

  @override
  List<Object> get props => [trainingType];
}

class ClearSelectedTrainingEvent extends TrainingManagementEvent {
  const ClearSelectedTrainingEvent();
}

class AddExerciseToSelectedTrainingEvent extends TrainingManagementEvent {}

class AddRunToSelectedTrainingEvent extends TrainingManagementEvent {}

class AddMultisetToSelectedTrainingEvent extends TrainingManagementEvent {}

class CreateTrainingEvent extends TrainingManagementEvent {
  final Training training;

  const CreateTrainingEvent(this.training);

  @override
  List<Object> get props => [training];
}

class SaveSelectedTrainingEvent extends TrainingManagementEvent {}

class UpdateTrainingTypeEvent extends TrainingManagementEvent {
  final TrainingType selectedTrainingType;

  const UpdateTrainingTypeEvent(this.selectedTrainingType);

  @override
  List<Object> get props => [selectedTrainingType];
}

class UpdateSelectedTrainingWidgetsEvent extends TrainingManagementEvent {
  final List<Widget> widgetList;

  const UpdateSelectedTrainingWidgetsEvent(this.widgetList);

  @override
  List<Object> get props => [List<Widget>.from(widgetList)];
}

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
