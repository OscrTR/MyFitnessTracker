import 'package:dartz/dartz.dart';
import 'package:my_fitness_tracker/features/exercise_management/domain/entities/exercise.dart';
import 'package:my_fitness_tracker/features/exercise_management/domain/repositories/exercise_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_fitness_tracker/features/exercise_management/domain/usecases/get_exercise.dart';

class MockExerciseRepository extends Mock implements ExerciseRepository {}

void main() {
  late GetExercise usecase;
  late MockExerciseRepository mockExerciseRepository;

  setUp(() {
    mockExerciseRepository = MockExerciseRepository();
    usecase = GetExercise(mockExerciseRepository);
  });

  const tId = 1;
  const tExercise = Exercise(
      id: 1,
      name: 'Test name',
      imagePath: 'Test image name',
      description: 'Test description');

  test(
    'should get exercise for the id from the repository',
    () async {
      // Arrange
      when(() => mockExerciseRepository.getExercise(tId))
          .thenAnswer((_) async => const Right(tExercise));
      // Act
      final result = await usecase(const Params(tId));
      // Assert
      expect(result, const Right(tExercise));
      verify(() => mockExerciseRepository.getExercise(tId));
      verifyNoMoreInteractions(mockExerciseRepository);
    },
  );
}
