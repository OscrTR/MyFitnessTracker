import 'package:flutter_test/flutter_test.dart';
import 'package:my_fitness_tracker/features/exercise_management/domain/entities/exercise.dart';

void main() {
  group('Exercise Entity', () {
    test('should create an Exercise with valid inputs', () {
      // Act
      const exercise = Exercise(
        id: 1,
        name: 'Push-up',
        imagePath: 'pushup.png',
        description: 'An upper body exercise',
      );

      // Assert
      expect(exercise.id, 1);
      expect(exercise.name, 'Push-up');
      expect(exercise.imagePath, 'pushup.png');
      expect(exercise.description, 'An upper body exercise');
    });

    test('should return true when comparing two exercises with same properties',
        () {
      // Arrange
      const exercise1 = Exercise(
        id: 1,
        name: 'Push-up',
        imagePath: 'pushup.png',
        description: 'An upper body exercise',
      );

      const exercise2 = Exercise(
        id: 1,
        name: 'Push-up',
        imagePath: 'pushup.png',
        description: 'An upper body exercise',
      );

      // Act & Assert
      expect(exercise1, exercise2);
    });

    test(
        'should return false when comparing two exercises with different properties',
        () {
      // Arrange
      const exercise1 = Exercise(
        id: 1,
        name: 'Push-up',
        imagePath: 'pushup.png',
        description: 'An upper body exercise',
      );

      const exercise2 = Exercise(
        id: 2,
        name: 'Squat',
        imagePath: 'squat.png',
        description: 'A lower body exercise',
      );

      // Act & Assert
      expect(exercise1 == exercise2, false);
    });
  });
}
