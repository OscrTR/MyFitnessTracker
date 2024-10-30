import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/messages/bloc/message_bloc.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/usecases/create_exercise.dart' as create;
import '../../domain/usecases/delete_exercise.dart' as delete;
import '../../domain/usecases/fetch_exercises.dart' as fetch;
import '../../domain/usecases/get_exercise.dart' as get_ex;
import '../../domain/usecases/update_exercise.dart' as update;

part 'exercise_management_event.dart';
part 'exercise_management_state.dart';

final String databaseFailureMessage = tr('message_database_failure');
final String invalidExerciseNameFailureMessage =
    tr('message_exercise_creation_name_error');

class ExerciseManagementBloc
    extends Bloc<ExerciseManagementEvent, ExerciseManagementState> {
  final create.CreateExercise createExercise;
  final fetch.FetchExercises fetchExercises;
  final update.UpdateExercise updateExercise;
  final delete.DeleteExercise deleteExercise;
  final get_ex.GetExercise getExercise;
  final MessageBloc messageBloc;

  ExerciseManagementBloc(
      {required this.createExercise,
      required this.fetchExercises,
      required this.updateExercise,
      required this.deleteExercise,
      required this.getExercise,
      required this.messageBloc})
      : super(ExerciseManagementInitial()) {
    on<FetchExercisesEvent>((event, emit) async {
      final result = await fetchExercises(null);

      result.fold(
        (failure) => messageBloc.add(AddMessageEvent(
            message: _mapFailureToMessage(failure), isError: true)),
        (exercises) {
          emit(ExerciseManagementLoaded(exercises: exercises));
        },
      );
    });

    on<GetExerciseEvent>((event, emit) async {
      if (state is ExerciseManagementLoaded) {
        final currentState = state as ExerciseManagementLoaded;
        final result = await getExercise(get_ex.Params(id: event.exerciseId));

        result.fold(
          (failure) {
            messageBloc.add(AddMessageEvent(
                message: _mapFailureToMessage(failure), isError: true));
          },
          (exercise) {
            emit(currentState.copyWith(selectedExercise: exercise));
          },
        );
      }
    });

    on<CreateExerciseEvent>((event, emit) async {
      if (state is ExerciseManagementLoaded) {
        final currentState = state as ExerciseManagementLoaded;

        final result = await createExercise(
          create.Params(
            name: event.name,
            description: event.description,
            imagePath: event.imagePath,
          ),
        );

        result.fold(
          (failure) {
            messageBloc.add(AddMessageEvent(
                message: _mapFailureToMessage(failure), isError: true));
          },
          (result) {
            messageBloc.add(AddMessageEvent(
                message:
                    tr('message_exercise_creation_success', args: [event.name]),
                isError: false));
            final updatedExercises = List<Exercise>.from(currentState.exercises)
              ..add(result);
            emit(currentState.copyWith(exercises: updatedExercises));
          },
        );
      }
    });

    on<UpdateExerciseEvent>((event, emit) async {
      if (state is ExerciseManagementLoaded) {
        final currentState = state as ExerciseManagementLoaded;

        final result = await updateExercise(
          update.Params(
            id: event.id,
            name: event.name,
            description: event.description,
            imagePath: event.imagePath,
          ),
        );

        result.fold(
          (failure) {
            messageBloc.add(AddMessageEvent(
                message: _mapFailureToMessage(failure), isError: true));
          },
          (result) {
            final updatedExerciseIndex =
                currentState.exercises.indexWhere((el) => el.id == event.id);
            final updatedExercises =
                List<Exercise>.from(currentState.exercises);
            updatedExercises[updatedExerciseIndex] = Exercise(
                id: event.id,
                name: event.name,
                description: event.description,
                imagePath: event.imagePath);
            emit(currentState.copyWith(exercises: updatedExercises));
            messageBloc.add(AddMessageEvent(
                message:
                    tr('message_exercise_update_success', args: [event.name]),
                isError: false));
          },
        );
      }
    });

    on<DeleteExerciseEvent>((event, emit) async {
      if (state is ExerciseManagementLoaded) {
        final currentState = state as ExerciseManagementLoaded;

        final result = await deleteExercise(
          delete.Params(id: event.id),
        );

        result.fold(
          (failure) {
            messageBloc.add(AddMessageEvent(
                message: _mapFailureToMessage(failure), isError: true));
          },
          (result) {
            final deletedExercise =
                currentState.exercises.firstWhere((el) => el.id == event.id);
            final updatedExercises = List<Exercise>.from(currentState.exercises)
              ..removeWhere((el) => el.id == event.id);
            emit(currentState.copyWith(exercises: updatedExercises));
            messageBloc.add(AddMessageEvent(
                message: tr('message_exercise_deletion_success',
                    args: [deletedExercise.name]),
                isError: false));
          },
        );
      }
    });
  }
}

String _mapFailureToMessage(Failure failure) {
  if (failure is DatabaseFailure) {
    return databaseFailureMessage;
  } else if (failure is InvalidExerciseNameFailure) {
    return invalidExerciseNameFailureMessage;
  } else {
    return tr('message_unexpected_error');
  }
}
