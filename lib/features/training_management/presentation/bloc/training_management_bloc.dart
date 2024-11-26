import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/multiset.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/training_exercise.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/messages/bloc/message_bloc.dart';
import '../../domain/entities/training.dart';
import '../../domain/usecases/create_training.dart' as create;
import '../../domain/usecases/fetch_trainings.dart' as fetch;
import '../../domain/usecases/get_training.dart' as get_tr;
import '../../domain/usecases/update_training.dart' as update;
import '../../domain/usecases/delete_training.dart' as delete;

part 'training_management_event.dart';
part 'training_management_state.dart';

final String databaseFailureMessage = tr('message_database_failure');
final String invalidNameFailureMessage = tr('message_name_error');

class TrainingManagementBloc
    extends Bloc<TrainingManagementEvent, TrainingManagementState> {
  final create.CreateTraining createTraining;
  final fetch.FetchTrainings fetchTrainings;
  final get_tr.GetTraining getTraining;
  final update.UpdateTraining updateTraining;
  final delete.DeleteTraining deleteTraining;
  final MessageBloc messageBloc;

  final TextEditingController nameController = TextEditingController();
  TrainingManagementBloc(
      {required this.createTraining,
      required this.fetchTrainings,
      required this.getTraining,
      required this.updateTraining,
      required this.deleteTraining,
      required this.messageBloc})
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

    on<DeleteTrainingEvent>((event, emit) async {
      if (state is TrainingManagementLoaded) {
        final currentState = state as TrainingManagementLoaded;

        final result = await deleteTraining(delete.Params(event.id));

        result.fold(
          (failure) => messageBloc.add(AddMessageEvent(
              message: _mapFailureToMessage(failure), isError: true)),
          (success) {
            final updatedTrainings = currentState.trainings
                .where((training) => training.id != event.id)
                .toList();
            emit(currentState.copyWith(trainings: updatedTrainings));
          },
        );
      }
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
    on<SelectTrainingEvent>((event, emit) async {
      if (state is TrainingManagementLoaded) {
        final currentState = state as TrainingManagementLoaded;

        Training? training = event.training;

        if (event.id != null) {
          final result = await getTraining(get_tr.Params(event.id!));
          result.fold(
            (failure) => messageBloc.add(AddMessageEvent(
                message: _mapFailureToMessage(failure), isError: true)),
            (success) {
              training = success;
            },
          );
        }

        emit(currentState.copyWith(selectedTraining: training));
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
            .indexWhere((multiset) => multiset.key == event.multisetKey);

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
          print('Multiset with key ${event.multisetKey} not found.');
        }
      }
    });

    on<RemoveExerciseFromSelectedTrainingMultisetEvent>((event, emit) {
      if (state is TrainingManagementLoaded) {
        final currentState = state as TrainingManagementLoaded;

        // Find the multiset by key and retrieve its trainingExercises
        final multisetIndex = currentState.selectedTraining?.multisets
            .indexWhere((multiset) => multiset.key == event.multisetKey);

        if (multisetIndex != null && multisetIndex != -1) {
          final multisetExercises = List<TrainingExercise>.from(
            currentState.selectedTraining!.multisets[multisetIndex]
                    .trainingExercises ??
                [],
          );

          // Add the new exercise to the multiset's exercises
          multisetExercises
              .removeWhere((exercise) => exercise.key == event.exerciseKey);

          // Update exercises position
          final updatedExercises = multisetExercises.map((item) {
            final newPosition = multisetExercises.indexOf(item);
            return item.copyWith(position: newPosition);
          }).toList();

          // Create an updated multiset
          final updatedMultiset = currentState
              .selectedTraining!.multisets[multisetIndex]
              .copyWith(trainingExercises: updatedExercises);

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
          messageBloc.add(AddMessageEvent(
              message: 'Multiset with key ${event.multisetKey} not found.',
              isError: true));
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

    on<SaveSelectedTrainingEvent>((event, emit) async {
      if (state is TrainingManagementLoaded) {
        final currentState = state as TrainingManagementLoaded;

        // Ensure selectedTraining is not null
        if (currentState.selectedTraining == null) {
          messageBloc.add(const AddMessageEvent(
              message: 'No training selected to save.', isError: true));
          return;
        }

        final createResult =
            await createTraining(create.Params(currentState.selectedTraining!));

        await createResult.fold(
          (failure) async {
            messageBloc.add(AddMessageEvent(
                message: _mapFailureToMessage(failure), isError: true));
          },
          (success) async {
            messageBloc.add(const AddMessageEvent(
                message: 'Training created successfully.', isError: false));

            final fetchResult = await fetchTrainings(null);

            await fetchResult.fold(
              (failure) async {
                messageBloc.add(AddMessageEvent(
                    message: _mapFailureToMessage(failure), isError: true));
              },
              (trainings) async {
                if (!emit.isDone) {
                  emit(currentState.copyWith(
                    trainings: trainings,
                    resetSelectedTraining: true,
                  ));
                }
              },
            );
          },
        );
      }
    });
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
