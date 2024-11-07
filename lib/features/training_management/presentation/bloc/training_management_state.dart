part of 'training_management_bloc.dart';

abstract class TrainingManagementState extends Equatable {
  const TrainingManagementState();

  @override
  List<Object?> get props => [];
}

class TrainingManagementInitial extends TrainingManagementState {}

class TrainingManagementLoading extends TrainingManagementState {}

class TrainingManagementLoaded extends TrainingManagementState {
  final List<Training> trainings;
  final Training? selectedTraining;

  const TrainingManagementLoaded(
      {this.trainings = const [], this.selectedTraining});

  TrainingManagementLoaded copyWith({
    List<Training>? trainings,
    Training? selectedTraining,
    bool clearSelectedTraining = false,
  }) {
    return TrainingManagementLoaded(
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
