part of 'training_management_bloc.dart';

abstract class TrainingManagementEvent extends Equatable {
  const TrainingManagementEvent();

  @override
  List<Object> get props => [];
}

class FetchTrainingsEvent extends TrainingManagementEvent {}
