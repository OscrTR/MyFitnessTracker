part of 'exercise_management_bloc.dart';

abstract class ExerciseManagementEvent extends Equatable {
  const ExerciseManagementEvent();

  @override
  List<Object> get props => [];
}

class CreateExerciseEvent extends ExerciseManagementEvent {
  final String name;
  final String description;
  final String imagePath;

  const CreateExerciseEvent({
    required this.name,
    required this.description,
    required this.imagePath,
  });

  @override
  List<Object> get props => [name, description, imagePath];
}

class GetExerciseEvent extends ExerciseManagementEvent {
  final int exerciseId;

  const GetExerciseEvent(this.exerciseId);

  @override
  List<Object> get props => [exerciseId];
}

class FetchExercisesEvent extends ExerciseManagementEvent {}

class UpdateExerciseEvent extends ExerciseManagementEvent {
  final int id;
  final String name;
  final String description;
  final String imagePath;

  const UpdateExerciseEvent({
    required this.id,
    required this.name,
    required this.description,
    required this.imagePath,
  });

  @override
  List<Object> get props => [id, name, description, imagePath];
}

class DeleteExerciseEvent extends ExerciseManagementEvent {
  final int id;

  const DeleteExerciseEvent(this.id);

  @override
  List<Object> get props => [id];
}
