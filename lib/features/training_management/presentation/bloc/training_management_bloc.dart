import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/messages/bloc/message_bloc.dart';
import '../../domain/entities/multiset.dart';
import '../../domain/entities/training.dart';
import '../../domain/entities/training_exercise.dart';
import '../../domain/usecases/create_training.dart' as create;
import '../../domain/usecases/delete_training.dart' as delete;
import '../../domain/usecases/fetch_trainings.dart' as fetch;
import '../../domain/usecases/get_days_since_training.dart' as get_d;
import '../../domain/usecases/get_training.dart' as get_tr;
import '../../domain/usecases/update_training.dart' as update;

part 'training_management_event.dart';
part 'training_management_state.dart';

final String databaseFailureMessage = tr('message_database_failure');
final String invalidNameFailureMessage = tr('message_name_error');
const uuid = Uuid();

class TrainingManagementBloc
    extends Bloc<TrainingManagementEvent, TrainingManagementState> {
  final create.CreateTraining createTraining;
  final fetch.FetchTrainings fetchTrainings;
  final get_tr.GetTraining getTraining;
  final update.UpdateTraining updateTraining;
  final delete.DeleteTraining deleteTraining;
  final get_d.GetDaysSinceTraining getDaysSinceTraining;
  final MessageBloc messageBloc;

  TrainingManagementBloc({
    required this.createTraining,
    required this.fetchTrainings,
    required this.getTraining,
    required this.updateTraining,
    required this.deleteTraining,
    required this.getDaysSinceTraining,
    required this.messageBloc,
  }) : super(TrainingManagementInitial()) {
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
      add(LoadDaysSinceTrainingEvent());
    });

    on<LoadDaysSinceTrainingEvent>((event, emit) async {
      if (state is TrainingManagementLoaded) {
        final currentState = state as TrainingManagementLoaded;
        final days = <int, int?>{};
        for (Training training in currentState.trainings) {
          final result = await getDaysSinceTraining(get_d.Params(training.id!));
          result.fold(
            (failure) => messageBloc.add(AddMessageEvent(
                message: _mapFailureToMessage(failure), isError: true)),
            (res) {
              days[training.id!] = res;
            },
          );
        }
        emit(currentState.copyWith(daysSinceLastTraining: days));
      }
    });

    on<DeleteTrainingEvent>((event, emit) async {
      if (state is TrainingManagementLoaded) {
        final result = await deleteTraining(delete.Params(event.id));

        result.fold(
          (failure) => messageBloc.add(AddMessageEvent(
              message: _mapFailureToMessage(failure), isError: true)),
          (success) {
            messageBloc.add(AddMessageEvent(
                message: tr('message_training_deletion_success'),
                isError: false));

            add(FetchTrainingsEvent());
          },
        );
      }
    });

    //! Selected training
    on<GetTrainingEvent>((event, emit) async {
      if (state is TrainingManagementLoaded) {
        final currentState = state as TrainingManagementLoaded;
        final result = await getTraining(get_tr.Params(event.id));

        result.fold(
          (failure) => messageBloc.add(AddMessageEvent(
              message: _mapFailureToMessage(failure), isError: true)),
          (training) {
            emit(currentState.copyWith(selectedTraining: training));
          },
        );
      }
    });

    on<StartTrainingEvent>((event, emit) async {
      if (state is! TrainingManagementLoaded) return;

      final currentState = state as TrainingManagementLoaded;

      try {
        // Fetch the training
        final getResult = await getTraining(get_tr.Params(event.trainingId));

        final training = getResult.fold<Training?>(
          (failure) {
            messageBloc.add(AddMessageEvent(
              message: _mapFailureToMessage(failure),
              isError: true,
            ));
            return null;
          },
          (training) => training,
        );

        if (training == null) return;

        final updatedTraining = training.copyWith(isSelected: true);
        final updateResult =
            await updateTraining(update.Params(updatedTraining));

        final updateSuccess = updateResult.fold<bool>(
          (failure) {
            messageBloc.add(AddMessageEvent(
              message: _mapFailureToMessage(failure),
              isError: true,
            ));
            return false;
          },
          (_) => true,
        );

        if (!updateSuccess) return;

        // Fetch updated trainings
        final fetchResult = await fetchTrainings(null);

        fetchResult.fold(
          (failure) {
            messageBloc.add(AddMessageEvent(
              message: _mapFailureToMessage(failure),
              isError: true,
            ));
          },
          (trainings) {
            if (!emit.isDone) {
              emit(currentState.copyWith(
                  trainings: trainings, activeTraining: updatedTraining));
            }
          },
        );
      } catch (e) {
        // Handle any unexpected exceptions
        messageBloc.add(AddMessageEvent(
          message: 'An unexpected error occurred: ${e.toString()}',
          isError: true,
        ));
      }
    });

    on<ClearSelectedTrainingEvent>((event, emit) {
      if (state is TrainingManagementLoaded) {
        final currentState = state as TrainingManagementLoaded;
        emit(currentState.copyWith(resetSelectedTraining: true));
      }
    });
    on<UpdateSelectedTrainingProperty>((event, emit) {
      if (state is TrainingManagementLoaded) {
        final currentState = state as TrainingManagementLoaded;
        final updatedTraining = currentState.selectedTraining?.copyWith(
          id: event.id ?? currentState.selectedTraining!.id,
          name: event.name ?? currentState.selectedTraining!.name,
          type: event.type ?? currentState.selectedTraining!.type,
          trainingExercises: event.trainingExercises ??
              currentState.selectedTraining!.trainingExercises,
          multisets:
              event.multisets ?? currentState.selectedTraining!.multisets,
        );

        emit(currentState.copyWith(selectedTraining: updatedTraining));
      }
    });

    on<AddOrUpdateTrainingEvent>((event, emit) async {
      if (state is TrainingManagementLoaded) {
        final currentState = state as TrainingManagementLoaded;
        Training trainingToCreateOrUpdate;

        if (currentState.selectedTraining == null) {
          trainingToCreateOrUpdate = const Training(
            name: 'Unnamed training',
            type: TrainingType.workout,
            trainingExercises: [],
            multisets: [],
          );
        } else {
          trainingToCreateOrUpdate = currentState.selectedTraining!;
        }

        trainingToCreateOrUpdate = trainingToCreateOrUpdate.copyWith(
          name: event.training.name.trim() != ''
              ? event.training.name.trim()
              : 'Unnamed training',
          type: event.training.type,
          objectives: event.training.objectives,
          trainingDays: event.training.trainingDays,
        );

        // Add
        if (trainingToCreateOrUpdate.id == null) {
          final createResult =
              await createTraining(create.Params(trainingToCreateOrUpdate));

          createResult.fold(
            (failure) {
              messageBloc.add(AddMessageEvent(
                  message: _mapFailureToMessage(failure), isError: true));
            },
            (success) {
              messageBloc.add(AddMessageEvent(
                  message: currentState.selectedTraining == null
                      ? tr('message_training_creation_success')
                      : tr('message_training_update_success'),
                  isError: false));

              add(FetchTrainingsEvent());
            },
          );
        }
        // Update
        else {
          final updatedResult =
              await updateTraining(update.Params(trainingToCreateOrUpdate));

          updatedResult.fold(
            (failure) {
              messageBloc.add(AddMessageEvent(
                  message: _mapFailureToMessage(failure), isError: true));
            },
            (success) {
              messageBloc.add(const AddMessageEvent(
                  message: 'Training updated successfully.', isError: false));

              add(FetchTrainingsEvent());
            },
          );
        }
      }
    });

    on<AddOrUpdateSelectedTrainingEvent>((event, emit) async {
      if (state is TrainingManagementLoaded) {
        final currentState = state as TrainingManagementLoaded;
        Training trainingToCreateOrUpdate;

        // Add
        if (currentState.selectedTraining == null) {
          trainingToCreateOrUpdate = const Training(
            name: 'Unnamed training',
            type: TrainingType.workout,
            objectives: '',
            trainingDays: [],
            trainingExercises: [],
            multisets: [],
          );
        }
        // Update
        else {
          trainingToCreateOrUpdate = currentState.selectedTraining!;
        }

        trainingToCreateOrUpdate = trainingToCreateOrUpdate.copyWith(
          name: event.training.name.trim(),
          type: event.training.type,
          objectives: event.training.objectives,
          trainingDays: event.training.trainingDays,
        );

        emit(currentState.copyWith(selectedTraining: trainingToCreateOrUpdate));
      }
    });

    //! Training exercise
    on<AddOrUpdateTrainingExerciseEvent>((event, emit) {
      if (state is TrainingManagementLoaded) {
        final currentState = state as TrainingManagementLoaded;
        final trainingExercises = List<TrainingExercise>.from(
            currentState.selectedTraining?.trainingExercises ?? []);
        final trainingMultisets =
            List<Multiset>.from(currentState.selectedTraining?.multisets ?? []);

        // Add
        if (event.trainingExercise.key == null) {
          final tExerciseToAdd = TrainingExercise(
            id: event.trainingExercise.id,
            trainingId: event.trainingExercise.trainingId,
            multisetId: event.trainingExercise.multisetId,
            exerciseId: event.trainingExercise.exerciseId,
            trainingExerciseType: event.trainingExercise.trainingExerciseType,
            specialInstructions: event.trainingExercise.specialInstructions,
            objectives: event.trainingExercise.objectives,
            targetDistance: event.trainingExercise.targetDistance,
            targetDuration: event.trainingExercise.targetDuration,
            targetPace: event.trainingExercise.targetPace,
            isTargetPaceSelected: event.trainingExercise.isTargetPaceSelected,
            sets: event.trainingExercise.sets,
            isSetsInReps: event.trainingExercise.isSetsInReps,
            minReps: event.trainingExercise.minReps,
            maxReps: event.trainingExercise.maxReps,
            duration: event.trainingExercise.duration,
            setRest: event.trainingExercise.setRest,
            exerciseRest: event.trainingExercise.exerciseRest,
            autoStart: event.trainingExercise.autoStart,
            position: trainingExercises.length + trainingMultisets.length,
            key: uuid.v4(),
            runExerciseTarget: event.trainingExercise.runExerciseTarget,
            intensity: event.trainingExercise.intensity,
          );

          trainingExercises.add(tExerciseToAdd);
        }
        // Update
        else {
          final index = trainingExercises.indexWhere(
              (tExercise) => tExercise.key == event.trainingExercise.key);
          trainingExercises[index] = event.trainingExercise;
        }

        final updatedTraining = currentState.selectedTraining != null
            ? currentState.selectedTraining!.copyWith(
                trainingExercises: trainingExercises,
              )
            : Training(
                name: event.training.name,
                type: event.training.type,
                trainingExercises: trainingExercises,
                multisets: event.training.multisets,
              );

        emit(currentState.copyWith(selectedTraining: updatedTraining));
      }
    });

    on<RemoveTrainingExerciseEvent>((event, emit) {
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
          return (item['type'] == 'exercise') &&
              (item['data'] as TrainingExercise).key ==
                  event.trainingExerciseKey;
        });
        combinedList.removeWhere((item) {
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

    //! Multiset
    on<AddOrUpdateMultisetEvent>((event, emit) {
      if (state is TrainingManagementLoaded) {
        final currentState = state as TrainingManagementLoaded;
        final trainingExercises = List<TrainingExercise>.from(
            currentState.selectedTraining?.trainingExercises ?? []);
        final trainingMultisets =
            List<Multiset>.from(currentState.selectedTraining?.multisets ?? []);

        // Add
        if (event.multiset.key == null) {
          final multisetToAdd = Multiset(
            id: event.multiset.id,
            trainingId: event.multiset.trainingId,
            trainingExercises: event.multiset.trainingExercises,
            sets: event.multiset.sets,
            setRest: event.multiset.setRest,
            multisetRest: event.multiset.multisetRest,
            specialInstructions: event.multiset.specialInstructions,
            objectives: event.multiset.objectives,
            position: trainingExercises.length + trainingMultisets.length,
            key: uuid.v4(),
          );

          trainingMultisets.add(multisetToAdd);
        }
        // Update
        else {
          final index = trainingMultisets
              .indexWhere((multiset) => multiset.key == event.multiset.key);
          trainingMultisets[index] = event.multiset;
        }

        final updatedTraining = currentState.selectedTraining != null
            ? currentState.selectedTraining!.copyWith(
                multisets: trainingMultisets,
              )
            : Training(
                name: event.training.name,
                type: event.training.type,
                trainingExercises: event.training.trainingExercises,
                multisets: trainingMultisets,
              );

        emit(currentState.copyWith(selectedTraining: updatedTraining));
      }
    });

    on<AddOrUpdateMultisetExerciseEvent>((event, emit) {
      if (state is TrainingManagementLoaded) {
        final currentState = state as TrainingManagementLoaded;

        // Find the multiset by key and retrieve its trainingExercises
        final multisetIndex = currentState.selectedTraining?.multisets
            .indexWhere((multiset) => multiset.key == event.multisetKey);

        if (multisetIndex != null && multisetIndex != -1) {
          final multisetExercises = List<TrainingExercise>.from(currentState
              .selectedTraining!.multisets[multisetIndex].trainingExercises);

          // Add
          if (event.trainingExercise.key == null) {
            final tExerciseToAdd = TrainingExercise(
              id: event.trainingExercise.id,
              trainingId: event.trainingExercise.trainingId,
              multisetId: event.trainingExercise.multisetId,
              exerciseId: event.trainingExercise.exerciseId,
              trainingExerciseType: event.trainingExercise.trainingExerciseType,
              specialInstructions: event.trainingExercise.specialInstructions,
              objectives: event.trainingExercise.objectives,
              targetDistance: event.trainingExercise.targetDistance,
              targetDuration: event.trainingExercise.targetDuration,
              targetPace: event.trainingExercise.targetPace,
              isTargetPaceSelected: event.trainingExercise.isTargetPaceSelected,
              sets: event.trainingExercise.sets,
              isSetsInReps: event.trainingExercise.isSetsInReps,
              minReps: event.trainingExercise.minReps,
              maxReps: event.trainingExercise.maxReps,
              duration: event.trainingExercise.duration,
              setRest: event.trainingExercise.setRest,
              exerciseRest: event.trainingExercise.exerciseRest,
              autoStart: event.trainingExercise.autoStart,
              position: multisetExercises.length,
              key: uuid.v4(),
              runExerciseTarget: event.trainingExercise.runExerciseTarget,
              intensity: event.trainingExercise.intensity,
            );
            multisetExercises.add(tExerciseToAdd);
          }

          // Update
          else {
            final index = multisetExercises.indexWhere(
                (tExercise) => tExercise.key == event.trainingExercise.key);
            multisetExercises[index] = event.trainingExercise;
          }

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
          AddMessageEvent(
              message:
                  tr('message_multiset_not_found', args: [event.multisetKey]),
              isError: true);
        }
      }
    });

    on<RemoveMultisetExerciseEvent>((event, emit) {
      if (state is TrainingManagementLoaded) {
        final currentState = state as TrainingManagementLoaded;

        // Find the multiset by key and retrieve its trainingExercises
        final multisetIndex = currentState.selectedTraining?.multisets
            .indexWhere((multiset) => multiset.key == event.multisetKey);

        if (multisetIndex != null && multisetIndex != -1) {
          final multisetExercises = List<TrainingExercise>.from(currentState
              .selectedTraining!.multisets[multisetIndex].trainingExercises);

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
