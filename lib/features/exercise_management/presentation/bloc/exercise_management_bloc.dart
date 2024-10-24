import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/usecases/create_exercise.dart';

part 'exercise_management_event.dart';
part 'exercise_management_state.dart';

const String databaseFailureMessage = 'Database Failure';
const String InvalidExerciseNameFailureMessage = 'Invalid exercise name.';

class ExerciseManagementBloc
    extends Bloc<ExerciseManagementEvent, ExerciseManagementState> {
  final CreateExercise createExercise;

  ExerciseManagementBloc({required this.createExercise})
      : super(ExerciseManagementInitial()) {
    on<CreateExerciseEvent>((event, emit) async {
      emit(ExerciseManagementLoading());
      final result = await createExercise(
        Params(
          name: event.name,
          description: event.description,
          imageName: event.imageName,
        ),
      );

      result.fold(
        (failure) {
          emit(
            ExerciseManagementFailure(message: _mapFailureToMessage(failure)),
          );
        },
        (exercise) {
          print(exercise);
          emit(ExerciseManagementSuccess(exercise));
        },
      );
    });
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is DatabaseFailure) {
      return databaseFailureMessage;
    } else if (failure is InvalidExerciseNameFailure) {
      return InvalidExerciseNameFailureMessage;
    } else {
      return 'Unexpected error';
    }
  }
}
