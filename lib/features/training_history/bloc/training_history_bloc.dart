import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import '../../../core/database/database_service.dart';
import '../models/history_run_location.dart';

import '../models/history_training.dart';
import '../../../core/enums/enums.dart';
import '../../../injection_container.dart';
import '../models/history_entry.dart';
import '../../../core/messages/bloc/message_bloc.dart';

part 'training_history_event.dart';
part 'training_history_state.dart';

class TrainingHistoryBloc
    extends Bloc<TrainingHistoryEvent, TrainingHistoryState> {
  final MessageBloc messageBloc;

  TrainingHistoryBloc({required this.messageBloc})
      : super(TrainingHistoryInitial()) {
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

        final List<HistoryEntry> fetchedEntries = await sl<DatabaseService>()
            .getHistoryEntriesForPeriod(startDate, endDate);
        final List<RunLocation> fetchedRunLocations =
            await sl<DatabaseService>()
                .getRunLocationsForPeriod(startDate, endDate);

        final locationsByTrainingId =
            groupBy(fetchedRunLocations, (loc) => loc.trainingId);

        final historyTrainings = await HistoryTraining.fromHistoryEntries(
          fetchedEntries,
          locationsByTrainingId: locationsByTrainingId,
        );

        if (state is TrainingHistoryLoaded) {
          final currentState = state as TrainingHistoryLoaded;
          emit(currentState.copyWith(
            historyEntries: fetchedEntries,
            historyTrainings: historyTrainings,
            startDate: startDate,
            endDate: endDate,
          ));
        } else {
          emit(TrainingHistoryLoaded.withDefaultLists(
              historyEntries: fetchedEntries,
              historyTrainings: historyTrainings,
              startDate: startDate,
              endDate: endDate,
              isWeekSelected: event.isWeekSelected));
        }
      } catch (e) {
        messageBloc.add(AddMessageEvent(
            message: 'An error occurred: ${e.toString()}', isError: true));
        rethrow;
      }
    });

    on<CreateOrUpdateHistoryEntry>((event, emit) async {
      try {
        bool hasRecentEntry = false;
        final isUpdate = event.historyEntry.id != 0;

        if (isUpdate) {
          hasRecentEntry = await sl<DatabaseService>()
              .checkIfTrainingHasRecentEntry(event.historyEntry.id!);
        }

        if (isUpdate || hasRecentEntry) {
          sl<DatabaseService>().updateHistoryEntry(event.historyEntry);
        } else {
          sl<DatabaseService>().createHistoryEntry(event.historyEntry);
        }

        add(FetchHistoryEntriesEvent());
      } catch (e) {
        messageBloc.add(AddMessageEvent(
            message: 'An error occurred: ${e.toString()}', isError: true));
        rethrow;
      }
    });

    on<DeleteHistoryEntryEvent>((event, emit) async {
      if (state is! TrainingHistoryLoaded) return;
      try {
        await sl<DatabaseService>().deleteHistoryEntry(event.id);
        add(FetchHistoryEntriesEvent());
      } catch (e) {
        messageBloc.add(AddMessageEvent(
            message: 'An error occurred: ${e.toString()}', isError: true));
        rethrow;
      }
    });

    on<DeleteHistoryTrainingEvent>((event, emit) async {
      if (state is! TrainingHistoryLoaded) return;

      try {
        await sl<DatabaseService>()
            .deleteHistoryEntriesByTrainingId(event.trainingId);
        add(FetchHistoryEntriesEvent());
      } catch (e) {
        messageBloc.add(AddMessageEvent(
            message: 'An error occurred: ${e.toString()}', isError: true));
        rethrow;
      }
    });

    //! History filters
    on<SetNewDateHistoryDateEvent>((event, emit) async {
      if (state is! TrainingHistoryLoaded) return;

      try {
        final currentState = state as TrainingHistoryLoaded;

        final startDate = event.startDate;
        final endDate = currentState.isWeekSelected
            ? startDate
                .add(const Duration(days: 7))
                .subtract(const Duration(seconds: 1))
            : DateTime(startDate.year, startDate.month + 1, 1)
                .subtract(const Duration(seconds: 1));

        final List<HistoryEntry> fetchedEntries = await sl<DatabaseService>()
            .getHistoryEntriesForPeriod(startDate, endDate);

        final List<RunLocation> fetchedRunLocations =
            await sl<DatabaseService>()
                .getRunLocationsForPeriod(startDate, endDate);

        final locationsByTrainingId =
            groupBy(fetchedRunLocations, (loc) => loc.trainingId);

        final historyTrainings = await HistoryTraining.fromHistoryEntries(
          fetchedEntries,
          locationsByTrainingId: locationsByTrainingId,
        );

        emit(currentState.copyWith(
          historyEntries: fetchedEntries,
          historyTrainings: historyTrainings,
          startDate: startDate,
          endDate: endDate,
        ));
      } catch (e) {
        messageBloc.add(AddMessageEvent(
            message: 'An error occurred: ${e.toString()}', isError: true));
        rethrow;
      }
    });

    on<SelectTrainingTypeEvent>((event, emit) async {
      if (state is! TrainingHistoryLoaded) return;
      final currentState = state as TrainingHistoryLoaded;

      final selectedTrainingTypes = currentState.selectedTrainingTypes;
      selectedTrainingTypes[event.trainingType] = event.isSelected;

      emit(currentState.copyWith(selectedTrainingTypes: selectedTrainingTypes));
    });

    on<SelectHistoryTrainingEntryEvent>((event, emit) async {
      if (state is! TrainingHistoryLoaded) return;
      final currentState = state as TrainingHistoryLoaded;

      print(event.historyTraining);

      emit(currentState.copyWith(selectedTrainingEntry: event.historyTraining));
    });
  }
}
