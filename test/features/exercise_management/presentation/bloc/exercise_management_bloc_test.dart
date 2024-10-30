import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:my_fitness_tracker/core/error/failures.dart';
import 'package:my_fitness_tracker/core/messages/bloc/message_bloc.dart';
import 'package:my_fitness_tracker/features/exercise_management/domain/entities/exercise.dart';
import 'package:my_fitness_tracker/features/exercise_management/domain/usecases/create_exercise.dart'
    as create;
import 'package:my_fitness_tracker/features/exercise_management/domain/usecases/delete_exercise.dart'
    as delete;
import 'package:my_fitness_tracker/features/exercise_management/domain/usecases/fetch_exercises.dart';
import 'package:my_fitness_tracker/features/exercise_management/domain/usecases/get_exercise.dart'
    as get_ex;
import 'package:my_fitness_tracker/features/exercise_management/domain/usecases/update_exercise.dart'
    as update;
import 'package:my_fitness_tracker/features/exercise_management/presentation/bloc/exercise_management_bloc.dart';

// Mocks
class MockCreateExercise extends Mock implements create.CreateExercise {}

class MockFetchExercises extends Mock implements FetchExercises {}

class MockUpdateExercise extends Mock implements update.UpdateExercise {}

class MockDeleteExercise extends Mock implements delete.DeleteExercise {}

class MockGetExercise extends Mock implements get_ex.GetExercise {}

class MockMessageBloc extends Mock implements MessageBloc {}

