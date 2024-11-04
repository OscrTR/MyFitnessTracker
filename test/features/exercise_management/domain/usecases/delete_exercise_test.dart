import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_fitness_tracker/core/error/failures.dart';
import 'package:my_fitness_tracker/features/exercise_management/domain/repositories/exercise_repository.dart';
import 'package:my_fitness_tracker/features/exercise_management/domain/usecases/delete_exercise.dart';

// Generate a mock repository
class MockExerciseRepository extends Mock implements ExerciseRepository {}

void main() {
  late DeleteExercise deleteExercise;
  late MockExerciseRepository mockExerciseRepository;

  setUp(() {
    mockExerciseRepository = MockExerciseRepository();
    deleteExercise = DeleteExercise(mockExerciseRepository);
  });

  group('DeleteExercise UseCase', () {
    const int tExerciseId = 1;
    const params = Params(tExerciseId);

    test('should delete exercise and return Right(void) on success', () async {
      // Arrange
      when(() => mockExerciseRepository.deleteExercise(tExerciseId))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await deleteExercise(params);

      // Assert
      expect(result, const Right(null));
      verify(() => mockExerciseRepository.deleteExercise(tExerciseId))
          .called(1);
      verifyNoMoreInteractions(mockExerciseRepository);
    });

    test('should return Left(Failure) on repository failure', () async {
      // Arrange
      when(() => mockExerciseRepository.deleteExercise(tExerciseId))
          .thenAnswer((_) async => const Left(DatabaseFailure()));

      // Act
      final result = await deleteExercise(params);

      // Assert
      expect(result, const Left(DatabaseFailure()));
      verify(() => mockExerciseRepository.deleteExercise(tExerciseId))
          .called(1);
      verifyNoMoreInteractions(mockExerciseRepository);
    });
  });
}
