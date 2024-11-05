import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_fitness_tracker/core/error/failures.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/multiset.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/training.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/training_exercise.dart';

import 'package:my_fitness_tracker/features/training_management/domain/repositories/multiset_repository.dart';
import 'package:my_fitness_tracker/features/training_management/domain/repositories/training_exercise_repository.dart';

import 'package:my_fitness_tracker/features/training_management/domain/repositories/training_repository.dart';
import 'package:my_fitness_tracker/features/training_management/domain/usecases/create_training.dart';

class MockTrainingRepository extends Mock implements TrainingRepository {}

class MockTrainingExerciseRepository extends Mock
    implements TrainingExerciseRepository {}

class MockMultisetRepository extends Mock implements MultisetRepository {}

void main() {
  late MockTrainingRepository mockTrainingRepository;
  late CreateTraining createTraining;

  setUp(() {
    mockTrainingRepository = MockTrainingRepository();
    createTraining = CreateTraining(mockTrainingRepository);
  });

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

  const training = Training(
    name: 'My first training',
    type: TrainingType.yoga,
    isSelected: true,
    trainingExercises: [trainingExercise],
    multisets: [multiset],
  );

  group('Create training', () {
    test(
      'should create a training, its multisets and exercises succefully',
      () async {
        // Arrange
        when(() => mockTrainingRepository.createTraining(training))
            .thenAnswer((_) async => const Right(training));

        // Act
        final result = await createTraining(const Params(training));

        // Assert
        expect(result, const Right(training));
        verify(() => mockTrainingRepository.createTraining(training)).called(1);
      },
    );

    test(
      'should return failure if creating training fails',
      () async {
        // Arrange
        when(() => mockTrainingRepository.createTraining(training))
            .thenAnswer((_) async => const Left(DatabaseFailure()));

        // Act
        final result = await createTraining(const Params(training));

        // Assert
        expect(result, const Left(DatabaseFailure()));
        verify(() => mockTrainingRepository.createTraining(training)).called(1);
      },
    );

    test(
      'should return DatabaseFailure if an exception is thrown',
      () async {
        // Arrange
        when(() => mockTrainingRepository.createTraining(training))
            .thenThrow(Exception());

        // Act
        final result = await createTraining(const Params(training));

        // Assert
        expect(result, const Left(DatabaseFailure()));
        verify(() => mockTrainingRepository.createTraining(training)).called(1);
      },
    );
  });
}
