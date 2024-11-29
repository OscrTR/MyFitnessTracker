import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'active_training_event.dart';
part 'active_training_state.dart';

class ActiveTrainingBloc extends Bloc<ActiveTrainingEvent, ActiveTrainingState> {
  ActiveTrainingBloc() : super(ActiveTrainingInitial()) {
    on<ActiveTrainingEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
