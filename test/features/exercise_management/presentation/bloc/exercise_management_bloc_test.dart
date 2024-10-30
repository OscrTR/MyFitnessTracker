import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_fitness_tracker/core/error/failures.dart';
import 'package:my_fitness_tracker/core/messages/bloc/message_bloc.dart';
import 'package:my_fitness_tracker/features/exercise_management/domain/entities/exercise.dart';
import 'package:my_fitness_tracker/features/exercise_management/domain/usecases/create_exercise.dart'
    as create;
import 'package:my_fitness_tracker/features/exercise_management/domain/usecases/delete_exercise.dart'
    as delete;
import 'package:my_fitness_tracker/features/exercise_management/domain/usecases/fetch_exercises.dart'
    as fetch;
import 'package:my_fitness_tracker/features/exercise_management/domain/usecases/get_exercise.dart'
    as get_ex;
import 'package:my_fitness_tracker/features/exercise_management/domain/usecases/update_exercise.dart'
    as update;
import 'package:my_fitness_tracker/features/exercise_management/presentation/bloc/exercise_management_bloc.dart';

class MockCreateExercise extends Mock implements create.CreateExercise {}

class MockFetchExercises extends Mock implements fetch.FetchExercises {}

class MockGetExercise extends Mock implements get_ex.GetExercise {}

class MockUpdateExercise extends Mock implements update.UpdateExercise {}

class MockDeleteExercise extends Mock implements delete.DeleteExercise {}

class MockMessageBloc extends Mock implements MessageBloc {}

void main() {
  late ExerciseManagementBloc bloc;
  late MockMessageBloc mockMessageBloc;
  late MockCreateExercise mockCreateExercise;
  late MockFetchExercises mockFetchExercises;
  late MockGetExercise mockGetExercise;
  late MockUpdateExercise mockUpdateExercise;
  late MockDeleteExercise mockDeleteExercise;

  setUp(() {
    mockCreateExercise = MockCreateExercise();
    mockFetchExercises = MockFetchExercises();
    mockGetExercise = MockGetExercise();
    mockUpdateExercise = MockUpdateExercise();
    mockDeleteExercise = MockDeleteExercise();
    mockMessageBloc = MockMessageBloc();
    bloc = ExerciseManagementBloc(
        createExercise: mockCreateExercise,
        fetchExercises: mockFetchExercises,
        getExercise: mockGetExercise,
        updateExercise: mockUpdateExercise,
        deleteExercise: mockDeleteExercise,
        messageBloc: mockMessageBloc);
  });

  test('initial state should be ExerciseManagementInitial', () {
    expect(bloc.state, equals(ExerciseManagementInitial()));
  });

  group('CreateExerciseEvent', () {
    const tExerciseName = 'Push-up';
    const tExerciseDescription = 'Upper body exercise';
    const tExerciseimagePath = 'pushup.png';
    final tExercise = Exercise(
      name: tExerciseName,
      description: tExerciseDescription,
      imagePath: tExerciseimagePath,
    );

    blocTest<ExerciseManagementBloc, ExerciseManagementState>(
      'should emit [ExerciseManagementLoaded] when exercise creation is successful',
      build: () => bloc,
      setUp: () {
        // Arrange: Mock success response from createExercise
        when(() => mockCreateExercise(const create.Params(
                name: tExerciseName,
                description: tExerciseDescription,
                imagePath: tExerciseimagePath)))
            .thenAnswer((_) async => Right(tExercise));
      },
      seed: () => const ExerciseManagementLoaded(exercises: []),
      act: (bloc) => bloc.add(const CreateExerciseEvent(
        name: tExerciseName,
        description: tExerciseDescription,
        imagePath: tExerciseimagePath,
      )),
      expect: () => [
        ExerciseManagementLoaded(exercises: [tExercise]),
      ],
    );

    blocTest<ExerciseManagementBloc, ExerciseManagementState>(
      'should emit [ErrorMessage] when exercise creation fails',
      build: () => bloc,
      setUp: () {
        // Arrange: Mock success response from createExercise
        when(() => mockCreateExercise(const create.Params(
                name: '',
                description: tExerciseDescription,
                imagePath: tExerciseimagePath)))
            .thenAnswer((_) async => const Left(InvalidExerciseNameFailure()));
      },
      seed: () => const ExerciseManagementLoaded(exercises: []),
      act: (bloc) => bloc.add(const CreateExerciseEvent(
        name: '',
        description: tExerciseDescription,
        imagePath: tExerciseimagePath,
      )),
      verify: (_) {
        // Confirm the message bloc received the error event
        verify(() => mockMessageBloc.add(const AddMessageEvent(
              message: invalidExerciseNameFailureMessage,
              isError: true,
            ))).called(1);
      },
    );
  });
}
