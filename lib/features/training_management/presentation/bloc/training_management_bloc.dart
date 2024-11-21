import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/multiset.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/training_exercise.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/messages/bloc/message_bloc.dart';
import '../../domain/entities/training.dart';
import '../../domain/usecases/fetch_trainings.dart';

part 'training_management_event.dart';
part 'training_management_state.dart';

final String databaseFailureMessage = tr('message_database_failure');
final String invalidNameFailureMessage = tr('message_name_error');

class TrainingManagementBloc
    extends Bloc<TrainingManagementEvent, TrainingManagementState> {
  final FetchTrainings fetchTrainings;
  final MessageBloc messageBloc;

  final TextEditingController nameController = TextEditingController();
  TrainingManagementBloc(
      {required this.fetchTrainings, required this.messageBloc})
      : super(TrainingManagementInitial()) {
    //! Trainings
    on<FetchTrainingsEvent>((event, emit) async {
      final result = await fetchTrainings(null);
      result.fold(
        (failure) => messageBloc.add(AddMessageEvent(
            message: _mapFailureToMessage(failure), isError: true)),
        (trainings) {
          emit(TrainingManagementLoaded(trainings: trainings));
        },
      );
    });

    //! Selected training
    on<LoadInitialSelectedTrainingData>((event, emit) async {
      if (state is TrainingManagementLoaded) {
        final currentState = state as TrainingManagementLoaded;

        final result = await fetchTrainings(null);
        const selectedTraining = Training(
          name: 'Unnamed training',
          type: TrainingType.workout,
          isSelected: true,
          trainingExercises: [],
          multisets: [],
        );

        nameController.text = selectedTraining.name;

        result.fold(
          (failure) => messageBloc.add(AddMessageEvent(
              message: _mapFailureToMessage(failure), isError: true)),
          (trainings) {
            emit(
              currentState.copyWith(selectedTraining: selectedTraining),
            );
          },
        );
      }
    });
    on<ClearSelectedTrainingEvent>((event, emit) {
      if (state is TrainingManagementLoaded) {
        final currentState = state as TrainingManagementLoaded;
        emit(currentState.clearSelectedTraining());
      }
    });
    on<UpdateSelectedTrainingProperty>((event, emit) {
      if (state is TrainingManagementLoaded) {
        final currentState = state as TrainingManagementLoaded;
        final updatedTraining = currentState.selectedTraining?.copyWith(
          id: event.id ?? currentState.selectedTraining!.id,
          name: event.name ?? currentState.selectedTraining!.name,
          type: event.type ?? currentState.selectedTraining!.type,
          isSelected:
              event.isSelected ?? currentState.selectedTraining!.isSelected,
          trainingExercises: event.trainingExercises ??
              currentState.selectedTraining!.trainingExercises,
          multisets:
              event.multisets ?? currentState.selectedTraining!.multisets,
        );

        emit(currentState.copyWith(selectedTraining: updatedTraining));
      }
    });
    on<AddExerciseToSelectedTrainingEvent>((event, emit) {
      if (state is TrainingManagementLoaded) {
        final currentState = state as TrainingManagementLoaded;
        final trainingExercises = List<TrainingExercise>.from(
            currentState.selectedTraining?.trainingExercises ?? []);
        trainingExercises.add(event.trainingExercise);

        final updatedTraining = currentState.selectedTraining?.copyWith(
          trainingExercises: trainingExercises,
        );

        emit(currentState.copyWith(selectedTraining: updatedTraining));
      }
    });

    on<RemoveExerciseFromSelectedTrainingEvent>((event, emit) {
      if (state is TrainingManagementLoaded) {
        final currentState = state as TrainingManagementLoaded;
        // Get the current list of exercises
        final trainingExercises = List<TrainingExercise>.from(
          currentState.selectedTraining?.trainingExercises ?? [],
        );
        // Remove the exercise at the specified position
        trainingExercises.removeAt(event.trainingExercisePosition);

        // Recalculate positions for remaining exercises
        for (int i = 0; i < trainingExercises.length; i++) {
          trainingExercises[i] = trainingExercises[i].copyWith(position: i);
        }

        // Create the updated training object
        final updatedTraining = currentState.selectedTraining?.copyWith(
          trainingExercises: trainingExercises,
        );

        emit(currentState.copyWith(selectedTraining: updatedTraining));
      }
    });

    on<SaveSelectedTrainingEvent>((event, emit) {
      if (state is TrainingManagementLoaded) {
        final currentState = state as TrainingManagementLoaded;
        print(currentState.selectedTraining);
      }
    });

    //! Multisets

    //! Runs

    //! Exercises
  }

  @override
  Future<void> close() {
    nameController.dispose();
    return super.close();
  }
}

String _mapFailureToMessage(Failure failure) {
  if (failure is DatabaseFailure) {
    return databaseFailureMessage;
  } else if (failure is InvalidNameFailure) {
    return invalidNameFailureMessage;
  } else {
    return tr('message_unexpected_error');
  }
}
