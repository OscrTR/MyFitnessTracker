part of 'muscle_management_bloc.dart';

abstract class MuscleManagementEvent extends Equatable {
  const MuscleManagementEvent();

  @override
  List<Object?> get props => [];
}

class FetchMusclesEvent extends MuscleManagementEvent {}

class CreateOrUpdateMuscleEvent extends MuscleManagementEvent {
  final Muscle muscle;

  const CreateOrUpdateMuscleEvent({required this.muscle});

  @override
  List<Object> get props => [muscle];
}

class GetMuscleEvent extends MuscleManagementEvent {
  final int id;

  const GetMuscleEvent({required this.id});

  @override
  List<Object> get props => [id];
}

class DeleteMuscleEvent extends MuscleManagementEvent {
  final int id;

  const DeleteMuscleEvent({required this.id});

  @override
  List<Object> get props => [id];
}

class AssignMuscleToExerciseEvent extends MuscleManagementEvent {
  final int exerciseId;
  final int muscleId;
  final bool isPrimary;

  const AssignMuscleToExerciseEvent(
      {required this.exerciseId,
      required this.muscleId,
      required this.isPrimary});

  @override
  List<Object> get props => [exerciseId, muscleId, isPrimary];
}
