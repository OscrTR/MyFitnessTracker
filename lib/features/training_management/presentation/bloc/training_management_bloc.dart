import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'training_management_event.dart';
part 'training_management_state.dart';

class TrainingManagementBloc
    extends Bloc<TrainingManagementEvent, TrainingManagementState> {
  TrainingManagementBloc() : super(TrainingManagementInitial()) {
    on<TrainingManagementEvent>((event, emit) {});
  }
}
