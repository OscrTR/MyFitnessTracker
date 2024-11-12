import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_fitness_tracker/core/error/failures.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/multiset.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/training.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/training_exercise.dart';
import 'package:my_fitness_tracker/features/training_management/domain/repositories/training_repository.dart';
import 'package:my_fitness_tracker/features/training_management/domain/usecases/get_training.dart';

class MockTrainingRepository extends Mock implements TrainingRepository {}

void main() {
  late GetTraining usecase;
  late MockTrainingRepository mockTrainingRepository;

  setUp(() {
    mockTrainingRepository = MockTrainingRepository();
    usecase = GetTraining(mockTrainingRepository);
  });

  group('GetTraining UseCase', () {
    const tId = 1;
    const tParams = Params(tId);
    const tTraining = Training(
      id: 1,
      name: 'Morning Yoga',
      type: TrainingType.yoga,
      isSelected: true,
      trainingExercises: [
        TrainingExercise(
          id: 1,
          trainingId: 1,
          multisetId: 1,
          exerciseId: 100,
          trainingExerciseType: TrainingExerciseType.yoga,
          specialInstructions: 'Breathe slowly',
          objectives: 'Relaxation',
          targetDistance: null,
          targetDuration: 10,
          targetRythm: null,
          intervals: null,
          intervalDistance: null,
          intervalDuration: null,
          intervalRest: null,
          sets: 2,
          isSetsInReps: true,
          minReps: 8,
          maxReps: 12,
          actualReps: 5,
          duration: 60,
          setRest: 30,
          exerciseRest: 10,
          manualStart: true,
        ),
      ],
      multisets: [
        Multiset(
            id: 1,
            trainingId: 1,
            trainingExercises: [
              TrainingExercise(
                id: 2,
                trainingId: 1,
                multisetId: 1,
                exerciseId: 101,
                trainingExerciseType: TrainingExerciseType.yoga,
                specialInstructions: 'Focus on posture',
                objectives: 'Flexibility',
                targetDistance: null,
                targetDuration: 15,
                targetRythm: null,
                intervals: 3,
                intervalDistance: 0,
                intervalDuration: 5,
                intervalRest: 2,
                sets: 3,
                isSetsInReps: true,
                minReps: 8,
                maxReps: 12,
                actualReps: 8,
                duration: 45,
                setRest: 20,
                exerciseRest: 15,
                manualStart: false,
              ),
            ],
            sets: 3,
            setRest: 60,
            multisetRest: 120,
            specialInstructions: 'Alternate sides',
            objectives: 'Balance',
            position: 0),
      ],
    );

    test('should call getTraining on the repository and return Right(Training)',
        () async {
      // Arrange
      when(() => mockTrainingRepository.getTraining(tId))
          .thenAnswer((_) async => const Right(tTraining));

      // Act
      final result = await usecase(tParams);

      // Assert
      verify(() => mockTrainingRepository.getTraining(tId)).called(1);
      expect(result, const Right(tTraining));
    });

    test(
        'should return Left(DatabaseFailure) when repository throws an exception',
        () async {
      // Arrange
      when(() => mockTrainingRepository.getTraining(tId))
          .thenThrow(Exception());

      // Act
      final result = await usecase(tParams);

      // Assert
      expect(result, const Left(DatabaseFailure()));
    });
  });
}
