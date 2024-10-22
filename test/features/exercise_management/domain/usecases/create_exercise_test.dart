import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_fitness_tracker/features/exercise_management/domain/entities/exercise.dart';
import 'package:my_fitness_tracker/features/exercise_management/domain/repositories/exercise_repository.dart';
import 'package:my_fitness_tracker/features/exercise_management/domain/usecases/create_exercise.dart';

class MockExerciseRepository extends Mock implements ExerciseRepository {}

void main() {
  late CreateExercise usecase;
  late MockExerciseRepository mockExerciseRepository;

  setUp(() {
    mockExerciseRepository = MockExerciseRepository();
    usecase = CreateExercise(mockExerciseRepository);
  });

  const tExercise = Exercise(
      name: 'Test name',
      imageName: 'Test image name',
      description: 'Test description');
  const rExercise = Exercise(
      id: 1,
      name: 'Test name',
      imageName: 'Test image name',
      description: 'Test description');

  test(
    'should return the created exercise from the repository',
    () async {
      // Arrange
      when(() => mockExerciseRepository.createExercise(tExercise))
          .thenAnswer((_) async => const Right(rExercise));
      // Act
      final result = await usecase(Params(exercise: tExercise));
      // Assert
      expect(result, const Right(rExercise));
      verify(() => mockExerciseRepository.createExercise(tExercise));
      verifyNoMoreInteractions(mockExerciseRepository);
    },
  );
}
