import 'package:flutter_test/flutter_test.dart';
import 'package:my_fitness_tracker/features/exercise_management/presentation/bloc/exercise_management_bloc.dart';

void main() {
  group('ExerciseManagementFailure equality', () {
    test('ExerciseManagementFailure with identical messages should be equal',
        () {
      const failure1 = ExerciseManagementFailure('An error occurred');
      const failure2 = ExerciseManagementFailure('An error occurred');

      expect(failure1, equals(failure2));
    });

    test(
        'ExerciseManagementFailure with different messages should not be equal',
        () {
      const failure1 = ExerciseManagementFailure('An error occurred');
      const failure2 = ExerciseManagementFailure('A different error occurred');

      expect(failure1, isNot(equals(failure2)));
    });
  });
}
