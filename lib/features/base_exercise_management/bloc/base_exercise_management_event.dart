part of 'base_exercise_management_bloc.dart';

abstract class BaseExerciseManagementEvent extends Equatable {
  const BaseExerciseManagementEvent();

  @override
  List<Object> get props => [];
}

class GetBaseExerciseEvent extends BaseExerciseManagementEvent {
  final int id;

  const GetBaseExerciseEvent(this.id);

  @override
  List<Object> get props => [id];
}

class GetAllBaseExercisesEvent extends BaseExerciseManagementEvent {}

class CreateOrUpdateBaseExerciseEvent extends BaseExerciseManagementEvent {
  final BaseExercise exercise;

  const CreateOrUpdateBaseExerciseEvent(this.exercise);

  @override
  List<Object> get props => [exercise];
}

class DeleteBaseExerciseEvent extends BaseExerciseManagementEvent {
  final int id;

  const DeleteBaseExerciseEvent(this.id);

  @override
  List<Object> get props => [id];
}

class ClearSelectedBaseExerciseEvent extends BaseExerciseManagementEvent {}
