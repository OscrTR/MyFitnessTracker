part of 'exercise_management_bloc.dart';

abstract class ExerciseManagementEvent extends Equatable {
  const ExerciseManagementEvent();

  @override
  List<Object> get props => [];
}

class CreateExerciseEvent extends ExerciseManagementEvent {
  final String name;
  final String description;
  final String imageName;

  const CreateExerciseEvent({
    required this.name,
    required this.description,
    required this.imageName,
  });

  @override
  List<Object> get props => [name, description, imageName];
}

class GetExerciseEvent extends ExerciseManagementEvent {
  final int exerciseId;

  const GetExerciseEvent(this.exerciseId);
}

class FetchExercisesEvent extends ExerciseManagementEvent {}

class UpdateExerciseEvent extends ExerciseManagementEvent {
  final Exercise exerciseToUpdate;

  const UpdateExerciseEvent(this.exerciseToUpdate);
}

class DeleteExerciseEvent extends ExerciseManagementEvent {
  final Exercise exerciseToDelete;

  const DeleteExerciseEvent(this.exerciseToDelete);
}
