import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import '../../../core/database/database_service.dart';
import 'package:uuid/uuid.dart';

import '../../../core/enums/enums.dart';
import '../../../core/messages/bloc/message_bloc.dart';
import '../../../injection_container.dart';
import '../models/multiset.dart';
import '../models/training.dart';
import '../models/exercise.dart';

part 'training_management_event.dart';
part 'training_management_state.dart';

const uuid = Uuid();

class TrainingManagementBloc
    extends Bloc<TrainingManagementEvent, TrainingManagementState> {
  final MessageBloc messageBloc;

  TrainingManagementBloc({required this.messageBloc})
      : super(TrainingManagementInitial()) {
    on<FetchTrainingsEvent>((event, emit) async {
      try {
        final fetchedTrainings = await sl<DatabaseService>().getAllTrainings();
        final daysSinceTraining =
            await sl<DatabaseService>().getDaysSinceTraining();

        if (state is TrainingManagementLoaded) {
          final currentState = state as TrainingManagementLoaded;
          emit(currentState.copyWith(
              trainings: fetchedTrainings,
              daysSinceLastTraining: daysSinceTraining,
              resetSelectedTraining: event.hasToResetSelectedTraining));
        } else {
          emit(TrainingManagementLoaded(
              trainings: fetchedTrainings,
              daysSinceLastTraining: daysSinceTraining));
        }
      } catch (e) {
        messageBloc.add(AddMessageEvent(
            message: 'An error occurred: ${e.toString()}', isError: true));
        rethrow;
      }
    });

    on<DeleteTrainingEvent>((event, emit) async {
      if (state is! TrainingManagementLoaded) return;
      final currentState = state as TrainingManagementLoaded;
      try {
        await sl<DatabaseService>().deleteTraining(event.id);
        emit(currentState.copyWith(resetSelectedTraining: true));
        messageBloc.add(AddMessageEvent(
            message: tr('message_training_deletion_success'), isError: false));

        add(FetchTrainingsEvent());
      } catch (e) {
        messageBloc.add(AddMessageEvent(
            message: 'An error occurred: ${e.toString()}', isError: true));
        rethrow;
      }
    });

    //! Selected training
    on<GetTrainingEvent>((event, emit) async {
      if (state is! TrainingManagementLoaded) return;
      final currentState = state as TrainingManagementLoaded;
      try {
        Training? training = currentState.selectedTraining;
        if (event.id != null) {
          training = await sl<DatabaseService>().getTrainingById(event.id!);
        }

        emit(currentState.copyWith(selectedTraining: training));
      } catch (e) {
        messageBloc.add(AddMessageEvent(
            message: 'An error occurred: ${e.toString()}', isError: true));
        rethrow;
      }
    });

    on<StartTrainingEvent>((event, emit) async {
      if (state is! TrainingManagementLoaded) return;
      final currentState = state as TrainingManagementLoaded;

      try {
        final training =
            await sl<DatabaseService>().getTrainingById(event.trainingId);
        if (training == null) return;

        final lastTrainingVersion = await sl<DatabaseService>()
            .getMostRecentTrainingVersionForTrainingId(training.id!);

        final lastTrainingVersionId = lastTrainingVersion.id!;

        emit(currentState.copyWith(
            activeTraining: training,
            activeTrainingMostRecentVersionId: lastTrainingVersionId));
      } catch (e) {
        messageBloc.add(AddMessageEvent(
          message: 'An error occurred: ${e.toString()}',
          isError: true,
        ));
        rethrow;
      }
    });

    on<ClearSelectedTrainingEvent>((event, emit) {
      if (state is! TrainingManagementLoaded) return;
      final currentState = state as TrainingManagementLoaded;
      emit(currentState.copyWith(resetSelectedTraining: true));
    });

    on<UpdateSelectedTrainingProperty>((event, emit) {
      if (state is! TrainingManagementLoaded) return;
      final currentState = state as TrainingManagementLoaded;
      final updatedTraining = currentState.selectedTraining.copyWith(
        id: event.id ?? currentState.selectedTraining.id,
        name: event.name ?? currentState.selectedTraining.name,
        objectives:
            event.objectives ?? currentState.selectedTraining.objectives,
        trainingType: event.type ?? currentState.selectedTraining.trainingType,
        exercises: event.exercises ?? currentState.selectedTraining.exercises,
        multisets: event.multisets ?? currentState.selectedTraining.multisets,
        trainingDays:
            event.trainingDays ?? currentState.selectedTraining.trainingDays,
      );

      emit(currentState.copyWith(selectedTraining: updatedTraining));
    });

    on<CreateOrUpdateTrainingEvent>((event, emit) async {
      if (state is! TrainingManagementLoaded) return;
      final currentState = state as TrainingManagementLoaded;

      Training trainingToCreateOrUpdate = currentState.selectedTraining;

      trainingToCreateOrUpdate = trainingToCreateOrUpdate.copyWith(
        name: event.training.name.trim() != ''
            ? event.training.name.trim()
            : 'Unnamed training',
        trainingType: event.training.trainingType,
        objectives: event.training.objectives,
        trainingDays: event.training.trainingDays,
      );

      try {
        final isUpdate = trainingToCreateOrUpdate.id != null;

        if (isUpdate) {
          await sl<DatabaseService>().updateTraining(event.training);
          messageBloc.add(const AddMessageEvent(
              message: 'Training updated successfully.', isError: false));
        } else {
          await sl<DatabaseService>().createTraining(event.training);
          messageBloc.add(const AddMessageEvent(
              message: 'Training created successfully.', isError: false));
        }

        add(FetchTrainingsEvent(true));
      } catch (e) {
        messageBloc.add(AddMessageEvent(
          message: 'An error occurred: ${e.toString()}',
          isError: true,
        ));
        rethrow;
      }
    });

    on<CreateOrUpdateSelectedTrainingEvent>((event, emit) async {
      if (state is! TrainingManagementLoaded) return;
      final currentState = state as TrainingManagementLoaded;

      Training trainingToCreateOrUpdate = currentState.selectedTraining;

      trainingToCreateOrUpdate = trainingToCreateOrUpdate.copyWith(
        name: event.training.name.trim(),
        trainingType: event.training.trainingType,
        objectives: event.training.objectives,
        trainingDays: event.training.trainingDays,
      );

      emit(currentState.copyWith(selectedTraining: trainingToCreateOrUpdate));
    });

    //! Training exercise
    on<CreateOrUpdateExerciseEvent>((event, emit) {
      if (state is! TrainingManagementLoaded) return;
      final currentState = state as TrainingManagementLoaded;

      final exercises =
          List<Exercise>.from(currentState.selectedTraining.exercises);

      final trainingMultisets =
          List<Multiset>.from(currentState.selectedTraining.multisets);

      // Add
      if (event.exercise.widgetKey == null) {
        final tExerciseToAdd = Exercise(
          id: event.exercise.id,
          trainingId: event.exercise.trainingId,
          multisetId: event.exercise.multisetId,
          baseExerciseId: event.exercise.baseExerciseId,
          exerciseType: event.exercise.exerciseType,
          specialInstructions: event.exercise.specialInstructions,
          objectives: event.exercise.objectives,
          targetDistance: event.exercise.targetDistance,
          targetDuration: event.exercise.targetDuration,
          targetPace: event.exercise.targetPace,
          isTargetPaceSelected: event.exercise.isTargetPaceSelected,
          sets: event.exercise.sets,
          isSetsInReps: event.exercise.isSetsInReps,
          minReps: event.exercise.minReps,
          maxReps: event.exercise.maxReps,
          duration: event.exercise.duration,
          setRest: event.exercise.setRest,
          exerciseRest: event.exercise.exerciseRest,
          isAutoStart: event.exercise.isAutoStart,
          position: exercises.length + trainingMultisets.length,
          widgetKey: uuid.v4(),
          runType: event.exercise.runType,
          intensity: event.exercise.intensity,
        );

        exercises.add(tExerciseToAdd);
      }
      // Update
      else {
        final index = exercises.indexWhere(
            (exercise) => exercise.widgetKey == event.exercise.widgetKey);
        exercises[index] = event.exercise;
      }

      final updatedTraining =
          currentState.selectedTraining.copyWith(exercises: exercises);

      emit(currentState.copyWith(selectedTraining: updatedTraining));
    });

    on<RemoveExerciseEvent>((event, emit) {
      if (state is! TrainingManagementLoaded) return;
      final currentState = state as TrainingManagementLoaded;
      final exercises = List<Exercise>.from(
        currentState.selectedTraining.exercises,
      );
      exercises
          .removeWhere((exercise) => exercise.widgetKey == event.exerciseKey);

      final exercisesAndMultisetsList = [
        ...currentState.selectedTraining.exercises
            .map((e) => {'type': 'exercise', 'data': e}),
        ...currentState.selectedTraining.multisets
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
            (item['data'] as Exercise).widgetKey == event.exerciseKey;
      });
      combinedList.removeWhere((item) {
        return item['type'] == 'multiset' &&
            (item['data'] as Multiset).widgetKey == event.exerciseKey;
      });

      // Update positions for exercises
      final updatedExercises =
          combinedList.where((item) => item['type'] == 'exercise').map((item) {
        final exercise = item['data'] as Exercise;
        final newPosition = combinedList.indexOf(item);
        return exercise.copyWith(position: newPosition);
      }).toList();

      final updatedMultisets =
          combinedList.where((item) => item['type'] == 'multiset').map((item) {
        final multiset = item['data'] as Multiset;
        final newPosition = combinedList.indexOf(item);
        return multiset.copyWith(position: newPosition);
      }).toList();

      final updatedTraining = currentState.selectedTraining.copyWith(
        exercises: updatedExercises,
        multisets: updatedMultisets,
      );

      emit(currentState.copyWith(selectedTraining: updatedTraining));
    });

    //! Multiset
    on<CreateOrUpdateMultisetEvent>((event, emit) {
      if (state is! TrainingManagementLoaded) return;
      final currentState = state as TrainingManagementLoaded;

      final selectedTraining = currentState.selectedTraining;

      final exercises =
          List<Exercise>.from(currentState.selectedTraining.exercises);
      final trainingMultisets =
          List<Multiset>.from(currentState.selectedTraining.multisets);

      // Add
      if (event.multiset.widgetKey == null) {
        final multisetToAdd = Multiset(
          id: event.multiset.id,
          trainingId: event.multiset.trainingId,
          sets: event.multiset.sets,
          setRest: event.multiset.setRest,
          multisetRest: event.multiset.multisetRest,
          specialInstructions: event.multiset.specialInstructions,
          objectives: event.multiset.objectives,
          position: exercises.length + trainingMultisets.length,
          widgetKey: uuid.v4(),
        );

        trainingMultisets.add(multisetToAdd);
      }
      // Update
      else {
        final index = trainingMultisets.indexWhere(
            (multiset) => multiset.widgetKey == event.multiset.widgetKey);
        trainingMultisets[index] = event.multiset;
      }

      emit(currentState.copyWith(
          selectedTraining:
              selectedTraining.copyWith(multisets: trainingMultisets)));
    });

    on<CreateOrUpdateMultisetExerciseEvent>((event, emit) {
      if (state is! TrainingManagementLoaded) return;
      final currentState = state as TrainingManagementLoaded;

      final updatedExercises = List<Exercise>.from(
        currentState.selectedTraining.exercises,
      );

      final multisetExercises = currentState.selectedTraining.exercises
          .where((e) => e.multisetKey == event.multisetKey)
          .toList();

      // Add
      if (event.exercise.multisetKey == null) {
        final tExerciseToAdd = Exercise(
          id: event.exercise.id,
          trainingId: event.exercise.trainingId,
          multisetId: event.exercise.multisetId,
          baseExerciseId: event.exercise.baseExerciseId,
          exerciseType: event.exercise.exerciseType,
          specialInstructions: event.exercise.specialInstructions,
          objectives: event.exercise.objectives,
          targetDistance: event.exercise.targetDistance,
          targetDuration: event.exercise.targetDuration,
          targetPace: event.exercise.targetPace,
          isTargetPaceSelected: event.exercise.isTargetPaceSelected,
          sets: event.exercise.sets,
          isSetsInReps: event.exercise.isSetsInReps,
          minReps: event.exercise.minReps,
          maxReps: event.exercise.maxReps,
          duration: event.exercise.duration,
          setRest: event.exercise.setRest,
          exerciseRest: event.exercise.exerciseRest,
          isAutoStart: event.exercise.isAutoStart,
          position: multisetExercises.length,
          widgetKey: uuid.v4(),
          runType: event.exercise.runType,
          intensity: event.exercise.intensity,
          multisetKey: event.multisetKey,
        );
        updatedExercises.add(tExerciseToAdd);
      }

      // Update
      else {
        final index = updatedExercises.indexWhere(
            (exercise) => exercise.widgetKey == event.exercise.widgetKey);
        updatedExercises[index] = event.exercise;
      }

      final updatedTraining = currentState.selectedTraining.copyWith(
        exercises: updatedExercises,
      );

      emit(currentState.copyWith(selectedTraining: updatedTraining));
    });

    on<RemoveMultisetExerciseEvent>((event, emit) {
      if (state is! TrainingManagementLoaded) return;
      final currentState = state as TrainingManagementLoaded;

      final updatedExercises = currentState.selectedTraining.exercises
          .where((e) => e.multisetKey != event.multisetKey)
          .toList();

      final multisetExercises = currentState.selectedTraining.exercises
          .where((e) => e.multisetKey == event.multisetKey)
          .toList();

      multisetExercises
          .removeWhere((exercise) => exercise.widgetKey == event.exerciseKey);

      final updatedMultisetExercises = multisetExercises.map((item) {
        final newPosition = multisetExercises.indexOf(item);
        return item.copyWith(position: newPosition);
      });

      updatedExercises.addAll(updatedMultisetExercises);

      final updatedTraining = currentState.selectedTraining.copyWith(
        exercises: updatedExercises,
      );

      emit(currentState.copyWith(selectedTraining: updatedTraining));
    });
  }
}
