part of 'training_management_bloc.dart';

abstract class TrainingManagementState extends Equatable {
  const TrainingManagementState();

  @override
  List<Object?> get props => [];
}

class TrainingManagementInitial extends TrainingManagementState {}

class TrainingManagementLoading extends TrainingManagementState {}

class TrainingsLoaded extends TrainingManagementState {
  final List<Training> trainings;
  final Training? selectedTraining;

  const TrainingsLoaded({this.trainings = const [], this.selectedTraining});

  TrainingsLoaded copyWith({
    List<Training>? trainings,
    Training? selectedTraining,
    bool clearSelectedTraining = false,
  }) {
    return TrainingsLoaded(
      trainings: trainings ?? this.trainings,
      selectedTraining: clearSelectedTraining
          ? null
          : (selectedTraining ?? this.selectedTraining),
    );
  }

  @override
  List<Object?> get props => [trainings, selectedTraining];
}

class TrainingManagementFailure extends TrainingManagementState {
  final String message;

  const TrainingManagementFailure(this.message);

  @override
  List<Object> get props => [message];
}
