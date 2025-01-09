part of 'muscle_management_bloc.dart';

abstract class MuscleManagementState extends Equatable {
  const MuscleManagementState();

  @override
  List<Object> get props => [];
}

class MuscleManagementInitial extends MuscleManagementState {}

class MuscleManagementLoading extends MuscleManagementState {}

class MuscleManagementLoaded extends MuscleManagementState {
  final List<Muscle> muscles;
  final Muscle? selectedMuscle;

  const MuscleManagementLoaded({
    this.muscles = const [],
    this.selectedMuscle,
  });
}

class MuscleManagementFailure extends MuscleManagementState {
  final String message;

  const MuscleManagementFailure(this.message);

  @override
  List<Object> get props => [message];
}
