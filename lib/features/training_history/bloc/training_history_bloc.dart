import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:my_fitness_tracker/features/training_history/models/history_period_stats.dart';

import '../../../core/database/database_service.dart';
import '../../../core/enums/enums.dart';
import '../../../core/messages/toast.dart';
import '../../../helper_functions.dart';
import '../../../injection_container.dart';
import '../../active_training/bloc/active_training_bloc.dart';
import '../../base_exercise_management/models/base_exercise.dart';
import '../../training_management/models/training.dart';
import '../models/history_entry.dart';
import '../models/history_training.dart';

part 'training_history_event.dart';
part 'training_history_state.dart';

class TrainingHistoryBloc
    extends Bloc<TrainingHistoryEvent, TrainingHistoryState> {
  TrainingHistoryBloc() : super(TrainingHistoryInitial()) {
    on<FetchHistoryEntriesEvent>((event, emit) async {
      try {
        final startDate = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day - DateTime.now().weekday + 1,
        );
        final endDate = DateTime.now()
            .subtract(Duration(days: DateTime.now().weekday - 1))
            .add(const Duration(days: 6));

        final historyTrainings = await getHistoryTrainings(
            startDate: startDate,
            endDate: endDate,
            trainingTypes: null,
            baseExerciseId: null,
            trainingId: null);

        if (state is TrainingHistoryLoaded) {
          final currentState = state as TrainingHistoryLoaded;
          emit(currentState.copyWith(
            historyTrainings: historyTrainings,
            periodStats: PeriodStats.fromTrainings(historyTrainings),
            startDate: startDate,
            endDate: endDate,
          ));
        } else {
          emit(TrainingHistoryLoaded.withDefaultLists(
              historyTrainings: historyTrainings,
              periodStats: PeriodStats.fromTrainings(historyTrainings),
              startDate: startDate,
              endDate: endDate,
              isWeekSelected: event.isWeekSelected));
        }
      } catch (e) {
        showToastMessage(
          message: e.toString(),
          isSuccess: false,
          isLog: true,
          logLevel: LogLevel.error,
          logFunction: 'FetchHistoryEntriesEvent',
        );
      }
    });

    on<CreateOrUpdateHistoryEntry>((event, emit) async {
      try {
        HistoryEntry? historyEntry;

        if (event.historyEntry != null) {
          historyEntry = event.historyEntry;
        } else if (event.timerState != null) {
          final timerState = event.timerState!;

          final registeredId = await sl<DatabaseService>()
              .getRegisteredHistoryEntryId(
                  exerciseId: timerState.exerciseId,
                  setNumber: timerState.setNumber,
                  trainingId: timerState.trainingId);

          final listOfExercises =
              (sl<ActiveTrainingBloc>().state as ActiveTrainingLoaded)
                  .activeTraining!
                  .exercises;

          final matchingExercise = listOfExercises
              .firstWhere((exercise) => exercise.id == timerState.exerciseId);

          final duration = timerState.isCountDown
              ? timerState.countDownValue - timerState.timerValue
              : timerState.timerValue;

          int cals = getCalories(
            weight: event.weight,
            intensity: matchingExercise.intensity,
            duration: duration,
          );

          historyEntry = HistoryEntry(
              id: registeredId,
              trainingId: timerState.trainingId,
              exerciseId: timerState.exerciseId,
              trainingVersionId: timerState.trainingVersionId,
              setNumber: timerState.setNumber,
              intervalNumber: timerState.intervalNumber,
              date: DateTime.now(),
              reps: event.reps,
              weight: event.weight,
              duration: duration,
              distance: timerState.distance.toInt(),
              pace: timerState.pace.toInt(),
              calories: cals);
        }

        bool hasRecentEntry = false;
        final isUpdate = historyEntry?.id != null;

        if (isUpdate) {
          hasRecentEntry = await sl<DatabaseService>()
                  .checkIfTrainingHasRecentEntry(historyEntry!.id!) ??
              false;
        }

        if (isUpdate || hasRecentEntry) {
          await sl<DatabaseService>().updateHistoryEntry(historyEntry!);
        } else {
          await sl<DatabaseService>().createHistoryEntry(historyEntry!);
        }

        add(FetchHistoryEntriesEvent());
      } catch (e) {
        showToastMessage(
          message: e.toString(),
          isSuccess: false,
          isLog: true,
          logLevel: LogLevel.error,
          logFunction: 'CreateOrUpdateHistoryEntry',
        );
      }
    });

    on<CreateOrUpdateHistoryAfterwardsEntry>((event, emit) async {
      try {
        final historyEntry = event.historyEntry;

        bool hasRecentEntry = false;
        final isUpdate = historyEntry.id != null;

        if (isUpdate) {
          hasRecentEntry = await sl<DatabaseService>()
                  .checkIfTrainingHasRecentEntry(historyEntry.id!) ??
              false;
        }

        if (isUpdate || hasRecentEntry) {
          await sl<DatabaseService>().updateHistoryEntry(historyEntry);
        } else {
          final lastDate = await sl<DatabaseService>()
              .getLastEntryDate(historyEntry.trainingVersionId);
          final updatedHistoryEntry = historyEntry.copyWith(date: lastDate);

          await sl<DatabaseService>().createHistoryEntry(updatedHistoryEntry);
        }

        add(FetchHistoryEntriesEvent());
      } catch (e) {
        showToastMessage(
          message: e.toString(),
          isSuccess: false,
          isLog: true,
          logLevel: LogLevel.error,
          logFunction: 'CreateOrUpdateHistoryAfterwardsEntry',
        );
      }
    });

    on<DeleteHistoryEntryEvent>((event, emit) async {
      if (state is! TrainingHistoryLoaded) return;
      try {
        await sl<DatabaseService>().deleteHistoryEntry(event.id);
        add(FetchHistoryEntriesEvent());
      } catch (e) {
        showToastMessage(
          message: e.toString(),
          isSuccess: false,
          isLog: true,
          logLevel: LogLevel.error,
          logFunction: 'DeleteHistoryEntryEvent',
        );
      }
    });

    on<DeleteHistoryTrainingEvent>((event, emit) async {
      if (state is! TrainingHistoryLoaded) return;

      try {
        await sl<DatabaseService>()
            .deleteHistoryEntriesByTrainingId(event.trainingId);
        add(FetchHistoryEntriesEvent());
      } catch (e) {
        showToastMessage(
          message: e.toString(),
          isSuccess: false,
          isLog: true,
          logLevel: LogLevel.error,
          logFunction: 'DeleteHistoryTrainingEvent',
        );
      }
    });

    //! History filters
    on<SetNewDateHistoryDateEvent>((event, emit) async {
      if (state is! TrainingHistoryLoaded) return;

      try {
        final currentState = state as TrainingHistoryLoaded;

        final startDate = DateTime(
            event.startDate.year, event.startDate.month, event.startDate.day);
        final endDate = currentState.isWeekSelected
            ? startDate
                .add(const Duration(days: 7))
                .subtract(const Duration(seconds: 1))
            : DateTime(startDate.year, startDate.month + 1, 1)
                .subtract(const Duration(seconds: 1));

        final historyTrainings = await getHistoryTrainings(
            startDate: startDate,
            endDate: endDate,
            trainingTypes: null,
            baseExerciseId: null,
            trainingId: null);

        emit(currentState.copyWith(
          historyTrainings: historyTrainings,
          periodStats: PeriodStats.fromTrainings(historyTrainings),
          startDate: startDate,
          endDate: endDate,
        ));
      } catch (e) {
        showToastMessage(
          message: e.toString(),
          isSuccess: false,
          isLog: true,
          logLevel: LogLevel.error,
          logFunction: 'SetNewDateHistoryDateEvent',
        );
      }
    });

    on<SelectHistoryTrainingEntryEvent>((event, emit) async {
      if (state is! TrainingHistoryLoaded) return;
      final currentState = state as TrainingHistoryLoaded;

      final selectedTraining = await sl<DatabaseService>()
          .getTrainingByVersionId(event.historyTraining.trainingVersionId);

      emit(currentState.copyWith(
          selectedTrainingEntry: event.historyTraining,
          selectedTraining: selectedTraining));
    });

    //! Stats

    on<SelectTrainingTypeEvent>((event, emit) async {
      if (state is! TrainingHistoryLoaded) return;
      final currentState = state as TrainingHistoryLoaded;

      final selectedTrainingTypes = currentState.selectedTrainingTypes;
      selectedTrainingTypes[event.trainingType] = event.isSelected;

      final startDate = currentState.startDate;
      final endDate = currentState.endDate;
      final trainingTypes = selectedTrainingTypes.entries
          .where((e) => e.value == true)
          .map((e) => e.key)
          .toList();
      final baseExerciseId = currentState.selectedStatsBaseExercise?.id;
      final trainingId = currentState.selectedStatsTraining?.id;

      final historyTrainings = await getHistoryTrainings(
          startDate: startDate,
          endDate: endDate,
          trainingTypes: trainingTypes,
          baseExerciseId: baseExerciseId,
          trainingId: trainingId);

      emit(currentState.copyWith(
          historyTrainings: historyTrainings,
          periodStats: PeriodStats.fromTrainings(historyTrainings),
          selectedTrainingTypes: selectedTrainingTypes,
          isExercisesSelected: false));
    });

    on<SelectExercisesEvent>((event, emit) async {
      if (state is! TrainingHistoryLoaded) return;
      final currentState = state as TrainingHistoryLoaded;

      final selectedTrainingTypes =
          createMapWithDefaultValues(TrainingType.values);

      final startDate = currentState.startDate;
      final endDate = currentState.endDate;
      final trainingTypes = selectedTrainingTypes.entries
          .where((e) => e.value == true)
          .map((e) => e.key)
          .toList();
      final baseExerciseId = currentState.selectedStatsBaseExercise?.id;
      final trainingId = currentState.selectedStatsTraining?.id;

      final historyTrainings = await getHistoryTrainings(
          startDate: startDate,
          endDate: endDate,
          trainingTypes: trainingTypes,
          baseExerciseId: baseExerciseId,
          trainingId: trainingId);

      emit(currentState.copyWith(
          historyTrainings: historyTrainings,
          periodStats: PeriodStats.fromTrainings(historyTrainings),
          selectedTrainingTypes: selectedTrainingTypes,
          isExercisesSelected: !currentState.isExercisesSelected));
    });

    on<SelectBaseExerciseEvent>((event, emit) async {
      if (state is! TrainingHistoryLoaded) return;
      final currentState = state as TrainingHistoryLoaded;

      final startDate = currentState.startDate;
      final endDate = currentState.endDate;
      final trainingTypes = currentState.selectedTrainingTypes.entries
          .where((e) => e.value == true)
          .map((e) => e.key)
          .toList();
      final baseExerciseId = event.baseExercise?.id;
      final trainingId = currentState.selectedStatsTraining?.id;

      final historyTrainings = await getHistoryTrainings(
          startDate: startDate,
          endDate: endDate,
          trainingTypes: trainingTypes,
          baseExerciseId: baseExerciseId,
          trainingId: trainingId);

      emit(currentState.copyWith(
        historyTrainings: historyTrainings,
        periodStats: PeriodStats.fromTrainings(historyTrainings),
        selectedStatsBaseExercise: event.baseExercise,
        resetSelectedStatsBaseExercise: event.baseExercise == null,
      ));
    });

    on<SelectTrainingEvent>((event, emit) async {
      if (state is! TrainingHistoryLoaded) return;
      final currentState = state as TrainingHistoryLoaded;

      final startDate = currentState.startDate;
      final endDate = currentState.endDate;
      final trainingTypes = currentState.selectedTrainingTypes.entries
          .where((e) => e.value == true)
          .map((e) => e.key)
          .toList();
      final baseExerciseId = currentState.selectedStatsBaseExercise?.id;
      final trainingId = event.training?.id;

      final historyTrainings = await getHistoryTrainings(
          startDate: startDate,
          endDate: endDate,
          trainingTypes: trainingTypes,
          baseExerciseId: baseExerciseId,
          trainingId: trainingId);

      emit(currentState.copyWith(
        historyTrainings: historyTrainings,
        periodStats: PeriodStats.fromTrainings(historyTrainings),
        selectedStatsTraining: event.training,
        resetSelectedStatsTraining: event.training == null,
      ));
    });
  }
}