void main() {
  late ExerciseManagementBloc bloc;
  late MockCreateExercise mockCreateExercise;
  late MockFetchExercises mockFetchExercises;
  late MockUpdateExercise mockUpdateExercise;
  late MockDeleteExercise mockDeleteExercise;
  late MockGetExercise mockGetExercise;
  late MockMessageBloc mockMessageBloc;

  setUp(() {
    mockCreateExercise = MockCreateExercise();
    mockFetchExercises = MockFetchExercises();
    mockUpdateExercise = MockUpdateExercise();
    mockDeleteExercise = MockDeleteExercise();
    mockGetExercise = MockGetExercise();
    mockMessageBloc = MockMessageBloc();

    bloc = ExerciseManagementBloc(
      createExercise: mockCreateExercise,
      fetchExercises: mockFetchExercises,
      updateExercise: mockUpdateExercise,
      deleteExercise: mockDeleteExercise,
      getExercise: mockGetExercise,
      messageBloc: mockMessageBloc,
    );

    registerFallbackValue(
        const AddMessageEvent(message: 'Test message', isError: true));
  });

  group('FetchExercisesEvent', () {
    var tExercises = [
      Exercise(
          id: 1,
          name: 'Squats',
          description: 'A lower body exercise',
          imagePath: '/images/squats.png'),
    ];

    blocTest<ExerciseManagementBloc, ExerciseManagementState>(
      'emits [ExerciseManagementLoaded] when FetchExercisesEvent is successful',
      build: () {
        when(() => mockFetchExercises(null))
            .thenAnswer((_) async => Right(tExercises));
        return bloc;
      },
      act: (bloc) => bloc.add(FetchExercisesEvent()),
      expect: () => [ExerciseManagementLoaded(exercises: tExercises)],
      verify: (_) {
        verify(() => mockFetchExercises(null)).called(1);
      },
    );

    blocTest<ExerciseManagementBloc, ExerciseManagementState>(
      'calls messageBloc with error when FetchExercisesEvent fails',
      build: () {
        when(() => mockFetchExercises(null))
            .thenAnswer((_) async => const Left(DatabaseFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(FetchExercisesEvent()),
      expect: () => [],
      verify: (_) {
        verify(() => mockFetchExercises(null)).called(1);
        verify(() => mockMessageBloc.add(const AddMessageEvent(
              message: databaseFailureMessage,
              isError: true,
            ))).called(1);
      },
    );
  });

  group('CreateExerciseEvent', () {
    final tExercise = Exercise(
        id: 1,
        name: 'Squats',
        description: 'A lower body exercise',
        imagePath: '/images/squats.png');
    const params = create.Params(
        name: 'Squats',
        description: 'A lower body exercise',
        imagePath: '/images/squats.png');

    blocTest<ExerciseManagementBloc, ExerciseManagementState>(
      'emits updated ExerciseManagementLoaded when CreateExerciseEvent is successful',
      build: () {
        when(() => mockCreateExercise(params))
            .thenAnswer((_) async => Right(tExercise));
        return bloc;
      },
      seed: () => const ExerciseManagementLoaded(exercises: []),
      act: (bloc) => bloc.add(const CreateExerciseEvent(
          name: 'Squats',
          description: 'A lower body exercise',
          imagePath: '/images/squats.png')),
      expect: () => [
        ExerciseManagementLoaded(exercises: [tExercise]),
      ],
      verify: (_) {
        verify(() => mockCreateExercise(params)).called(1);
        verify(() => mockMessageBloc.add(const AddMessageEvent(
              message: 'Exercise Squats created successfully.',
              isError: false,
            ))).called(1);
      },
    );

    blocTest<ExerciseManagementBloc, ExerciseManagementState>(
      'calls messageBloc with error when CreateExerciseEvent fails due to invalid name',
      build: () {
        when(() => mockCreateExercise(params))
            .thenAnswer((_) async => const Left(InvalidExerciseNameFailure()));
        return bloc;
      },
      seed: () => const ExerciseManagementLoaded(exercises: []),
      act: (bloc) => bloc.add(const CreateExerciseEvent(
          name: 'Squats',
          description: 'A lower body exercise',
          imagePath: '/images/squats.png')),
      expect: () => [],
      verify: (_) {
        verify(() => mockCreateExercise(params)).called(1);
        verify(() => mockMessageBloc.add(const AddMessageEvent(
              message: invalidExerciseNameFailureMessage,
              isError: true,
            ))).called(1);
      },
    );
  });

  group('GetExerciseEvent', () {
    const tExerciseId = 1;
    final tExercise = Exercise(
      id: tExerciseId,
      name: 'Push Up',
      description: 'An upper body exercise',
      imagePath: '/images/push_up.png',
    );

    blocTest<ExerciseManagementBloc, ExerciseManagementState>(
      'emits updated ExerciseManagementLoaded with selectedExercise when GetExerciseEvent is successful',
      build: () {
        when(() => mockGetExercise(const get_ex.Params(id: tExerciseId)))
            .thenAnswer((_) async => Right(tExercise));
        return bloc;
      },
      seed: () {
        return ExerciseManagementLoaded(exercises: [tExercise]);
      },
      act: (bloc) => (bloc.add(const GetExerciseEvent(tExerciseId))),
      expect: () => [
        ExerciseManagementLoaded(
            exercises: [tExercise], selectedExercise: tExercise),
      ],
      verify: (_) {
        verify(() => mockGetExercise(const get_ex.Params(id: tExerciseId)))
            .called(1);
      },
    );

    blocTest<ExerciseManagementBloc, ExerciseManagementState>(
      'calls messageBloc with error when GetExerciseEvent fails',
      build: () {
        when(() => mockGetExercise(const get_ex.Params(id: tExerciseId)))
            .thenAnswer((_) async => const Left(DatabaseFailure()));
        return bloc;
      },
      seed: () => ExerciseManagementLoaded(exercises: [tExercise]),
      act: (bloc) => bloc.add(const GetExerciseEvent(tExerciseId)),
      expect: () => [],
      verify: (_) {
        verify(() => mockGetExercise(const get_ex.Params(id: tExerciseId)))
            .called(1);
        verify(() => mockMessageBloc.add(const AddMessageEvent(
              message: databaseFailureMessage,
              isError: true,
            ))).called(1);
      },
    );
  });

  group('UpdateExerciseEvent', () {
    const tExerciseId = 1;
    final tUpdatedExercise = Exercise(
      id: tExerciseId,
      name: 'Updated Push Up',
      description: 'An updated upper body exercise',
      imagePath: '/images/updated_push_up.png',
    );

    const updateParams = update.Params(
      id: tExerciseId,
      name: 'Updated Push Up',
      description: 'An updated upper body exercise',
      imagePath: '/images/updated_push_up.png',
    );

    blocTest<ExerciseManagementBloc, ExerciseManagementState>(
      'emits updated ExerciseManagementLoaded with updated exercise and sends success message on successful update',
      build: () {
        when(() => mockUpdateExercise(updateParams))
            .thenAnswer((_) async => Right(tUpdatedExercise));
        return bloc;
      },
      seed: () => ExerciseManagementLoaded(exercises: [
        Exercise(
            id: 1,
            name: 'Push Up',
            description: 'An upper body exercise',
            imagePath: '/images/push_up.png'),
      ]),
      act: (bloc) => bloc.add(const UpdateExerciseEvent(
        id: tExerciseId,
        name: 'Updated Push Up',
        description: 'An updated upper body exercise',
        imagePath: '/images/updated_push_up.png',
      )),
      expect: () => [
        ExerciseManagementLoaded(exercises: [tUpdatedExercise]),
      ],
      verify: (_) {
        verify(() => mockUpdateExercise(updateParams)).called(1);
        verify(() => mockMessageBloc.add(const AddMessageEvent(
              message: 'Exercise Updated Push Up updated successfully.',
              isError: false,
            ))).called(1);
      },
    );

    blocTest<ExerciseManagementBloc, ExerciseManagementState>(
      'does not emit new state and sends error message on update failure',
      build: () {
        when(() => mockUpdateExercise(updateParams))
            .thenAnswer((_) async => const Left(DatabaseFailure()));
        return bloc;
      },
      seed: () => ExerciseManagementLoaded(exercises: [
        Exercise(
            id: 1,
            name: 'Push Up',
            description: 'An upper body exercise',
            imagePath: '/images/push_up.png'),
      ]),
      act: (bloc) => bloc.add(const UpdateExerciseEvent(
        id: tExerciseId,
        name: 'Updated Push Up',
        description: 'An updated upper body exercise',
        imagePath: '/images/updated_push_up.png',
      )),
      expect: () => [],
      verify: (_) {
        verify(() => mockUpdateExercise(updateParams)).called(1);
        verify(() => mockMessageBloc.add(const AddMessageEvent(
              message: databaseFailureMessage,
              isError: true,
            ))).called(1);
      },
    );
  });

  group('DeleteExerciseEvent', () {
    const tExerciseId = 1;
    final tExercise = Exercise(
      id: tExerciseId,
      name: 'Push Up',
      description: 'An upper body exercise',
      imagePath: '/images/push_up.png',
    );

    blocTest<ExerciseManagementBloc, ExerciseManagementState>(
      'emits updated ExerciseManagementLoaded without the deleted exercise and sends success message on successful deletion',
      build: () {
        when(() => mockDeleteExercise(const delete.Params(id: tExerciseId)))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      seed: () => ExerciseManagementLoaded(exercises: [tExercise]),
      act: (bloc) => bloc.add(const DeleteExerciseEvent(tExerciseId)),
      expect: () => [
        const ExerciseManagementLoaded(exercises: []),
      ],
      verify: (_) {
        verify(() => mockDeleteExercise(const delete.Params(id: tExerciseId)))
            .called(1);
        verify(() => mockMessageBloc.add(AddMessageEvent(
              message: 'Exercise ${tExercise.name} deleted successfully.',
              isError: false,
            ))).called(1);
      },
    );

    blocTest<ExerciseManagementBloc, ExerciseManagementState>(
      'does not emit new state and sends error message on deletion failure',
      build: () {
        when(() => mockDeleteExercise(const delete.Params(id: tExerciseId)))
            .thenAnswer((_) async => const Left(DatabaseFailure()));
        return bloc;
      },
      seed: () => ExerciseManagementLoaded(exercises: [tExercise]),
      act: (bloc) => bloc.add(const DeleteExerciseEvent(tExerciseId)),
      expect: () => [],
      verify: (_) {
        verify(() => mockDeleteExercise(const delete.Params(id: tExerciseId)))
            .called(1);
        verify(() => mockMessageBloc.add(const AddMessageEvent(
              message: databaseFailureMessage,
              isError: true,
            ))).called(1);
      },
    );
  });
}
