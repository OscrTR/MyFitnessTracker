import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_fitness_tracker/features/exercise_management/domain/entities/exercise.dart';
import 'package:my_fitness_tracker/features/exercise_management/domain/repositories/exercise_repository.dart';
import 'package:my_fitness_tracker/features/exercise_management/domain/usecases/update_exercise.dart';

class MockExerciseRepository extends Mock implements ExerciseRepository {}

void main() {
  late UpdateExercise usecase;
  late MockExerciseRepository mockExerciseRepository;

  setUp(() {
    mockExerciseRepository = MockExerciseRepository();
    usecase = UpdateExercise(mockExerciseRepository);
  });

  const tExercise = Exercise(
      id: 1,
      name: 'Test name modified',
      imageName: 'Test image name modified',
      description: 'Test description modified');

  test(
    'should return the updated exercise from the repository',
    () async {
      // Arrange
      when(() => mockExerciseRepository.updateExercise(tExercise))
          .thenAnswer((_) async => const Right(tExercise));
      // Act
      final result = await usecase(Params(exercise: tExercise));
      // Assert
      expect(result, const Right(tExercise));
      verify(() => mockExerciseRepository.updateExercise(tExercise));
      verifyNoMoreInteractions(mockExerciseRepository);
    },
  );
}
