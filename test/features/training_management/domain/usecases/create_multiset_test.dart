import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:my_fitness_tracker/core/error/failures.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/multiset.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/yoga_exercise.dart';
import 'package:my_fitness_tracker/features/training_management/domain/repositories/multiset_repository.dart';
import 'package:my_fitness_tracker/features/training_management/domain/repositories/training_exercise_repository.dart';
import 'package:my_fitness_tracker/features/training_management/domain/usecases/create_multiset.dart';
import 'package:my_fitness_tracker/features/training_management/domain/usecases/create_training_exercise.dart';

class MockMultisetRepository extends Mock implements MultisetRepository {}

class MockTrainingExerciseRepository extends Mock
    implements TrainingExerciseRepository {}

void main() {
  late CreateMultiset createMultiset;
  late MockMultisetRepository mockMultisetRepository;
  late CreateTrainingExercise createTrainingExercise;
  late MockTrainingExerciseRepository mockTrainingExerciseRepository;

  setUp(() {
    mockMultisetRepository = MockMultisetRepository();
    mockTrainingExerciseRepository = MockTrainingExerciseRepository();
    createTrainingExercise =
        CreateTrainingExercise(mockTrainingExerciseRepository);
    createMultiset =
        CreateMultiset(mockMultisetRepository, createTrainingExercise);
  });

  group('CreateMultiset', () {
    const trainingId = 1;
    const multisetId = 2;
    const sets = 3;
    const setRest = 10;
    const multisetRest = 15;
    const specialInstructions = 'Focus on form';
    const objectives = 'Improve endurance';
    const exerciseId = 1;

    const yogaExercise = YogaExercise(
      specialInstructions: specialInstructions,
      objectives: objectives,
      multisetId: multisetId,
      trainingId: trainingId,
      exerciseId: exerciseId,
      sets: 3,
      reps: 5,
      duration: 30,
      setRest: 10,
      exerciseRest: 15,
      manualStart: true,
    );

    const yogaParams = CreateTrainingExerciseParams(
      exerciseType: ExerciseType.yoga,
      trainingId: trainingId,
      multisetId: multisetId,
      exerciseId: exerciseId,
      sets: 3,
      reps: 5,
      duration: 30,
      setRest: 10,
      exerciseRest: 15,
      manualStart: true,
      specialInstructions: specialInstructions,
      objectives: objectives,
    );
    const multisetParams = CreateMultisetParams(
      id: multisetId,
      trainingId: trainingId,
      exercises: [yogaParams],
      sets: sets,
      setRest: setRest,
      multisetRest: multisetRest,
      specialInstructions: specialInstructions,
      objectives: objectives,
    );

    const multiset = Multiset(
      id: multisetId,
      trainingId: trainingId,
      exercises: [yogaExercise],
      sets: sets,
      setRest: setRest,
      multisetRest: multisetRest,
      specialInstructions: specialInstructions,
      objectives: objectives,
    );

    const multisetNoExercise = Multiset(
      id: multisetId,
      trainingId: trainingId,
      exercises: [],
      sets: sets,
      setRest: setRest,
      multisetRest: multisetRest,
      specialInstructions: specialInstructions,
      objectives: objectives,
    );

    test('should create a multiset and associated exercises successfully',
        () async {
      // Arrange: Mock successful multiset and training exercises
      when(() => mockMultisetRepository.createMultiset(multiset))
          .thenAnswer((_) async => const Right(multiset));
      when(() => mockTrainingExerciseRepository.createTrainingExercise(
          yogaExercise)).thenAnswer((_) async => const Right(yogaExercise));

      // Act
      final result = await createMultiset(multisetParams);

      // Assert
      expect(result, const Right(multiset));
      verify(() => mockMultisetRepository.createMultiset(multiset)).called(1);
      verify(() => mockTrainingExerciseRepository.createTrainingExercise(
          yogaExercise)).called(multisetParams.exercises.length);
    });

    test('should return failure if creating multiset fails', () async {
      // Arrange: Mock failure from repository
      when(() => mockMultisetRepository.createMultiset(multiset))
          .thenAnswer((_) async => const Left(DatabaseFailure()));
      when(() => mockTrainingExerciseRepository.createTrainingExercise(
          yogaExercise)).thenAnswer((_) async => const Right(yogaExercise));

      // Act
      final result = await createMultiset(multisetParams);

      // Assert
      expect(result, const Left(DatabaseFailure()));
      verify(() => mockMultisetRepository.createMultiset(multiset)).called(1);
    });

    test('should return failure if creating any training exercise fails',
        () async {
      // Arrange: Mock successful multiset creation but failure for training exercise
      when(() => mockMultisetRepository.createMultiset(multiset))
          .thenAnswer((_) async => const Right(multiset));
      when(() => mockTrainingExerciseRepository.createTrainingExercise(
          yogaExercise)).thenAnswer((_) async => const Left(DatabaseFailure()));

      // Act
      final result = await createMultiset(multisetParams);

      // Assert
      expect(result, const Left(DatabaseFailure()));
      verify(() => mockMultisetRepository.createMultiset(multisetNoExercise))
          .called(1);
      verify(() => mockTrainingExerciseRepository.createTrainingExercise(
          yogaExercise)).called(multisetParams.exercises.length);
    });

    test('should return DatabaseFailure if an exception is thrown', () async {
      // Arrange: Simulate an unexpected exception
      when(() => mockMultisetRepository.createMultiset(multiset))
          .thenThrow(Exception());

      // Act
      final result = await createMultiset(multisetParams);

      // Assert
      expect(result, const Left(DatabaseFailure()));
      verify(() => mockMultisetRepository.createMultiset(multisetNoExercise))
          .called(1);
    });
  });
}