Future<List<HistoryTraining>> getHistoryTrainings({
  required DateTime startDate,
  required DateTime endDate,
  required List<TrainingType>? trainingTypes,
  required int? baseExerciseId,
  required int? trainingId,
}) async {
  try {
    // Récupère les history entries filtrées
    final fetchedEntries =
        await sl<DatabaseService>().getFilteredHistoryEntries(
      startDate: startDate,
      endDate: endDate,
      trainingTypes: trainingTypes,
      baseExerciseId: baseExerciseId,
      trainingId: trainingId,
    );

    // Récupère les run locations filtrées
    final fetchedRunLocations =
        await sl<DatabaseService>().getFilteredRunLocations(
      startDate: startDate,
      endDate: endDate,
      trainingTypes: trainingTypes,
      baseExerciseId: baseExerciseId,
      trainingId: trainingId,
    );

    // Regroupe les run locations par trainingId
    final locationsByTrainingId =
        groupBy(fetchedRunLocations, (loc) => loc.trainingId);

    // Construit et retourne la liste de HistoryTraining à partir des history entries et du regroupement
    final historyTrainings = await HistoryTraining.fromHistoryEntries(
      fetchedEntries,
      locationsByTrainingId: locationsByTrainingId,
    );

    return historyTrainings;
  } catch (e) {
    showToastMessage(
      message: e.toString(),
      isSuccess: false,
      isLog: true,
      logLevel: LogLevel.error,
      logFunction: 'getHistoryTrainings',
    );
    return [];
  }
}
