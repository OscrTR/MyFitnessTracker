import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'training_history_event.dart';
part 'training_history_state.dart';

class TrainingHistoryBloc
    extends Bloc<TrainingHistoryEvent, TrainingHistoryState> {
  TrainingHistoryBloc() : super(TrainingHistoryInitial()) {
    on<TrainingHistoryEvent>((event, emit) {
      // TODO: créer un événement pour enregistrer la série
    });
  }
}
