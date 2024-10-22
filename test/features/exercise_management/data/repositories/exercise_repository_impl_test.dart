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

  const tId = 1;
  const tExerciseModel = ExerciseModel(
      id: 1,
      name: 'Push-up',
      description: 'Upper body exercise',
      imageName: 'pushup.png');
  const Exercise tExercise = tExerciseModel;
  final tExerciseList = [tExerciseModel];

  group('createExercise', () {
    test(
        'should return created Exercise when the call to localDataSource is successful',
        () async {
      // Arrange
      when(() => mockLocalDataSource.createExercise(tExercise))
          .thenAnswer((_) async => tExerciseModel);

      // Act
      final result = await repository.createExercise(tExercise);

      // Assert
      verify(() => mockLocalDataSource.createExercise(tExercise));
      expect(result, const Right(tExercise));
    });

    test('should return DatabaseFailure when the call to localDataSource fails',
        () async {
      // Arrange
      when(() => mockLocalDataSource.createExercise(tExercise))
          .thenThrow(LocalDatabaseException());

      // Act
      final result = await repository.createExercise(tExercise);

      // Assert
      verify(() => mockLocalDataSource.createExercise(tExercise));
      expect(result, const Left(DatabaseFailure()));
    });
  });

  group('getExercise', () {
    test(
      'should return an exercise when the call to localDataSource is successful',
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
      'should return DatabaseFailure when the call to localDataSource fails',
      () async {
        // Arrange
        when(() => mockLocalDataSource.getExercise(tId))
            .thenThrow(LocalDatabaseException());
        // Act
        final result = await repository.getExercise(tId);
        // Assert
        verify(() => mockLocalDataSource.getExercise(tId));
        expect(result, equals(const Left(DatabaseFailure())));
      },
    );
  });

  group('fetchExercises', () {
    test(
        'should return a list of exercises when the call to localDataSource is successful',
        () async {
      // Arrange
      when(() => mockLocalDataSource.fetchExercises())
          .thenAnswer((_) async => tExerciseList);

      // Act
      final result = await repository.fetchExercises();

      // Assert
      verify(() => mockLocalDataSource.fetchExercises());
      expect(result, Right(tExerciseList));
    });

    test('should return DatabaseFailure when the call to localDataSource fails',
        () async {
      // Arrange
      when(() => mockLocalDataSource.fetchExercises())
          .thenThrow(LocalDatabaseException());

      // Act
      final result = await repository.fetchExercises();

      // Assert
      verify(() => mockLocalDataSource.fetchExercises());
      expect(result, const Left(DatabaseFailure()));
    });
  });
  group('updateExercise', () {
    test(
        'should return updated Exercise when the call to localDataSource is successful',
        () async {
      // Arrange
      when(() => mockLocalDataSource.updateExercise(tExercise))
          .thenAnswer((_) async => tExerciseModel);

      // Act
      final result = await repository.updateExercise(tExercise);

      // Assert
      verify(() => mockLocalDataSource.updateExercise(tExercise));
      expect(result, const Right(tExercise));
    });

    test('should return DatabaseFailure when the call to localDataSource fails',
        () async {
      // Arrange
      when(() => mockLocalDataSource.updateExercise(tExercise))
          .thenThrow(LocalDatabaseException());

      // Act
      final result = await repository.updateExercise(tExercise);

      // Assert
      verify(() => mockLocalDataSource.updateExercise(tExercise));
      expect(result, const Left(DatabaseFailure()));
    });
  });

  group('deleteExercise', () {
    test(
        'should return deleted Exercise when the call to localDataSource is successful',
        () async {
      // Arrange
      when(() => mockLocalDataSource.deleteExercise(tExercise))
          .thenAnswer((_) async => tExerciseModel);

      // Act
      final result = await repository.deleteExercise(tExercise);

      // Assert
      verify(() => mockLocalDataSource.deleteExercise(tExercise));
      expect(result, const Right(tExercise));
    });

    test('should return DatabaseFailure when the call to localDataSource fails',
        () async {
      // Arrange
      when(() => mockLocalDataSource.deleteExercise(tExercise))
          .thenThrow(LocalDatabaseException());

      // Act
      final result = await repository.deleteExercise(tExercise);

      // Assert
      verify(() => mockLocalDataSource.deleteExercise(tExercise));
      expect(result, const Left(DatabaseFailure()));
    });
  });
}
