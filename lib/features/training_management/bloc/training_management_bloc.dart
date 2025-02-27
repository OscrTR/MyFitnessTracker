import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../../core/messages/toast.dart';
import '../../../core/database/database_service.dart';
import 'package:uuid/uuid.dart';

import '../../../core/enums/enums.dart';
import '../../../core/notification_service.dart';
import '../../../injection_container.dart';
import '../../base_exercise_management/models/base_exercise.dart';
import '../../settings/bloc/settings_bloc.dart';
import '../models/multiset.dart';
import '../models/training.dart';
import '../models/exercise.dart';

part 'training_management_event.dart';
part 'training_management_state.dart';

const uuid = Uuid();

class TrainingManagementBloc
    extends Bloc<TrainingManagementEvent, TrainingManagementState> {
  TrainingManagementBloc() : super(TrainingManagementInitial()) {
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
        showToastMessage(message: 'An error occurred: ${e.toString()}');
      }
    });

    on<DeleteTrainingEvent>((event, emit) async {
      if (state is! TrainingManagementLoaded) return;
      final currentState = state as TrainingManagementLoaded;
      try {
        await sl<DatabaseService>().deleteTraining(event.id);
        await _compareTrainingDays();
        emit(currentState.copyWith(resetSelectedTraining: true));
        showToastMessage(message: tr('message_training_deletion_success'));
        add(FetchTrainingsEvent());
      } catch (e) {
        showToastMessage(message: 'An error occurred: ${e.toString()}');
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
        showToastMessage(message: 'An error occurred: ${e.toString()}');
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
          showToastMessage(message: tr('message_training_update_success'));
        } else {
          await sl<DatabaseService>().createTraining(event.training);
          showToastMessage(message: tr('message_training_creation_success'));
        }

        await _compareTrainingDays();

        add(FetchTrainingsEvent(true));
      } catch (e) {
        showToastMessage(message: 'An error occurred: ${e.toString()}');
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

    //! Exercise
    on<CreateOrUpdateExerciseEvent>((event, emit) {
      if (state is! TrainingManagementLoaded) return;
      final currentState = state as TrainingManagementLoaded;

      final exercises =
          List<Exercise>.from(currentState.selectedTraining.exercises);

      final baseExercises =
          List<BaseExercise>.from(currentState.selectedTraining.baseExercises);

      // Add exercise
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
          targetSpeed: event.exercise.targetSpeed,
          isTargetPaceSelected: event.exercise.isTargetPaceSelected,
          sets: event.exercise.sets,
          isSetsInReps: event.exercise.isSetsInReps,
          minReps: event.exercise.minReps,
          maxReps: event.exercise.maxReps,
          duration: event.exercise.duration,
          setRest: event.exercise.setRest,
          exerciseRest: event.exercise.exerciseRest,
          isAutoStart: event.exercise.isAutoStart,
          position:
              exercises.length + currentState.selectedTraining.multisets.length,
          widgetKey: uuid.v4(),
          runType: event.exercise.runType,
          intensity: event.exercise.intensity,
        );

        exercises.add(tExerciseToAdd);
      }
      // Update exercise
      else {
        final index = exercises.indexWhere(
            (exercise) => exercise.widgetKey == event.exercise.widgetKey);
        exercises[index] = event.exercise;
      }

      // Update base exercises
      if (event.baseExercise != null &&
          !baseExercises.any((b) => b.id == event.baseExercise!.id)) {
        baseExercises.add(event.baseExercise!);
      }

      // Update training
      final updatedTraining = currentState.selectedTraining
          .copyWith(exercises: exercises, baseExercises: baseExercises);

      emit(currentState.copyWith(selectedTraining: updatedTraining));
    });

    on<RemoveExerciseEvent>((event, emit) {
      if (state is! TrainingManagementLoaded) return;
      final currentState = state as TrainingManagementLoaded;

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

      // Remove exercise
      combinedList.removeWhere((item) {
        return (item['type'] == 'exercise') &&
            (item['data'] as Exercise).widgetKey == event.exercise.widgetKey;
      });

      // Update positions for exercises
      final updatedExercises =
          combinedList.where((item) => item['type'] == 'exercise').map((item) {
        final exercise = item['data'] as Exercise;
        final newPosition = combinedList.indexOf(item);
        return exercise.copyWith(position: newPosition);
      }).toList();

      // Update position for multisets
      final updatedMultisets =
          combinedList.where((item) => item['type'] == 'multiset').map((item) {
        final multiset = item['data'] as Multiset;
        final newPosition = combinedList.indexOf(item);
        return multiset.copyWith(position: newPosition);
      }).toList();

      final baseExercises =
          List<BaseExercise>.from(currentState.selectedTraining.baseExercises);

      // Remove unused base exercise
      final baseExercise = baseExercises
          .firstWhereOrNull((b) => b.id == event.exercise.baseExerciseId);

      if (baseExercise != null) {
        final exercisesUsingSameBaseExercise = updatedExercises
            .where((e) => e.baseExerciseId == event.exercise.baseExerciseId)
            .toList();

        if (exercisesUsingSameBaseExercise.isEmpty) {
          baseExercises.removeWhere((b) => b.id == baseExercise.id);
        }
      }

      // Update training
      final updatedTraining = currentState.selectedTraining.copyWith(
        exercises: updatedExercises,
        multisets: updatedMultisets,
        baseExercises: baseExercises,
      );

      emit(currentState.copyWith(selectedTraining: updatedTraining));
    });

    //! Multiset
    on<CreateOrUpdateMultisetEvent>((event, emit) {
      if (state is! TrainingManagementLoaded) return;
      final currentState = state as TrainingManagementLoaded;

      final exercises =
          List<Exercise>.from(currentState.selectedTraining.exercises);

      final multisets =
          List<Multiset>.from(currentState.selectedTraining.multisets);

      // Add multiset
      if (event.multiset.widgetKey == null) {
        final multisetToAdd = Multiset(
          id: event.multiset.id,
          trainingId: event.multiset.trainingId,
          sets: event.multiset.sets,
          setRest: event.multiset.setRest,
          multisetRest: event.multiset.multisetRest,
          specialInstructions: event.multiset.specialInstructions,
          objectives: event.multiset.objectives,
          position: exercises.length + multisets.length,
          widgetKey: uuid.v4(),
        );

        multisets.add(multisetToAdd);
      }
      // Update multiset
      else {
        final index = multisets.indexWhere(
            (multiset) => multiset.widgetKey == event.multiset.widgetKey);
        multisets[index] = event.multiset;
      }

      // Update training
      emit(currentState.copyWith(
          selectedTraining:
              currentState.selectedTraining.copyWith(multisets: multisets)));
    });

    on<RemoveMultisetEvent>((event, emit) {
      if (state is! TrainingManagementLoaded) return;
      final currentState = state as TrainingManagementLoaded;

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

      // Remove multiset
      combinedList.removeWhere((item) {
        return item['type'] == 'multiset' &&
            (item['data'] as Multiset).widgetKey == event.multiset.widgetKey;
      });

      // Remove multiset exercises
      combinedList.removeWhere((item) {
        return (item['type'] == 'exercise') &&
            (item['data'] as Exercise).multisetKey == event.multiset.widgetKey;
      });

      // Update positions for exercises
      final updatedExercises =
          combinedList.where((item) => item['type'] == 'exercise').map((item) {
        final exercise = item['data'] as Exercise;
        final newPosition = combinedList.indexOf(item);
        return exercise.copyWith(position: newPosition);
      }).toList();

      // Update position for multisets
      final updatedMultisets =
          combinedList.where((item) => item['type'] == 'multiset').map((item) {
        final multiset = item['data'] as Multiset;
        final newPosition = combinedList.indexOf(item);
        return multiset.copyWith(position: newPosition);
      }).toList();

      final baseExercises =
          List<BaseExercise>.from(currentState.selectedTraining.baseExercises);

      final multisetExercises = currentState.selectedTraining.exercises
          .where((e) => e.multisetKey == event.multiset.widgetKey)
          .toList();

      final multisetBaseExercises = baseExercises
          .where((b) => multisetExercises.any((e) => e.baseExerciseId == b.id))
          .toList();

      // Remove base exercises
      if (multisetBaseExercises.isNotEmpty) {
        for (var baseExercise in multisetBaseExercises) {
          final exercisesUsingSameBaseExercise = updatedExercises
              .where((e) => e.baseExerciseId == baseExercise.id)
              .toList();

          if (exercisesUsingSameBaseExercise.isEmpty) {
            baseExercises.removeWhere((b) => b.id == baseExercise.id);
          }
        }
      }

      // Update training
      final updatedTraining = currentState.selectedTraining.copyWith(
        exercises: updatedExercises,
        multisets: updatedMultisets,
        baseExercises: baseExercises,
      );

      emit(currentState.copyWith(selectedTraining: updatedTraining));
    });

    on<CreateOrUpdateMultisetExerciseEvent>((event, emit) {
      if (state is! TrainingManagementLoaded) return;
      final currentState = state as TrainingManagementLoaded;

      final exercises = List<Exercise>.from(
        currentState.selectedTraining.exercises,
      );

      final multisetExercises = currentState.selectedTraining.exercises
          .where((e) => e.multisetKey == event.multisetKey)
          .toList();

      final baseExercises =
          List<BaseExercise>.from(currentState.selectedTraining.baseExercises);

      // Add exercise
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
          targetSpeed: event.exercise.targetSpeed,
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
        exercises.add(tExerciseToAdd);
      }

      // Update exercise
      else {
        final index = exercises.indexWhere(
            (exercise) => exercise.widgetKey == event.exercise.widgetKey);
        exercises[index] = event.exercise;
      }

      // Update base exercises
      if (event.baseExercise != null &&
          !baseExercises.any((b) => b.id == event.baseExercise!.id)) {
        baseExercises.add(event.baseExercise!);
      }

      // Update training
      final updatedTraining = currentState.selectedTraining.copyWith(
        exercises: exercises,
        baseExercises: baseExercises,
      );

      emit(currentState.copyWith(selectedTraining: updatedTraining));
    });

    on<RemoveMultisetExerciseEvent>((event, emit) {
      if (state is! TrainingManagementLoaded) return;
      final currentState = state as TrainingManagementLoaded;

      final exercises =
          List<Exercise>.from(currentState.selectedTraining.exercises);

      final updatedExercises = currentState.selectedTraining.exercises
          .where((e) => e.multisetKey != event.exercise.multisetKey)
          .toList();

      final baseExercises =
          List<BaseExercise>.from(currentState.selectedTraining.baseExercises);

      final multisetExercises = currentState.selectedTraining.exercises
          .where((e) => e.multisetKey == event.exercise.multisetKey)
          .toList();

      // Delete exercise
      multisetExercises.removeWhere(
          (exercise) => exercise.widgetKey == event.exercise.widgetKey);

      // Supprimer le base exercise du training si aucun autre exercise ne l'utilise
      final baseExercise = baseExercises
          .firstWhereOrNull((b) => b.id == event.exercise.baseExerciseId);

      if (baseExercise != null) {
        final exercisesUsingSameBaseExercise = exercises
            .where((e) => e.baseExerciseId == event.exercise.baseExerciseId)
            .toList();

        if (exercisesUsingSameBaseExercise.isEmpty) {
          baseExercises.removeWhere((b) => b.id == baseExercise.id);
        }
      }

      // Update position
      final updatedMultisetExercises = multisetExercises.map((item) {
        final newPosition = multisetExercises.indexOf(item);
        return item.copyWith(position: newPosition);
      });

      updatedExercises.addAll(updatedMultisetExercises);

      // Update training
      final updatedTraining = currentState.selectedTraining.copyWith(
        exercises: updatedExercises,
      );

      emit(currentState.copyWith(selectedTraining: updatedTraining));
    });
  }
}

