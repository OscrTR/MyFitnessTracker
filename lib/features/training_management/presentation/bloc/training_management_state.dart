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
  final List<Widget> selectedTrainingWidgetList;

  const TrainingManagementLoaded({
    this.trainings = const [],
    this.selectedTraining = const Training(
        name: 'Unnamed training',
        type: TrainingType.workout,
        isSelected: true,
        trainingExercises: [],
        multisets: []),
    this.selectedTrainingWidgetList = const [],
  });

  TrainingManagementLoaded copyWith({
    List<Training>? trainings,
    Training? selectedTraining,
    TrainingType? selectedTrainingType,
    List<Widget>? selectedTrainingWidgetList,
    bool? isSelected,
    String? name,
    TrainingType? type,
    List<TrainingExercise>? trainingExercises,
    List<Multiset>? multisets,
  }) {
    return TrainingManagementLoaded(
      trainings: trainings ?? this.trainings,
      selectedTraining: (selectedTraining ?? this.selectedTraining)?.copyWith(
        name: selectedTraining?.name ?? this.selectedTraining?.name,
        type: selectedTraining?.type ?? this.selectedTraining?.type,
        isSelected:
            selectedTraining?.isSelected ?? this.selectedTraining?.isSelected,
        trainingExercises: selectedTraining?.trainingExercises ??
            this.selectedTraining?.trainingExercises,
        multisets:
            selectedTraining?.multisets ?? this.selectedTraining?.multisets,
      ),
      selectedTrainingWidgetList:
          selectedTrainingWidgetList ?? this.selectedTrainingWidgetList,
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
        selectedTraining,
        selectedTrainingWidgetList,
      ];
}

class TrainingManagementFailure extends TrainingManagementState {
  final String message;

  const TrainingManagementFailure(this.message);

  @override
  List<Object> get props => [message];
}
