part of 'base_exercise_management_bloc.dart';

abstract class BaseExerciseManagementState extends Equatable {
  const BaseExerciseManagementState();

  @override
  List<Object?> get props => [];
}

class BaseExerciseManagementInitial extends BaseExerciseManagementState {}

class BaseExerciseManagementLoaded extends BaseExerciseManagementState {
  final List<BaseExercise> baseExercises;
  final BaseExercise? selectedBaseExercise;

  const BaseExerciseManagementLoaded({
    this.baseExercises = const [],
    this.selectedBaseExercise,
  });

  BaseExerciseManagementLoaded copyWith({
    List<BaseExercise>? baseExercises,
    BaseExercise? selectedBaseExercise,
    bool clearSelectedBaseExercise = false,
  }) {
    return BaseExerciseManagementLoaded(
      baseExercises: baseExercises ?? this.baseExercises,
      selectedBaseExercise: clearSelectedBaseExercise
          ? null
          : (selectedBaseExercise ?? this.selectedBaseExercise),
    );
  }

  @override
  List<Object?> get props => [baseExercises, selectedBaseExercise];
}
