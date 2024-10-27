import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'message_event.dart';
part 'message_state.dart';

class MessageBloc extends Bloc<MessageEvent, MessageState> {
  MessageBloc() : super(MessageInitial()) {
    on<AddMessageEvent>((event, emit) async {
      emit(MessageLoaded(message: event.message, isError: event.isError));
    });
  }
}
