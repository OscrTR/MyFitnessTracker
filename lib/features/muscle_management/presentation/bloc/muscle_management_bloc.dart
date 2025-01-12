import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import '../../domain/usecases/assign_muscle_to_exercise.dart' as assign;
import '../../domain/usecases/create_muscle.dart' as create;
import '../../domain/usecases/delete_muscle.dart' as delete;
import '../../domain/usecases/get_muscle.dart' as get_m;
import '../../domain/usecases/update_muscle.dart' as update;

import '../../../../core/error/failures.dart';
import '../../../../core/messages/bloc/message_bloc.dart';
import '../../domain/entities/muscle.dart';
import '../../domain/usecases/fetch_muscles.dart';

part 'muscle_management_event.dart';
part 'muscle_management_state.dart';

final String databaseFailureMessage = tr('message_database_failure');

class MuscleManagementBloc
    extends Bloc<MuscleManagementEvent, MuscleManagementState> {
  final FetchMuscles fetchMuscles;
  final create.CreateMuscle createMuscle;
  final get_m.GetMuscle getMuscle;
  final update.UpdateMuscle updateMuscle;
  final delete.DeleteMuscle deleteMuscle;
  final assign.AssignMuscleToExercise assignMuscleToExercise;
  final MessageBloc messageBloc;
  MuscleManagementBloc({
    required this.createMuscle,
    required this.getMuscle,
    required this.updateMuscle,
    required this.deleteMuscle,
    required this.assignMuscleToExercise,
    required this.fetchMuscles,
    required this.messageBloc,
  }) : super(MuscleManagementInitial()) {
    on<FetchMusclesEvent>(
      (event, emit) async {
        final result = await fetchMuscles(null);

        result.fold(
          (failure) => messageBloc.add(AddMessageEvent(
              message: _mapFailureToMessage(failure), isError: true)),
          (muscles) {
            emit(MuscleManagementLoaded(muscles: muscles));
          },
        );
      },
    );

    on<GetMuscleEvent>((event, emit) async {
      if (state is MuscleManagementLoaded) {
        final currentState = state as MuscleManagementLoaded;
        final result = await getMuscle(get_m.Params(event.id));

        result.fold(
          (failure) {
            messageBloc.add(AddMessageEvent(
                message: _mapFailureToMessage(failure), isError: true));
          },
          (muscle) {
            emit(currentState.copyWith(selectedMuscle: muscle));
          },
        );
      }
    });

    on<CreateOrUpdateMuscleEvent>((event, emit) async {
      if (state is MuscleManagementLoaded) {
        final currentState = state as MuscleManagementLoaded;
        final result = event.muscle.id != null
            ? await updateMuscle(update.Params(event.muscle))
            : await createMuscle(create.Params(event.muscle));

        result.fold(
          (failure) {
            messageBloc.add(AddMessageEvent(
                message: _mapFailureToMessage(failure), isError: true));
          },
          (muscle) {
            final List<Muscle> updatedMuscles = List.from(currentState.muscles);
            if (event.muscle.id != null) {
              final index =
                  updatedMuscles.indexWhere((el) => el.id == event.muscle.id);
              updatedMuscles[index] = muscle;
            } else {
              updatedMuscles.add(muscle);
            }

            emit(currentState.copyWith(muscles: updatedMuscles));
          },
        );
      }
    });

    on<DeleteMuscleEvent>((event, emit) async {
      if (state is MuscleManagementLoaded) {
        final currentState = state as MuscleManagementLoaded;
        final result = await deleteMuscle(delete.Params(event.id));

        result.fold(
          (failure) {
            messageBloc.add(AddMessageEvent(
                message: _mapFailureToMessage(failure), isError: true));
          },
          (muscle) {
            final List<Muscle> updatedMuscles = List.from(currentState.muscles);
            updatedMuscles.removeWhere((element) => element.id == event.id);
            emit(currentState.copyWith(muscles: updatedMuscles));
          },
        );
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
