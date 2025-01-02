part of 'message_bloc.dart';

abstract class MessageEvent extends Equatable {
  const MessageEvent();

  @override
  List<Object> get props => [];
}

class AddMessageEvent extends MessageEvent {
  final String message;
  final bool isError;

  const AddMessageEvent({required this.message, required this.isError});

  @override
  List<Object> get props => [message, isError];
}
