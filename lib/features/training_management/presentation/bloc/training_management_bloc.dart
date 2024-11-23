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
        final trainingExercises = List<TrainingExercise>.from(
          currentState.selectedTraining?.trainingExercises ?? [],
        );
        trainingExercises.removeWhere(
            (exercise) => exercise.key == event.trainingExerciseKey);

        final exercisesAndMultisetsList = [
          ...currentState.selectedTraining!.trainingExercises
              .map((e) => {'type': 'exercise', 'data': e}),
          ...currentState.selectedTraining!.multisets
              .map((m) => {'type': 'multiset', 'data': m}),
        ];
        exercisesAndMultisetsList.sort((a, b) {
          final aPosition = (a['data'] as dynamic).position ?? 0;
          final bPosition = (b['data'] as dynamic).position ?? 0;
          return aPosition.compareTo(bPosition);
        });

        final combinedList =
            List<Map<String, dynamic>>.from(exercisesAndMultisetsList);

        // Remove the item
        combinedList.removeWhere((item) {
          // Replace the condition with your specific criteria
          return (item['type'] == 'exercise') &&
              (item['data'] as TrainingExercise).key ==
                  event.trainingExerciseKey;
        });
        combinedList.removeWhere((item) {
          // Replace the condition with your specific criteria
          return item['type'] == 'multiset' &&
              (item['data'] as Multiset).key == event.trainingExerciseKey;
        });

        // Update positions for exercises
        final updatedExercises = combinedList
            .where((item) => item['type'] == 'exercise')
            .map((item) {
          final exercise = item['data'] as TrainingExercise;
          final newPosition = combinedList.indexOf(item);
          return exercise.copyWith(position: newPosition);
        }).toList();

        final updatedMultisets = combinedList
            .where((item) => item['type'] == 'multiset')
            .map((item) {
          final multiset = item['data'] as Multiset;
          final newPosition = combinedList.indexOf(item);
          return multiset.copyWith(position: newPosition);
        }).toList();

        final updatedTraining = currentState.selectedTraining?.copyWith(
          trainingExercises: updatedExercises,
          multisets: updatedMultisets,
        );

        emit(currentState.copyWith(selectedTraining: updatedTraining));
      }
    });

    on<AddExerciseToSelectedTrainingMultisetEvent>((event, emit) {
      if (state is TrainingManagementLoaded) {
        final currentState = state as TrainingManagementLoaded;

        // Find the multiset by key and retrieve its trainingExercises
        final multisetIndex = currentState.selectedTraining?.multisets
            .indexWhere((multiset) => multiset.key == event.key);

        if (multisetIndex != null && multisetIndex != -1) {
          final multisetExercises = List<TrainingExercise>.from(
            currentState.selectedTraining!.multisets[multisetIndex]
                    .trainingExercises ??
                [],
          );

          // Add the new exercise to the multiset's exercises
          multisetExercises.add(event.trainingExercise);

          // Create an updated multiset
          final updatedMultiset = currentState
              .selectedTraining!.multisets[multisetIndex]
              .copyWith(trainingExercises: multisetExercises);

          // Replace the old multiset with the updated one in the multisets list
          final updatedMultisets = List<Multiset>.from(
            currentState.selectedTraining!.multisets,
          );
          updatedMultisets[multisetIndex] = updatedMultiset;

          // Update the training with the modified multisets list
          final updatedTraining = currentState.selectedTraining?.copyWith(
            multisets: updatedMultisets,
          );

          // Emit the updated state
          emit(currentState.copyWith(selectedTraining: updatedTraining));
        } else {
          // Handle the case where the multiset with the given key does not exist
          print('Multiset with key ${event.key} not found.');
        }
      }
    });

    on<AddMultisetToSelectedTrainingEvent>((event, emit) {
      if (state is TrainingManagementLoaded) {
        final currentState = state as TrainingManagementLoaded;
        final multisets =
            List<Multiset>.from(currentState.selectedTraining?.multisets ?? []);

        multisets.add(event.multiset);

        final updatedTraining = currentState.selectedTraining?.copyWith(
          multisets: multisets,
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
