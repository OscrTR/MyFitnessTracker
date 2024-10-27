part of 'exercise_management_bloc.dart';

abstract class ExerciseManagementState extends Equatable {
  const ExerciseManagementState();

  @override
  List<Object?> get props => [];
}

class ExerciseManagementInitial extends ExerciseManagementState {}

class ExerciseManagementLoading extends ExerciseManagementState {}

class ExerciseManagementLoaded extends ExerciseManagementState {
  final List<Exercise> exercises;
  final Exercise? selectedExercise;

  const ExerciseManagementLoaded({
    this.exercises = const [],
    this.selectedExercise,
  });

  ExerciseManagementLoaded copyWith({
    List<Exercise>? exercises,
    Exercise? selectedExercise,
    String? errorMessage,
    String? successMessage,
  }) {
    return ExerciseManagementLoaded(
      exercises: exercises ?? this.exercises,
      selectedExercise: selectedExercise ?? this.selectedExercise,
    );
  }

  @override
  List<Object?> get props => [exercises, selectedExercise];
}

class ExerciseManagementFailure extends ExerciseManagementState {
  final String message;

  const ExerciseManagementFailure(this.message);

  @override
  List<Object> get props => [message];
}
