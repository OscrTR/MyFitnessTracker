import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'exercise_management_event.dart';
part 'exercise_management_state.dart';

class ExerciseManagementBloc
    extends Bloc<ExerciseManagementEvent, ExerciseManagementState> {
  ExerciseManagementBloc() : super(ExerciseManagementInitial()) {
    on<ExerciseManagementEvent>((event, emit) {});
  }
}
