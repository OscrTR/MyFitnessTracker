import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_fitness_tracker/core/error/failures.dart';
import 'package:my_fitness_tracker/features/exercise_management/domain/entities/exercise.dart';
import 'package:my_fitness_tracker/features/exercise_management/domain/repositories/exercise_repository.dart';
import 'package:my_fitness_tracker/features/exercise_management/domain/usecases/update_exercise.dart';

class MockExerciseRepository extends Mock implements ExerciseRepository {}

void main() {
  late UpdateExercise updateExercise;
  late MockExerciseRepository mockExerciseRepository;

  setUp(() {
    mockExerciseRepository = MockExerciseRepository();
    updateExercise = UpdateExercise(mockExerciseRepository);
  });

  group('UpdateExercise UseCase', () {
    const tExercise = Exercise(
      id: 1,
      name: 'Squats',
      description: 'A lower body exercise',
      imagePath: '/images/squats.png',
    );

    const params = Params(
      id: 1,
      name: 'Squats',
      description: 'A lower body exercise',
      imagePath: '/images/squats.png',
    );

    const paramsWithEmptyName = Params(
      id: 1,
      name: '',
      description: 'A lower body exercise',
      imagePath: '/images/squats.png',
    );

    test('should return Exercise on successful update', () async {
      // Arrange
      when(() => mockExerciseRepository.updateExercise(tExercise))
          .thenAnswer((_) async => const Right(tExercise));

      // Act
      final result = await updateExercise(params);

      // Assert
      expect(result, const Right(tExercise));
      verify(() => mockExerciseRepository.updateExercise(tExercise)).called(1);
      verifyNoMoreInteractions(mockExerciseRepository);
    });

    test('should return InvalidExerciseNameFailure when name is empty',
        () async {
      // Act
      final result = await updateExercise(paramsWithEmptyName);

      // Assert
      expect(result, const Left(InvalidExerciseNameFailure()));
      verifyZeroInteractions(mockExerciseRepository);
    });

    test('should return DatabaseFailure for any other exception', () async {
      // Arrange
      when(() => mockExerciseRepository.updateExercise(tExercise))
          .thenThrow(Exception());

      // Act
      final result = await updateExercise(params);

      // Assert
      expect(result, const Left(DatabaseFailure()));
      verify(() => mockExerciseRepository.updateExercise(tExercise)).called(1);
      verifyNoMoreInteractions(mockExerciseRepository);
    });
  });

  group('Params Equatability', () {
    test('Params with identical properties should be equal', () {
      const params1 = Params(
        id: 1,
        name: 'Squats',
        description: 'A lower body exercise',
        imagePath: '/images/squats.png',
      );

      const params2 = Params(
        id: 1,
        name: 'Squats',
        description: 'A lower body exercise',
        imagePath: '/images/squats.png',
      );

      expect(params1, equals(params2));
    });

    test('Params with different properties should not be equal', () {
      const params1 = Params(
        id: 1,
        name: 'Squats',
        description: 'A lower body exercise',
        imagePath: '/images/squats.png',
      );

      const params2 = Params(
        id: 2,
        name: 'Lunges',
        description: 'A different exercise',
        imagePath: '/images/lunges.png',
      );

      expect(params1, isNot(equals(params2)));
    });

    test('Params with identical id but different names should not be equal',
        () {
      const params1 = Params(
        id: 1,
        name: 'Squats',
        description: 'A lower body exercise',
        imagePath: '/images/squats.png',
      );

      const params2 = Params(
        id: 1,
        name: 'Lunges',
        description: 'A lower body exercise',
        imagePath: '/images/squats.png',
      );

      expect(params1, isNot(equals(params2)));
    });
  });
}
