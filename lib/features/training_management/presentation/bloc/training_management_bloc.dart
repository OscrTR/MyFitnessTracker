import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/messages/bloc/message_bloc.dart';
import '../../domain/entities/training.dart';
import '../../domain/usecases/fetch_trainings.dart';
import '../widgets/multiset_widget.dart';
import '../widgets/run_widget.dart';

import '../widgets/exercise_widget.dart';

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
    on<FetchTrainingsEvent>((event, emit) async {
      final result = await fetchTrainings(null);
      result.fold(
        (failure) => messageBloc.add(AddMessageEvent(
            message: _mapFailureToMessage(failure), isError: true)),
        (trainings) {
          emit(TrainingManagementLoaded(
              trainings: trainings, nameController: nameController));
        },
      );
    });

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
              currentState.copyWith(
                  selectedTraining: selectedTraining,
                  selectedTrainingType: event.trainingType),
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

    on<UpdateTrainingTypeEvent>((event, emit) {
      if (state is TrainingManagementLoaded) {
        final currentState = state as TrainingManagementLoaded;
        emit(
          currentState.copyWith(
              selectedTrainingType: event.selectedTrainingType),
        );
      }
    });

    on<AddMultisetToSelectedTrainingEvent>((event, emit) {
      if (state is TrainingManagementLoaded) {
        final currentState = state as TrainingManagementLoaded;
        final updatedWidgetList =
            List<Widget>.from(currentState.selectedTrainingWidgetList)
              ..add(const MultisetWidget());
        emit(
          currentState.copyWith(selectedTrainingWidgetList: updatedWidgetList),
        );
      }
    });

    on<AddRunToSelectedTrainingEvent>((event, emit) {
      if (state is TrainingManagementLoaded) {
        final currentState = state as TrainingManagementLoaded;
        final updatedWidgetList =
            List<Widget>.from(currentState.selectedTrainingWidgetList)
              ..add(const RunWidget());
        emit(
          currentState.copyWith(selectedTrainingWidgetList: updatedWidgetList),
        );
      }
    });

    on<AddExerciseToSelectedTrainingEvent>((event, emit) {
      if (state is TrainingManagementLoaded) {
        final currentState = state as TrainingManagementLoaded;
        final updatedWidgetList =
            List<Widget>.from(currentState.selectedTrainingWidgetList)
              ..add(const ExerciseWidget());
        emit(
          currentState.copyWith(selectedTrainingWidgetList: updatedWidgetList),
        );
      }
    });

    on<SaveSelectedTrainingEvent>((event, emit) {
      if (state is TrainingManagementLoaded) {
        final currentState = state as TrainingManagementLoaded;
        print(currentState.selectedTraining);
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
