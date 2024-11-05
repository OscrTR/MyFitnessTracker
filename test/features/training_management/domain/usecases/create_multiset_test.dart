import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:my_fitness_tracker/core/error/failures.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/multiset.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/training_exercise.dart';
import 'package:my_fitness_tracker/features/training_management/domain/repositories/multiset_repository.dart';
import 'package:my_fitness_tracker/features/training_management/domain/repositories/training_exercise_repository.dart';
import 'package:my_fitness_tracker/features/training_management/domain/usecases/create_multiset.dart';

class MockMultisetRepository extends Mock implements MultisetRepository {}

class MockTrainingExerciseRepository extends Mock
    implements TrainingExerciseRepository {}

void main() {
  late CreateMultiset createMultiset;
  late MockMultisetRepository mockMultisetRepository;

  setUp(() {
    mockMultisetRepository = MockMultisetRepository();
    createMultiset = CreateMultiset(mockMultisetRepository);
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

    const trainingExercise = TrainingExercise(
      id: 1,
      trainingExerciseType: TrainingExerciseType.yoga,
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
      targetDistance: null,
      targetDuration: null,
      targetRythm: null,
      intervals: null,
      intervalDistance: null,
      intervalDuration: null,
      intervalRest: null,
    );

    const multiset = Multiset(
      id: multisetId,
      trainingId: trainingId,
      trainingExercises: [trainingExercise],
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

      // Act
      final result = await createMultiset(const Params(multiset));

      // Assert
      expect(result, const Right(multiset));
      verify(() => mockMultisetRepository.createMultiset(multiset)).called(1);
    });

    test('should return failure if creating multiset fails', () async {
      // Arrange: Mock failure from repository
      when(() => mockMultisetRepository.createMultiset(multiset))
          .thenAnswer((_) async => const Left(DatabaseFailure()));

      // Act
      final result = await createMultiset(const Params(multiset));

      // Assert
      expect(result, const Left(DatabaseFailure()));
      verify(() => mockMultisetRepository.createMultiset(multiset)).called(1);
    });

    test('should return DatabaseFailure if an exception is thrown', () async {
      // Arrange: Simulate an unexpected exception
      when(() => mockMultisetRepository.createMultiset(multiset))
          .thenThrow(Exception());

      // Act
      final result = await createMultiset(const Params(multiset));

      // Assert
      expect(result, const Left(DatabaseFailure()));
      verify(() => mockMultisetRepository.createMultiset(multiset)).called(1);
    });
  });
}
