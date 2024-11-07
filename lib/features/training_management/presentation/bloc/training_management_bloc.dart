import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:my_fitness_tracker/core/error/failures.dart';
import 'package:my_fitness_tracker/core/messages/bloc/message_bloc.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/training.dart';
import 'package:my_fitness_tracker/features/training_management/domain/usecases/fetch_trainings.dart';

part 'training_management_event.dart';
part 'training_management_state.dart';

final String databaseFailureMessage = tr('message_database_failure');
final String invalidNameFailureMessage = 'ERROR';

class TrainingManagementBloc
    extends Bloc<TrainingManagementEvent, TrainingManagementState> {
  final FetchTrainings fetchTrainings;
  final MessageBloc messageBloc;
  TrainingManagementBloc(
      {required this.fetchTrainings, required this.messageBloc})
      : super(TrainingManagementInitial()) {
    on<FetchTrainingsEvent>((event, emit) async {
      final result = await fetchTrainings(null);

      result.fold(
        (failure) => messageBloc.add(AddMessageEvent(
            message: _mapFailureToMessage(failure), isError: true)),
        (trainings) {
          emit(TrainingsLoaded(trainings: trainings));
        },
      );
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
