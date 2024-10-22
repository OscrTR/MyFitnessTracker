import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_fitness_tracker/core/error/exceptions.dart';
import 'package:my_fitness_tracker/core/error/failures.dart';
import 'package:my_fitness_tracker/features/exercise_management/data/datasources/exercise_local_data_source.dart';
import 'package:my_fitness_tracker/features/exercise_management/data/models/exercise_model.dart';
import 'package:my_fitness_tracker/features/exercise_management/data/repositories/exercise_repository_impl.dart';
import 'package:my_fitness_tracker/features/exercise_management/domain/entities/exercise.dart';

class MockLocalDataSource extends Mock implements ExerciseLocalDataSource {}

void main() {
  late ExerciseRepositoryImpl repository;
  late MockLocalDataSource mockLocalDataSource;

  setUp(() {
    mockLocalDataSource = MockLocalDataSource();
    repository = ExerciseRepositoryImpl(localDataSource: mockLocalDataSource);
  });

  group('getExercise', () {
    const tId = 1;
    const tExerciseModel = ExerciseModel(
        id: 1,
        name: 'Test name',
        imageName: 'Test image name',
        description: 'Test description');
    const Exercise tExercise = tExerciseModel;

    // TODO : test database connection

    test(
      'should return exercise data matching the id when the call is successful',
      () async {
        // Arrange
        when(() => mockLocalDataSource.getExercise(tId))
            .thenAnswer((_) async => tExerciseModel);
        // Act
        final result = await repository.getExercise(tId);
        // Assert
        verify(() => mockLocalDataSource.getExercise(tId));
        expect(result, equals(const Right(tExercise)));
      },
    );

    test(
      'should return database failure when the call is unsuccessful',
      () async {
        // Arrange
        when(() => mockLocalDataSource.getExercise(tId))
            .thenThrow(DatabaseException());
        // Act
        final result = await repository.getExercise(tId);
        // Assert
        verify(() => mockLocalDataSource.getExercise(tId));
        expect(result, equals(const Left(DatabaseFailure())));
      },
    );
  });
}
