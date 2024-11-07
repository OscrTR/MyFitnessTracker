import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_fitness_tracker/core/error/failures.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/training.dart';
import 'package:my_fitness_tracker/features/training_management/domain/repositories/training_repository.dart';
import 'package:my_fitness_tracker/features/training_management/domain/usecases/update_training.dart';

class MockTrainingRepository extends Mock implements TrainingRepository {}

void main() {
  late UpdateTraining usecase;
  late MockTrainingRepository mockTrainingRepository;

  setUp(() {
    mockTrainingRepository = MockTrainingRepository();
    usecase = UpdateTraining(mockTrainingRepository);
  });

  group('UpdateTraining UseCase', () {
    const tTraining = Training(
      id: 1,
      name: 'Morning Yoga',
      type: TrainingType.yoga,
      isSelected: true,
      trainingExercises: [],
      multisets: [],
    );

    const tParams = Params(tTraining);

    test(
        'should call updateTraining on the repository and return Right(Training)',
        () async {
      // Arrange
      when(() => mockTrainingRepository.updateTraining(tTraining))
          .thenAnswer((_) async => const Right(tTraining));

      // Act
      final result = await usecase(tParams);

      // Assert
      verify(() => mockTrainingRepository.updateTraining(tTraining)).called(1);
      expect(result, const Right(tTraining));
    });

    test(
        'should return Left(InvalidExerciseNameFailure) when training name is empty',
        () async {
      // Arrange
      const invalidTraining = Training(
        id: 2,
        name: '', // Invalid name
        type: TrainingType.yoga,
        isSelected: false,
        trainingExercises: [],
        multisets: [],
      );
      const invalidParams = Params(invalidTraining);

      // Act
      final result = await usecase(invalidParams);

      // Assert
      expect(result, const Left(InvalidNameFailure()));
      verifyNever(() => mockTrainingRepository.updateTraining(invalidTraining));
    });

    test(
        'should return Left(DatabaseFailure) when repository throws an exception',
        () async {
      // Arrange
      when(() => mockTrainingRepository.updateTraining(tTraining))
          .thenThrow(Exception());

      // Act
      final result = await usecase(tParams);

      // Assert
      expect(result, const Left(DatabaseFailure()));
    });
  });
}
