import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import '../../../core/database/database_service.dart';

import '../../../core/messages/bloc/message_bloc.dart';
import '../../../injection_container.dart';
import '../models/base_exercise.dart';

part 'base_exercise_management_event.dart';
part 'base_exercise_management_state.dart';

class BaseExerciseManagementBloc
    extends Bloc<BaseExerciseManagementEvent, BaseExerciseManagementState> {
  final MessageBloc messageBloc;

  BaseExerciseManagementBloc({required this.messageBloc})
      : super(BaseExerciseManagementInitial()) {
    on<GetAllBaseExercisesEvent>((event, emit) async {
      try {
        final fetchedBaseExercises =
            await sl<DatabaseService>().getAllBaseExercises();

        if (state is BaseExerciseManagementLoaded) {
          final currentState = state as BaseExerciseManagementLoaded;
          emit(currentState.copyWith(baseExercises: fetchedBaseExercises));
        } else {
          emit(BaseExerciseManagementLoaded(
              baseExercises: fetchedBaseExercises));
        }
      } catch (e) {
        messageBloc.add(AddMessageEvent(
            message: 'An error occurred: ${e.toString()}', isError: true));
      }
    });

    on<GetBaseExerciseEvent>((event, emit) async {
      try {
        final fetchedBaseExercise =
            await sl<DatabaseService>().getBaseExerciseById(event.id);

        final currentState = state as BaseExerciseManagementLoaded;
        emit(currentState.copyWith(selectedBaseExercise: fetchedBaseExercise));
      } catch (e) {
        messageBloc.add(AddMessageEvent(
            message: 'An error occurred: ${e.toString()}', isError: true));
      }
    });

    on<CreateOrUpdateBaseExerciseEvent>((event, emit) async {
      if (state is! BaseExerciseManagementLoaded) return;

      try {
        final isUpdate = event.exercise.id != 0;

        if (isUpdate) {
          sl<DatabaseService>().updateBaseExercise(event.exercise);
          messageBloc.add(AddMessageEvent(
              message: tr('message_exercise_update_success'), isError: false));
        } else {
          sl<DatabaseService>().createBaseExercise(event.exercise);
          messageBloc.add(AddMessageEvent(
              message: tr('message_exercise_creation_success'),
              isError: false));
        }
        add(GetAllBaseExercisesEvent());
      } catch (e) {
        messageBloc.add(AddMessageEvent(
            message: 'An error occurred: ${e.toString()}', isError: true));
      }
    });

    on<DeleteBaseExerciseEvent>((event, emit) async {
      if (state is! BaseExerciseManagementLoaded) return;
      try {
        sl<DatabaseService>().deleteBaseExercise(event.id);
        messageBloc.add(AddMessageEvent(
            message: tr('message_exercise_deletion_success'), isError: false));

        add(GetAllBaseExercisesEvent());
      } catch (e) {
        messageBloc.add(AddMessageEvent(
            message: 'An error occurred: ${e.toString()}', isError: true));
      }
    });

    on<ClearSelectedBaseExerciseEvent>((event, emit) async {
      if (state is! BaseExerciseManagementLoaded) return;
      try {
        final currentState = state as BaseExerciseManagementLoaded;
        emit(currentState.copyWith(clearSelectedBaseExercise: true));
      } catch (e) {
        messageBloc.add(AddMessageEvent(
            message: 'An error occurred: ${e.toString()}', isError: true));
      }
    });
  }
}
