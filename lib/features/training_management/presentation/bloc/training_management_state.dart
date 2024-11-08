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
  final TrainingType selectedTrainingType;
  final List<Widget> selectedTrainingWidgetList;
  final TextEditingController? nameController;

  const TrainingManagementLoaded({
    this.trainings = const [],
    this.selectedTraining,
    this.selectedTrainingType = TrainingType.workout,
    this.selectedTrainingWidgetList = const [],
    this.nameController,
  });

  TrainingManagementLoaded copyWith({
    List<Training>? trainings,
    Training? selectedTraining,
    TrainingType? selectedTrainingType,
    List<Widget>? selectedTrainingWidgetList,
  }) {
    return TrainingManagementLoaded(
      trainings: trainings ?? this.trainings,
      selectedTraining: selectedTraining ?? this.selectedTraining,
      selectedTrainingType: selectedTrainingType ?? this.selectedTrainingType,
      selectedTrainingWidgetList:
          selectedTrainingWidgetList ?? this.selectedTrainingWidgetList,
      nameController: nameController,
    );
  }

  TrainingManagementLoaded clearSelectedTraining() {
    return copyWith(
      selectedTraining: null,
      selectedTrainingType: null,
      selectedTrainingWidgetList: const [],
    );
  }

  @override
  List<Object?> get props => [
        trainings,
        selectedTrainingType,
        selectedTrainingWidgetList,
        nameController,
      ];
}

class TrainingManagementFailure extends TrainingManagementState {
  final String message;

  const TrainingManagementFailure(this.message);

  @override
  List<Object> get props => [message];
}
