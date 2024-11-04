import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_fitness_tracker/core/error/failures.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/run_exercise.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/workout_exercise.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/yoga_exercise.dart';
import 'package:my_fitness_tracker/features/training_management/domain/usecases/create_training_exercise.dart';
import 'package:my_fitness_tracker/features/training_management/domain/repositories/training_exercise_repository.dart';

class MockTrainingExerciseRepository extends Mock
    implements TrainingExerciseRepository {}

void main() {
  late CreateTrainingExercise createTrainingExercise;
  late MockTrainingExerciseRepository mockRepository;

  setUp(() {
    mockRepository = MockTrainingExerciseRepository();
    createTrainingExercise = CreateTrainingExercise(mockRepository);
  });

  group('CreateTrainingExercise', () {
    const trainingId = 1;
    const multisetId = 2;
    const exerciseId = 1;
    const specialInstructions = 'Focus on breathing';
    const objectives = 'Increase flexibility';

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

    const workoutExercise = WorkoutExercise(
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

    const runExercise = RunExercise(
      trainingId: trainingId,
      multisetId: multisetId,
      targetDistance: 5000,
      targetDuration: 1800,
      targetRythm: 300,
      intervals: 5,
      intervalDistance: 1000,
      intervalDuration: 200,
      intervalRest: 60,
      specialInstructions: specialInstructions,
      objectives: objectives,
    );

    test('should create a YogaExercise when exerciseType is yoga', () async {
      when(() => mockRepository.createTrainingExercise(yogaExercise))
          .thenAnswer(
        (_) async => const Right(yogaExercise),
      );

      final result = await createTrainingExercise(const Params(yogaExercise));

      expect(result, const Right(yogaExercise));
      verify(() => mockRepository.createTrainingExercise(yogaExercise));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should create a WorkoutExercise when exerciseType is workout',
        () async {
      when(() => mockRepository.createTrainingExercise(workoutExercise))
          .thenAnswer(
        (_) async => const Right(workoutExercise),
      );

      final result =
          await createTrainingExercise(const Params(workoutExercise));

      expect(result, const Right(workoutExercise));
      verify(() => mockRepository.createTrainingExercise(workoutExercise));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should create a RunExercise when exerciseType is run', () async {
      when(() => mockRepository.createTrainingExercise(runExercise)).thenAnswer(
        (_) async => const Right(runExercise),
      );

      final result = await createTrainingExercise(const Params(runExercise));

      expect(result, const Right(runExercise));
      verify(() => mockRepository.createTrainingExercise(runExercise));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return DatabaseFailure on exception', () async {
      when(() => mockRepository.createTrainingExercise(runExercise))
          .thenAnswer((_) async => const Left(DatabaseFailure()));

      final result = await createTrainingExercise(const Params(yogaExercise));

      expect(result, equals(const Left(DatabaseFailure())));
      verify(() => mockRepository.createTrainingExercise(yogaExercise))
          .called(1);
    });
  });
}
