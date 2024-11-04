import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_fitness_tracker/core/error/failures.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/training_exercise.dart';
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

    test('should create a TrainingExercise', () async {
      when(() => mockRepository.createTrainingExercise(trainingExercise))
          .thenAnswer(
        (_) async => const Right(trainingExercise),
      );

      final result =
          await createTrainingExercise(const Params(trainingExercise));

      expect(result, const Right(trainingExercise));
      verify(() => mockRepository.createTrainingExercise(trainingExercise));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return DatabaseFailure on exception', () async {
      when(() => mockRepository.createTrainingExercise(trainingExercise))
          .thenAnswer((_) async => const Left(DatabaseFailure()));

      final result =
          await createTrainingExercise(const Params(trainingExercise));

      expect(result, equals(const Left(DatabaseFailure())));
      verify(() => mockRepository.createTrainingExercise(trainingExercise))
          .called(1);
    });
  });
}
