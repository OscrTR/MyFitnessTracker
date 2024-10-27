import 'package:bloc/bloc.dart';
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

const String databaseFailureMessage = 'Database Failure';
const String invalidExerciseNameFailureMessage = 'Invalid exercise name.';

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

    on<CreateExerciseEvent>((event, emit) async {
      if (state is ExerciseManagementLoaded) {
        final currentState = state as ExerciseManagementLoaded;

        final result = await createExercise(
          create.Params(
            name: event.name,
            description: event.description,
            imageName: event.imageName,
          ),
        );

        result.fold(
          (failure) {
            messageBloc.add(AddMessageEvent(
                message: _mapFailureToMessage(failure), isError: true));
          },
          (result) {
            messageBloc.add(AddMessageEvent(
                message: 'Exercise ${event.name} created successfully.',
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
            imageName: event.imageName,
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
                imageName: event.imageName);
            emit(currentState.copyWith(exercises: updatedExercises));
            messageBloc.add(AddMessageEvent(
                message: 'Exercise ${event.name} updated successfully.',
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
                message:
                    'Exercise ${deletedExercise.name} deleted successfully.',
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
    return 'Unexpected error';
  }
}
