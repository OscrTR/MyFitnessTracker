part of 'exercise_management_bloc.dart';

abstract class ExerciseManagementState extends Equatable {
  const ExerciseManagementState();  

  @override
  List<Object> get props => [];
}
class ExerciseManagementInitial extends ExerciseManagementState {}
