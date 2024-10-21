import 'package:dartz/dartz.dart';
import 'package:my_fitness_tracker/features/exercise_management/domain/entities/exercise.dart';
import 'package:my_fitness_tracker/features/exercise_management/domain/repositories/exercise_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_fitness_tracker/features/exercise_management/domain/usecases/fetch_exercises.dart';

class MockExerciseRepository extends Mock implements ExerciseRepository {}

void main() {
  late FetchExercises usecase;
  late MockExerciseRepository mockExerciseRepository;

  setUp(() {
    mockExerciseRepository = MockExerciseRepository();
    usecase = FetchExercises(mockExerciseRepository);
  });

  final tExercises = [
    Exercise(
        id: 1,
        name: 'Test name',
        imageName: 'Test image name',
        description: 'Test description'),
    Exercise(
        id: 2,
        name: 'Test name 2',
        imageName: 'Test image name 2',
        description: 'Test description 2')
  ];

  test(
    'should fetch exercises from the repository',
    () async {
      // Arrange
      when(() => mockExerciseRepository.fetchExercises())
          .thenAnswer((_) async => Right(tExercises));
      // Act
      final result = await usecase(null);
      // Assert
      expect(result, Right(tExercises));
      verify(() => mockExerciseRepository.fetchExercises());
      verifyNoMoreInteractions(mockExerciseRepository);
    },
  );
}
