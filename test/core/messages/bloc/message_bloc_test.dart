import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_fitness_tracker/core/messages/bloc/message_bloc.dart';

void main() {
  group('MessageBloc', () {
    late MessageBloc messageBloc;

    setUp(() {
      messageBloc = MessageBloc();
    });

    tearDown(() {
      messageBloc.close();
    });

    test('initial state is MessageInitial', () {
      expect(messageBloc.state, MessageInitial());
    });

    blocTest<MessageBloc, MessageState>(
      'emits [MessageLoaded] with message and isError values when AddMessageEvent is added',
      build: () => messageBloc,
      act: (bloc) =>
          bloc.add(const AddMessageEvent(message: 'Hello', isError: false)),
      expect: () => [
        const MessageLoaded(message: 'Hello', isError: false),
      ],
    );

    blocTest<MessageBloc, MessageState>(
      'emits [MessageLoaded] with message and isError set to true when AddMessageEvent is added with isError true',
      build: () => messageBloc,
      act: (bloc) => bloc
          .add(const AddMessageEvent(message: 'Error occurred', isError: true)),
      expect: () => [
        const MessageLoaded(message: 'Error occurred', isError: true),
      ],
    );
  });

  group('AddMessageEvent', () {
    test('supports value equality with identical props', () {
      const event1 = AddMessageEvent(message: 'Test Message', isError: false);
      const event2 = AddMessageEvent(message: 'Test Message', isError: false);

      expect(event1, equals(event2));
    });

    test('does not equal another event with different props', () {
      const event1 = AddMessageEvent(message: 'Test Message', isError: false);
      const event2 =
          AddMessageEvent(message: 'Different Message', isError: true);

      expect(event1, isNot(equals(event2)));
    });
  });
}
