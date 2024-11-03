import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_fitness_tracker/core/error/failures.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/multiset.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/training.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/yoga_exercise.dart';
import 'package:my_fitness_tracker/features/training_management/domain/repositories/multiset_repository.dart';
import 'package:my_fitness_tracker/features/training_management/domain/repositories/training_exercise_repository.dart';

import 'package:my_fitness_tracker/features/training_management/domain/repositories/training_repository.dart';
import 'package:my_fitness_tracker/features/training_management/domain/usecases/create_multiset.dart';
import 'package:my_fitness_tracker/features/training_management/domain/usecases/create_training.dart';
import 'package:my_fitness_tracker/features/training_management/domain/usecases/create_training_exercise.dart';

class MockTrainingRepository extends Mock implements TrainingRepository {}

class MockTrainingExerciseRepository extends Mock
    implements TrainingExerciseRepository {}

class MockMultisetRepository extends Mock implements MultisetRepository {}

void main() {
  late MockTrainingRepository mockTrainingRepository;
  late MockTrainingExerciseRepository mockTrainingExerciseRepository;
  late MockMultisetRepository mockMultisetRepository;
  late CreateTraining createTraining;
  late CreateMultiset createMultiset;
  late CreateTrainingExercise createTrainingExercise;

  setUp(() {
    mockTrainingRepository = MockTrainingRepository();
    mockTrainingExerciseRepository = MockTrainingExerciseRepository();
    mockMultisetRepository = MockMultisetRepository();
    createTrainingExercise =
        CreateTrainingExercise(mockTrainingExerciseRepository);
    createMultiset =
        CreateMultiset(mockMultisetRepository, createTrainingExercise);
    createTraining = CreateTraining(
        mockTrainingRepository, createMultiset, createTrainingExercise);
  });

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

  const training = Training(
    name: 'My first training',
    type: TrainingType.yoga,
    isSelected: true,
    exercises: [yogaExercise],
    multisets: [multiset],
  );

  const trainingNoMultisets = Training(
    name: 'My first training',
    type: TrainingType.yoga,
    isSelected: true,
    exercises: [yogaExercise],
    multisets: [],
  );

  const trainingNoExercisesNoMultisets = Training(
    name: 'My first training',
    type: TrainingType.yoga,
    isSelected: true,
    exercises: [],
    multisets: [],
  );

  const trainingParams = CreateTrainingParams(
    name: 'My first training',
    type: TrainingType.yoga,
    isSelected: true,
    exercises: [yogaParams],
    multisets: [multisetParams],
  );

  group('Create training', () {
    test(
      'should create a training, its multisets and exercises succefully',
      () async {
        // Arrange
        when(() => mockTrainingRepository.createTraining(training))
            .thenAnswer((_) async => const Right(training));
        when(() => mockMultisetRepository.createMultiset(multiset))
            .thenAnswer((_) async => const Right(multiset));
        when(() => mockTrainingExerciseRepository.createTrainingExercise(
            yogaExercise)).thenAnswer((_) async => const Right(yogaExercise));

        // Act
        final result = await createTraining(trainingParams);

        // Assert
        expect(result, const Right(training));
        verify(() => mockTrainingRepository.createTraining(training)).called(1);
        verify(() => mockMultisetRepository.createMultiset(multiset))
            .called(training.multisets.length);
        verify(() => mockTrainingExerciseRepository
                .createTrainingExercise(yogaExercise))
            .called(training.exercises.length + multiset.exercises.length);
      },
    );

    test(
      'should return failure if creating training fails',
      () async {
        // Arrange
        when(() => mockTrainingRepository.createTraining(training))
            .thenAnswer((_) async => const Left(DatabaseFailure()));
        when(() => mockMultisetRepository.createMultiset(multiset))
            .thenAnswer((_) async => const Right(multiset));
        when(() => mockTrainingExerciseRepository.createTrainingExercise(
            yogaExercise)).thenAnswer((_) async => const Right(yogaExercise));

        // Act
        final result = await createTraining(trainingParams);

        // Assert
        expect(result, const Left(DatabaseFailure()));
        verify(() => mockTrainingRepository.createTraining(training)).called(1);
        verify(() => mockMultisetRepository.createMultiset(multiset))
            .called(training.multisets.length);
        verify(() => mockTrainingExerciseRepository
                .createTrainingExercise(yogaExercise))
            .called(training.exercises.length + multiset.exercises.length);
      },
    );

    test(
      'should should return failure if creating any multiset fails',
      () async {
        // Arrange
        when(() => mockTrainingRepository.createTraining(training))
            .thenAnswer((_) async => const Right(training));
        when(() => mockMultisetRepository.createMultiset(multiset))
            .thenAnswer((_) async => const Left(DatabaseFailure()));
        when(() => mockTrainingExerciseRepository.createTrainingExercise(
            yogaExercise)).thenAnswer((_) async => const Right(yogaExercise));

        // Act
        final result = await createTraining(trainingParams);

        // Assert
        expect(result, const Left(DatabaseFailure()));
        verify(() => mockTrainingRepository.createTraining(trainingNoMultisets))
            .called(1);
        verify(() => mockMultisetRepository.createMultiset(multiset))
            .called(training.multisets.length);
        verify(() => mockTrainingExerciseRepository
                .createTrainingExercise(yogaExercise))
            .called(training.exercises.length + multiset.exercises.length);
      },
    );

    test(
      'should return failure if creating any training exercise fails',
      () async {
        // Arrange
        when(() => mockTrainingRepository.createTraining(training))
            .thenAnswer((_) async => const Right(training));
        when(() => mockMultisetRepository.createMultiset(multiset))
            .thenAnswer((_) async => const Right(multiset));
        when(() => mockTrainingExerciseRepository
                .createTrainingExercise(yogaExercise))
            .thenAnswer((_) async => const Left(DatabaseFailure()));

        // Act
        final result = await createTraining(trainingParams);

        // Assert
        expect(result, const Left(DatabaseFailure()));
        verify(() => mockTrainingRepository
            .createTraining(trainingNoExercisesNoMultisets)).called(1);
        verify(() => mockMultisetRepository.createMultiset(multisetNoExercise))
            .called(training.multisets.length);
        verify(() => mockTrainingExerciseRepository
                .createTrainingExercise(yogaExercise))
            .called(training.exercises.length + multiset.exercises.length);
      },
    );

    test(
      'should return DatabaseFailure if an exception is thrown',
      () async {
        // Arrange
        when(() => mockTrainingRepository.createTraining(training))
            .thenThrow(Exception());

        // Act
        final result = await createTraining(trainingParams);

        // Assert
        expect(result, const Left(DatabaseFailure()));
        verify(() => mockTrainingRepository
            .createTraining(trainingNoExercisesNoMultisets)).called(1);
      },
    );
  });
}
