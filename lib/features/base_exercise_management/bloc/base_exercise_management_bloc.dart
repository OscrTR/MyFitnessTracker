import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import '../../../core/enums/enums.dart';
import '../../../core/database/database_service.dart';

import '../../../core/messages/toast.dart';
import '../../../injection_container.dart';
import '../models/base_exercise.dart';

part 'base_exercise_management_event.dart';
part 'base_exercise_management_state.dart';

class BaseExerciseManagementBloc
    extends Bloc<BaseExerciseManagementEvent, BaseExerciseManagementState> {
  BaseExerciseManagementBloc() : super(BaseExerciseManagementInitial()) {
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
        showToastMessage(
          message: e.toString(),
          isSuccess: false,
          isLog: true,
          logLevel: LogLevel.error,
          logFunction: 'GetAllBaseExercisesEvent',
        );
      }
    });

    on<GetBaseExerciseEvent>((event, emit) async {
      try {
        final fetchedBaseExercise =
            await sl<DatabaseService>().getBaseExerciseById(event.id);

        final currentState = state as BaseExerciseManagementLoaded;
        emit(currentState.copyWith(selectedBaseExercise: fetchedBaseExercise));
      } catch (e) {
        showToastMessage(
          message: e.toString(),
          isSuccess: false,
          isLog: true,
          logLevel: LogLevel.error,
          logFunction: 'GetBaseExerciseEvent',
        );
      }
    });

    on<CreateOrUpdateBaseExerciseEvent>((event, emit) async {
      if (state is! BaseExerciseManagementLoaded) return;

      try {
        final isUpdate = event.baseExercise.id != null;

        if (isUpdate) {
          await sl<DatabaseService>().updateBaseExercise(event.baseExercise);
          showToastMessage(message: tr('message_base_exercise_update_success'));
        } else {
          await sl<DatabaseService>().createBaseExercise(event.baseExercise);
          showToastMessage(
              message: tr('message_base_exercise_creation_success'));
        }
        add(GetAllBaseExercisesEvent());
      } catch (e) {
        showToastMessage(
          message: e.toString(),
          isSuccess: false,
          isLog: true,
          logLevel: LogLevel.error,
          logFunction: 'CreateOrUpdateBaseExerciseEvent',
        );
      }
    });

    on<DeleteBaseExerciseEvent>((event, emit) async {
      if (state is! BaseExerciseManagementLoaded) return;
      try {
        await sl<DatabaseService>().deleteBaseExercise(event.id);
        showToastMessage(message: tr('message_base_exercise_deletion_success'));

        add(GetAllBaseExercisesEvent());
      } catch (e) {
        showToastMessage(
          message: e.toString(),
          isSuccess: false,
          isLog: true,
          logLevel: LogLevel.error,
          logFunction: 'DeleteBaseExerciseEvent',
        );
      }
    });

    on<ClearSelectedBaseExerciseEvent>((event, emit) async {
      if (state is! BaseExerciseManagementLoaded) return;
      try {
        final currentState = state as BaseExerciseManagementLoaded;
        emit(currentState.copyWith(clearSelectedBaseExercise: true));
      } catch (e) {
        showToastMessage(
          message: e.toString(),
          isSuccess: false,
          isLog: true,
          logLevel: LogLevel.error,
          logFunction: 'ClearSelectedBaseExerciseEvent',
        );
      }
    });
  }
}
