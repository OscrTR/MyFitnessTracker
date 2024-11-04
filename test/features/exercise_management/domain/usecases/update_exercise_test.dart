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

  const exercise = Exercise(
    id: 1,
    name: 'Squats',
    description: 'A lower body exercise',
    imagePath: '/images/squats.png',
  );

  const exerciseNoName = Exercise(
    id: 1,
    name: '',
    description: 'A lower body exercise',
    imagePath: '/images/squats.png',
  );

  group('UpdateExercise UseCase', () {
    test('should return Exercise on successful update', () async {
      // Arrange
      when(() => mockExerciseRepository.updateExercise(exercise))
          .thenAnswer((_) async => const Right(exercise));

      // Act
      final result = await updateExercise(const Params(exercise));

      // Assert
      expect(result, const Right(exercise));
      verify(() => mockExerciseRepository.updateExercise(exercise)).called(1);
      verifyNoMoreInteractions(mockExerciseRepository);
    });

    test('should return InvalidExerciseNameFailure when name is empty',
        () async {
      // Act
      final result = await updateExercise(const Params(exerciseNoName));

      // Assert
      expect(result, const Left(InvalidExerciseNameFailure()));
      verifyZeroInteractions(mockExerciseRepository);
    });

    test('should return DatabaseFailure for any other exception', () async {
      // Arrange
      when(() => mockExerciseRepository.updateExercise(exercise))
          .thenThrow(Exception());

      // Act
      final result = await updateExercise(const Params(exercise));

      // Assert
      expect(result, const Left(DatabaseFailure()));
      verify(() => mockExerciseRepository.updateExercise(exercise)).called(1);
      verifyNoMoreInteractions(mockExerciseRepository);
    });
  });
}
