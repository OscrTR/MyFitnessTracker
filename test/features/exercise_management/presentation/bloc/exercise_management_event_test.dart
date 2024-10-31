import 'package:flutter_test/flutter_test.dart';
import 'package:my_fitness_tracker/features/exercise_management/presentation/bloc/exercise_management_bloc.dart';

void main() {
  group('ExerciseManagementEvent equality', () {
    test('CreateExerciseEvent with identical properties should be equal', () {
      const event1 = CreateExerciseEvent(
        name: 'Push Up',
        description: 'An upper body exercise',
        imagePath: '/images/push_up.png',
      );

      const event2 = CreateExerciseEvent(
        name: 'Push Up',
        description: 'An upper body exercise',
        imagePath: '/images/push_up.png',
      );

      expect(event1, equals(event2));
    });

    test('CreateExerciseEvent with different properties should not be equal',
        () {
      const event1 = CreateExerciseEvent(
        name: 'Push Up',
        description: 'An upper body exercise',
        imagePath: '/images/push_up.png',
      );

      const event2 = CreateExerciseEvent(
        name: 'Pull Up',
        description: 'An upper body exercise',
        imagePath: '/images/pull_up.png',
      );

      expect(event1, isNot(equals(event2)));
    });

    test('GetExerciseEvent with identical properties should be equal', () {
      const event1 = GetExerciseEvent(1);
      const event2 = GetExerciseEvent(1);

      expect(event1, equals(event2));
    });

    test('GetExerciseEvent with different properties should not be equal', () {
      const event1 = GetExerciseEvent(1);
      const event2 = GetExerciseEvent(2);

      expect(event1, isNot(equals(event2)));
    });

    test('ClearSelectedExerciseEvent should be equal', () {
      const event1 = ClearSelectedExerciseEvent();
      const event2 = ClearSelectedExerciseEvent();

      expect(event1, equals(event2));
    });

    test('FetchExercisesEvent should always be equal', () {
      var event1 = FetchExercisesEvent();
      var event2 = FetchExercisesEvent();

      expect(event1, equals(event2));
    });

    test('UpdateExerciseEvent with identical properties should be equal', () {
      const event1 = UpdateExerciseEvent(
        id: 1,
        name: 'Push Up',
        description: 'An upper body exercise',
        imagePath: '/images/push_up.png',
      );

      const event2 = UpdateExerciseEvent(
        id: 1,
        name: 'Push Up',
        description: 'An upper body exercise',
        imagePath: '/images/push_up.png',
      );

      expect(event1, equals(event2));
    });

    test('UpdateExerciseEvent with different properties should not be equal',
        () {
      const event1 = UpdateExerciseEvent(
        id: 1,
        name: 'Push Up',
        description: 'An upper body exercise',
        imagePath: '/images/push_up.png',
      );

      const event2 = UpdateExerciseEvent(
        id: 1,
        name: 'Pull Up',
        description: 'A different exercise',
        imagePath: '/images/pull_up.png',
      );

      expect(event1, isNot(equals(event2)));
    });

    test('DeleteExerciseEvent with identical properties should be equal', () {
      const event1 = DeleteExerciseEvent(1);
      const event2 = DeleteExerciseEvent(1);

      expect(event1, equals(event2));
    });

    test('DeleteExerciseEvent with different properties should not be equal',
        () {
      const event1 = DeleteExerciseEvent(1);
      const event2 = DeleteExerciseEvent(2);

      expect(event1, isNot(equals(event2)));
    });
  });
}
