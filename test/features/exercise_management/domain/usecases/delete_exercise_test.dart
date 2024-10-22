import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_fitness_tracker/features/exercise_management/domain/entities/exercise.dart';
import 'package:my_fitness_tracker/features/exercise_management/domain/repositories/exercise_repository.dart';
import 'package:my_fitness_tracker/features/exercise_management/domain/usecases/delete_exercise.dart';

class MockExerciseRepository extends Mock implements ExerciseRepository {}

void main() {
  late DeleteExercise usecase;
  late MockExerciseRepository mockExerciseRepository;

  setUp(() {
    mockExerciseRepository = MockExerciseRepository();
    usecase = DeleteExercise(mockExerciseRepository);
  });

  const tExercise = Exercise(
      id: 1,
      name: 'Test name',
      imageName: 'Test image name',
      description: 'Test description');

  test(
    'should return the deleted exercise from the repository',
    () async {
      // Arrange
      when(() => mockExerciseRepository.deleteExercise(tExercise))
          .thenAnswer((_) async => const Right(tExercise));
      // Act
      final result = await usecase(Params(exercise: tExercise));
      // Assert
      expect(result, const Right(tExercise));
      verify(() => mockExerciseRepository.deleteExercise(tExercise));
      verifyNoMoreInteractions(mockExerciseRepository);
    },
  );
}
