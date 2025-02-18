import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/database/object_box.dart';
import '../../../../core/messages/bloc/message_bloc.dart';
import '../../../../injection_container.dart';
import '../../models/exercise.dart';

part 'exercise_management_event.dart';
part 'exercise_management_state.dart';

class ExerciseManagementBloc
    extends Bloc<ExerciseManagementEvent, ExerciseManagementState> {
  final MessageBloc messageBloc;

  ExerciseManagementBloc({required this.messageBloc})
      : super(ExerciseManagementInitial()) {
    on<FetchExercisesEvent>((event, emit) async {
      try {
        final fetchedExercises = sl<ObjectBox>().getAllExercises();

        if (state is ExerciseManagementLoaded) {
          final currentState = state as ExerciseManagementLoaded;
          emit(currentState.copyWith(exercises: fetchedExercises));
        } else {
          emit(ExerciseManagementLoaded(exercises: fetchedExercises));
        }
      } catch (e) {
        messageBloc.add(AddMessageEvent(
            message: 'An error occurred: ${e.toString()}', isError: true));
      }
    });

    on<GetExerciseEvent>((event, emit) async {
      if (state is! ExerciseManagementLoaded) return;
      try {
        final currentState = state as ExerciseManagementLoaded;
        final exercise = sl<ObjectBox>().getExerciseById(event.exerciseId);

        emit(currentState.copyWith(selectedExercise: exercise));
      } catch (e) {
        messageBloc.add(AddMessageEvent(
            message: 'An error occurred: ${e.toString()}', isError: true));
      }
    });

    on<ClearSelectedExerciseEvent>((event, emit) {
      if (state is ExerciseManagementLoaded) {
        final currentState = state as ExerciseManagementLoaded;
        emit(
          currentState.copyWith(clearSelectedExercise: true),
        );
      }
    });

    on<CreateOrUpdateExerciseEvent>((event, emit) async {
      if (state is! ExerciseManagementLoaded) return;

      try {
        final isUpdate = event.exercise.id != 0;

        if (isUpdate) {
          sl<ObjectBox>().updateExercise(event.exercise);
          messageBloc.add(AddMessageEvent(
              message: tr('message_exercise_update_success'), isError: false));
        } else {
          sl<ObjectBox>().createExercise(event.exercise);
          messageBloc.add(AddMessageEvent(
              message: tr('message_exercise_creation_success'),
              isError: false));
        }
        add(FetchExercisesEvent());
      } catch (e) {
        messageBloc.add(AddMessageEvent(
            message: 'An error occurred: ${e.toString()}', isError: true));
      }
    });

    on<DeleteExerciseEvent>((event, emit) async {
      if (state is! ExerciseManagementLoaded) return;
      try {
        sl<ObjectBox>().deleteExercise(event.id);
        messageBloc.add(AddMessageEvent(
            message: tr('message_exercise_deletion_success'), isError: false));

        add(FetchExercisesEvent());
      } catch (e) {
        messageBloc.add(AddMessageEvent(
            message: 'An error occurred: ${e.toString()}', isError: true));
      }
    });
  }
}
