import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import '../../../core/database/object_box.dart';
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

        final fetchedEntries =
            sl<ObjectBox>().getHistoryEntriesForPeriod(startDate, endDate);
        final fetchedRunLocations =
            sl<ObjectBox>().getRunLocationsForPeriod(startDate, endDate);

        final locationsByTrainingId =
            groupBy(fetchedRunLocations, (loc) => loc.linkedTrainingId);

        final historyTrainings = HistoryTraining.fromHistoryEntries(
          fetchedEntries,
          locationsBylinkedTrainingId: locationsByTrainingId,
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
      }
    });

    on<CreateOrUpdateHistoryEntry>((event, emit) async {
      try {
        bool hasRecentEntry = false;
        final isUpdate = event.historyEntry.id != 0;

        if (isUpdate) {
          hasRecentEntry = sl<ObjectBox>()
              .checkIfTrainingHasRecentEntry(event.historyEntry.id);
        }

        if (isUpdate || hasRecentEntry) {
          sl<ObjectBox>().updateHistoryEntry(event.historyEntry);
        } else {
          sl<ObjectBox>().createHistoryEntry(event.historyEntry);
        }

        add(FetchHistoryEntriesEvent());
      } catch (e) {
        messageBloc.add(AddMessageEvent(
            message: 'An error occurred: ${e.toString()}', isError: true));
      }
    });

    on<DeleteHistoryEntryEvent>((event, emit) async {
      if (state is! TrainingHistoryLoaded) return;
      try {
        sl<ObjectBox>().deleteHistoryEntry(event.id);
        add(FetchHistoryEntriesEvent());
      } catch (e) {
        messageBloc.add(AddMessageEvent(
            message: 'An error occurred: ${e.toString()}', isError: true));
      }
    });

    on<DeleteHistoryTrainingEvent>((event, emit) async {
      if (state is! TrainingHistoryLoaded) return;

      try {
        sl<ObjectBox>().deleteHistoryEntriesForTrainingId(event.trainingId);
        add(FetchHistoryEntriesEvent());
      } catch (e) {
        messageBloc.add(AddMessageEvent(
            message: 'An error occurred: ${e.toString()}', isError: true));
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

        final fetchedEntries =
            sl<ObjectBox>().getHistoryEntriesForPeriod(startDate, endDate);
        final fetchedRunLocations =
            sl<ObjectBox>().getRunLocationsForPeriod(startDate, endDate);

        final locationsByTrainingId =
            groupBy(fetchedRunLocations, (loc) => loc.linkedTrainingId);

        final historyTrainings = HistoryTraining.fromHistoryEntries(
          fetchedEntries,
          locationsBylinkedTrainingId: locationsByTrainingId,
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

      emit(currentState.copyWith(selectedTrainingEntry: event.historyTraining));
    });
  }
}
