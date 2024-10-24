import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_fitness_tracker/core/error/failures.dart';
import 'package:my_fitness_tracker/features/exercise_management/domain/entities/exercise.dart';
import 'package:my_fitness_tracker/features/exercise_management/domain/usecases/create_exercise.dart';
import 'package:my_fitness_tracker/features/exercise_management/presentation/bloc/exercise_management_bloc.dart';

class MockCreateExercise extends Mock implements CreateExercise {}

void main() {
  late ExerciseManagementBloc bloc;
  late MockCreateExercise mockCreateExercise;

  setUp(() {
    mockCreateExercise = MockCreateExercise();
    bloc = ExerciseManagementBloc(createExercise: mockCreateExercise);
  });

  test('initial state should be ExerciseManagementInitial', () {
    expect(bloc.state, equals(ExerciseManagementInitial()));
  });

  group('CreateExerciseEvent', () {
    const tExerciseName = 'Push-up';
    const tExerciseDescription = 'Upper body exercise';
    const tExerciseImageName = 'pushup.png';
    final tExercise = Exercise(
      name: tExerciseName,
      description: tExerciseDescription,
      imageName: tExerciseImageName,
    );

    blocTest<ExerciseManagementBloc, ExerciseManagementState>(
      'should emit [ExerciseManagementLoading, ExerciseManagementSuccess] when exercise creation is successful',
      build: () => bloc,
      setUp: () {
        // Arrange: Mock success response from createExercise
        when(() => mockCreateExercise(const Params(
                name: tExerciseName,
                description: tExerciseDescription,
                imageName: tExerciseImageName)))
            .thenAnswer((_) async => Right(tExercise));
      },
      act: (bloc) => bloc.add(const CreateExerciseEvent(
        name: tExerciseName,
        description: tExerciseDescription,
        imageName: tExerciseImageName,
      )),
      expect: () => [
        ExerciseManagementLoading(),
        ExerciseManagementSuccess(tExercise),
      ],
    );

    blocTest<ExerciseManagementBloc, ExerciseManagementState>(
      'should emit [ExerciseManagementLoading, ExerciseManagementFailure] when exercise creation fails',
      build: () => bloc,
      setUp: () {
        // Arrange: Mock failure response from createExercise
        when(() => mockCreateExercise(const Params(
                name: tExerciseName,
                description: tExerciseDescription,
                imageName: tExerciseImageName)))
            .thenAnswer((_) async => const Left(DatabaseFailure()));
      },
      act: (bloc) => bloc.add(const CreateExerciseEvent(
        name: tExerciseName,
        description: tExerciseDescription,
        imageName: tExerciseImageName,
      )),
      expect: () => [
        ExerciseManagementLoading(),
        const ExerciseManagementFailure(message: databaseFailureMessage),
      ],
    );
  });
}
