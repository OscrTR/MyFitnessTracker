import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_fitness_tracker/core/error/failures.dart';
import 'package:my_fitness_tracker/features/training_management/domain/repositories/training_repository.dart';
import 'package:my_fitness_tracker/features/training_management/domain/usecases/delete_training.dart';

class MockTrainingRepository extends Mock implements TrainingRepository {}

void main() {
  late DeleteTraining usecase;
  late MockTrainingRepository mockTrainingRepository;

  setUp(() {
    mockTrainingRepository = MockTrainingRepository();
    usecase = DeleteTraining(mockTrainingRepository);
  });

  group('DeleteTraining UseCase', () {
    const tId = 1;
    const tParams = Params(tId);

    test('should call deleteTraining on the repository and return Right(void)',
        () async {
      // Arrange
      when(() => mockTrainingRepository.deleteTraining(tId))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await usecase(tParams);

      // Assert
      verify(() => mockTrainingRepository.deleteTraining(tId)).called(1);
      expect(result, const Right(null));
    });

    test(
        'should return Left(DatabaseFailure) when repository throws an exception',
        () async {
      // Arrange
      when(() => mockTrainingRepository.deleteTraining(tId))
          .thenThrow(Exception());

      // Act
      final result = await usecase(tParams);

      // Assert
      expect(result, const Left(DatabaseFailure()));
    });
  });
}