Future<void> _compareTrainingDays() async {
  if ((sl<SettingsBloc>().state as SettingsLoaded).isReminderActive) {
    final reminders = await sl<DatabaseService>().getAllReminders();
    final trainings = await sl<DatabaseService>().getAllTrainings();

    final trainingDays = <Day>{};
    for (final training in trainings) {
      for (final trainingDay in training.trainingDays) {
        trainingDays.add(Day.values.firstWhere(
          (day) => day.name == trainingDay.name,
          orElse: () => throw Exception('Invalid training day'),
        ));
      }
    }

    final reminderDays = reminders.map((reminder) => reminder.day).toSet();

    // Trouver les jours présents dans trainingDays mais absents dans reminderDays
    final daysToCreate = trainingDays.difference(reminderDays);

    // Trouver les jours présents dans reminderDays mais absents dans trainingDays
    final daysToDelete = reminderDays.difference(trainingDays);

    // Créer des reminders pour les jours manquants
    for (final day in daysToCreate) {
      if (!reminders.any((d) => d.day == day)) {
        NotificationService.scheduleWeeklyNotification(day: day);
      }
    }

    // Supprimer les reminders pour les jours obsolètes
    for (final day in daysToDelete) {
      for (var reminder in reminders) {
        if (reminder.day == day) {
          await sl<DatabaseService>().deleteReminder(reminder.notificationId);
          await NotificationService.deleteNotification(reminder.notificationId);
        }
      }
    }
  }
}
