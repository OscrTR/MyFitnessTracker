part of 'exercise_management_bloc.dart';

abstract class ExerciseManagementEvent extends Equatable {
  const ExerciseManagementEvent();

  @override
  List<Object> get props => [];
}

class CreateExerciseEvent extends ExerciseManagementEvent {
  final Exercise exercise;

  const CreateExerciseEvent(this.exercise);

  @override
  List<Object> get props => [exercise];
}

class GetExerciseEvent extends ExerciseManagementEvent {
  final int exerciseId;

  const GetExerciseEvent(this.exerciseId);

  @override
  List<Object> get props => [exerciseId];
}

class ClearSelectedExerciseEvent extends ExerciseManagementEvent {
  const ClearSelectedExerciseEvent();
}

class FetchExercisesEvent extends ExerciseManagementEvent {}

class UpdateExerciseEvent extends ExerciseManagementEvent {
  final Exercise exercise;

  const UpdateExerciseEvent(this.exercise);

  @override
  List<Object> get props => [exercise];
}

class DeleteExerciseEvent extends ExerciseManagementEvent {
  final int id;

  const DeleteExerciseEvent(this.id);

  @override
  List<Object> get props => [id];
}
