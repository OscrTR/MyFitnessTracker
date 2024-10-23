part of 'exercise_management_bloc.dart';

abstract class ExerciseManagementState extends Equatable {
  const ExerciseManagementState();

  @override
  List<Object> get props => [];
}

class ExerciseManagementInitial extends ExerciseManagementState {}

class ExerciseManagementLoading extends ExerciseManagementState {}

class ExerciseManagementSuccess extends ExerciseManagementState {
  final Exercise exercise;

  const ExerciseManagementSuccess(this.exercise);

  @override
  List<Object> get props => [exercise];
}

class ExerciseManagementFailure extends ExerciseManagementState {
  final String message;

  const ExerciseManagementFailure({required this.message});

  @override
  List<Object> get props => [message];
}
