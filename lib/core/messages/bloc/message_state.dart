part of 'message_bloc.dart';

abstract class MessageState extends Equatable {
  const MessageState();

  @override
  List<Object?> get props => [];
}

class MessageInitial extends MessageState {}

class MessageLoading extends MessageState {}

class MessageLoaded extends MessageState {
  final String message;
  final bool isError;

  const MessageLoaded({required this.message, required this.isError});

  @override
  List<Object?> get props => [message, isError];
}
