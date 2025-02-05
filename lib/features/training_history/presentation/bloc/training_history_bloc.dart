import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:my_fitness_tracker/features/training_history/domain/entities/history_training.dart';
import '../../domain/entities/history_entry.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/messages/bloc/message_bloc.dart';
import '../../domain/usecases/create_history_entry.dart' as create;
import '../../domain/usecases/delete_history_entry.dart' as delete;
import '../../domain/usecases/fetch_history_entries.dart' as fetch;
import '../../domain/usecases/get_history_entry.dart' as get_h;
import '../../domain/usecases/update_history_entry.dart' as update;
import '../../domain/usecases/check_recent_entry.dart' as recent;
import '../../domain/usecases/fetch_history_run_locations.dart' as fetch_rl;

part 'training_history_event.dart';
part 'training_history_state.dart';

final String databaseFailureMessage = tr('message_database_failure');

class TrainingHistoryBloc
    extends Bloc<TrainingHistoryEvent, TrainingHistoryState> {
  final create.CreateHistoryEntry createHistoryEntry;
  final fetch.FetchHistoryEntries fetchHistoryEntries;
  final update.UpdateHistoryEntry updateHistoryEntry;
  final delete.DeleteHistoryEntry deleteHistoryEntry;
  final get_h.GetHistoryEntry getHistoryEntry;
  final recent.CheckRecentEntry checkRecentEntry;
  final fetch_rl.FetchHistoryRunLocations fetchHistoryRunLocations;
  final MessageBloc messageBloc;

  TrainingHistoryBloc({
    required this.createHistoryEntry,
    required this.fetchHistoryEntries,
    required this.updateHistoryEntry,
    required this.deleteHistoryEntry,
    required this.getHistoryEntry,
    required this.checkRecentEntry,
    required this.fetchHistoryRunLocations,
    required this.messageBloc,
  }) : super(TrainingHistoryInitial()) {
    on<FetchHistoryEntriesEvent>((event, emit) async {
      final startDate = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day - DateTime.now().weekday + 1,
      );
      final endDate = DateTime.now()
          .subtract(Duration(days: DateTime.now().weekday - 1))
          .add(const Duration(days: 6));

      final fetchedEntries =
          await fetchHistoryEntries(fetch.Params(startDate, endDate));

      fetchedEntries.fold(
        (failure) => messageBloc.add(AddMessageEvent(
            message: _mapFailureToMessage(failure), isError: true)),
        (historyEntries) {
          if (state is TrainingHistoryLoaded) {
            final currentState = state as TrainingHistoryLoaded;
            emit(currentState.copyWith(
              historyEntries: historyEntries,
              startDate: startDate,
              endDate: endDate,
            ));
          } else {
            emit(TrainingHistoryLoaded(
              historyEntries: historyEntries,
              historyTrainings: const [],
              startDate: startDate,
              endDate: endDate,
            ));
          }
        },
      );

      add(FetchHistoryTrainingsEvent());
    });

    on<FetchHistoryTrainingsEvent>((event, emit) async {
      if (state is TrainingHistoryLoaded) {
        final currentState = state as TrainingHistoryLoaded;

        final historyEntries = currentState.historyEntries;

        final result = await fetchHistoryRunLocations(null);

        result.fold(
          (failure) => messageBloc.add(AddMessageEvent(
              message: _mapFailureToMessage(failure), isError: true)),
          (runLocations) {
            final locationsByTrainingId =
                groupBy(runLocations, (loc) => loc.trainingId!);

            final trainings = HistoryTraining.fromHistoryEntries(
              historyEntries,
              locationsByTrainingId: locationsByTrainingId,
            );
            emit(currentState.copyWith(historyTrainings: trainings));
          },
        );
      }
    });

    on<CreateOrUpdateHistoryEntry>((event, emit) async {
      if (state is TrainingHistoryLoaded) {
        final currentState = state as TrainingHistoryLoaded;
        bool hasRecentEntry = false;

        if (event.historyEntry.id != null) {
          final checkResult =
              await checkRecentEntry(recent.Params(event.historyEntry.id!));
          checkResult.fold((failure) {
            messageBloc.add(AddMessageEvent(
                message: _mapFailureToMessage(failure), isError: true));
          }, (result) {
            hasRecentEntry = result;
          });
        }

        final result = event.historyEntry.id != null || hasRecentEntry
            ? await updateHistoryEntry(update.Params(event.historyEntry))
            : await createHistoryEntry(create.Params(event.historyEntry));

        result.fold(
          (failure) {
            messageBloc.add(AddMessageEvent(
                message: _mapFailureToMessage(failure), isError: true));
          },
          (result) {
            final updatedHistoryEntries =
                List<HistoryEntry>.from(currentState.historyEntries);
            if (event.historyEntry.id != null && hasRecentEntry) {
              final entryIndex = updatedHistoryEntries
                  .indexWhere((el) => el.id == event.historyEntry.id);
              updatedHistoryEntries[entryIndex] = result;
            } else {
              updatedHistoryEntries.add(result);
            }

            emit(currentState.copyWith(historyEntries: updatedHistoryEntries));
          },
        );
      }

      add(FetchHistoryEntriesEvent());
    });

    on<DeleteHistoryEntryEvent>((event, emit) async {
      if (state is TrainingHistoryLoaded) {
        final currentState = state as TrainingHistoryLoaded;

        final result = await deleteHistoryEntry(
          delete.Params(event.id),
        );

        result.fold(
          (failure) {
            messageBloc.add(AddMessageEvent(
                message: _mapFailureToMessage(failure), isError: true));
          },
          (result) {
            final updatedHistoryEntries =
                List<HistoryEntry>.from(currentState.historyEntries)
                  ..removeWhere((el) => el.id == event.id);
            emit(currentState.copyWith(historyEntries: updatedHistoryEntries));
          },
        );
        add(FetchHistoryEntriesEvent());
      }
    });

    on<DeleteHistoryTrainingEvent>((event, emit) async {
      if (state is TrainingHistoryLoaded) {
        final currentState = state as TrainingHistoryLoaded;

        final updatedHistoryEntries =
            List<HistoryEntry>.from(currentState.historyEntries);

        for (var entry in event.historyTraining.historyEntries) {
          final result = await deleteHistoryEntry(
            delete.Params(entry.id!),
          );

          result.fold(
            (failure) {
              messageBloc.add(AddMessageEvent(
                  message: _mapFailureToMessage(failure), isError: true));
            },
            (result) {
              updatedHistoryEntries.removeWhere((el) => el.id == entry.id!);
            },
          );
        }

        emit(currentState.copyWith(historyEntries: updatedHistoryEntries));
        add(FetchHistoryEntriesEvent());
      }
    });

    //! History filters
    on<SetNewDateHistoryDateEvent>((event, emit) async {
      if (state is TrainingHistoryLoaded) {
        final currentState = state as TrainingHistoryLoaded;

        final endDate = event.isWeekSelected
            ? event.startDate
                .add(const Duration(days: 7))
                .subtract(const Duration(seconds: 1))
            : DateTime(event.startDate.year, event.startDate.month + 1, 1)
                .subtract(const Duration(seconds: 1));

        final fetchedEntries =
            await fetchHistoryEntries(fetch.Params(event.startDate, endDate));

        fetchedEntries.fold(
          (failure) => messageBloc.add(AddMessageEvent(
              message: _mapFailureToMessage(failure), isError: true)),
          (historyEntries) {
            currentState.copyWith(historyEntries: historyEntries);
            emit(TrainingHistoryLoaded(
              historyEntries: historyEntries,
              historyTrainings: const [],
              startDate: event.startDate,
              endDate: endDate,
            ));
          },
        );

        add(FetchHistoryTrainingsEvent());
      }
    });

    on<SetDefaultHistoryDateEvent>((event, emit) async {
      if (state is TrainingHistoryLoaded) {
        final currentState = state as TrainingHistoryLoaded;

        final startDate = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day - DateTime.now().weekday + 1,
        );
        final endDate = DateTime.now()
            .subtract(Duration(days: DateTime.now().weekday - 1))
            .add(const Duration(days: 6));

        final fetchedEntries =
            await fetchHistoryEntries(fetch.Params(startDate, endDate));

        fetchedEntries.fold(
          (failure) => messageBloc.add(AddMessageEvent(
              message: _mapFailureToMessage(failure), isError: true)),
          (historyEntries) {
            currentState.copyWith(historyEntries: historyEntries);
            emit(TrainingHistoryLoaded(
              historyEntries: historyEntries,
              historyTrainings: const [],
              startDate: startDate,
              endDate: endDate,
            ));
          },
        );

        add(FetchHistoryTrainingsEvent());
      }
    });

    on<SelectHistoryTrainingEntryEvent>((event, emit) async {
      if (state is TrainingHistoryLoaded) {
        final currentState = state as TrainingHistoryLoaded;

        emit(currentState.copyWith(
            selectedTrainingEntry: event.historyTraining));
      }
    });
  }
}

String _mapFailureToMessage(Failure failure) {
  if (failure is DatabaseFailure) {
    return databaseFailureMessage;
  } else {
    return tr('message_unexpected_error');
  }
}
