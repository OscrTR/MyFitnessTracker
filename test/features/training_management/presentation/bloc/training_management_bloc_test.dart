import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_fitness_tracker/core/error/failures.dart';
import 'package:my_fitness_tracker/core/messages/bloc/message_bloc.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/multiset.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/training.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/training_exercise.dart';
import 'package:my_fitness_tracker/features/training_management/domain/usecases/create_training.dart'
    as create;
import 'package:my_fitness_tracker/features/training_management/domain/usecases/delete_training.dart'
    as delete;
import 'package:my_fitness_tracker/features/training_management/domain/usecases/fetch_trainings.dart'
    as fetch;
import 'package:my_fitness_tracker/features/training_management/domain/usecases/get_training.dart'
    as get_tr;
import 'package:my_fitness_tracker/features/training_management/domain/usecases/update_training.dart'
    as update;
import 'package:my_fitness_tracker/features/training_management/presentation/bloc/training_management_bloc.dart';
import 'package:dartz/dartz.dart';

class MockCreateTraining extends Mock implements create.CreateTraining {}

class FakeCreateParams extends Fake implements create.Params {}

class MockFetchTrainings extends Mock implements fetch.FetchTrainings {}

class MockGetTraining extends Mock implements get_tr.GetTraining {}

class FakeGetParams extends Fake implements get_tr.Params {}

class MockUpdateTraining extends Mock implements update.UpdateTraining {}

class FakeUpdateParams extends Fake implements update.Params {}

class MockDeleteTraining extends Mock implements delete.DeleteTraining {}

class FakeDeleteParams extends Fake implements delete.Params {}

class MockMessageBloc extends Mock implements MessageBloc {}

void main() {
  late MockCreateTraining mockCreateTraining;
  late MockFetchTrainings mockFetchTrainings;
  late MockGetTraining mockGetTraining;
  late MockUpdateTraining mockUpdateTraining;
  late MockDeleteTraining mockDeleteTraining;
  late MockMessageBloc mockMessageBloc;

  late TrainingManagementBloc bloc;

  setUpAll(() {
    registerFallbackValue(FakeCreateParams());
    registerFallbackValue(FakeGetParams());
    registerFallbackValue(FakeUpdateParams());
    registerFallbackValue(FakeDeleteParams());
  });

  setUp(() {
    mockCreateTraining = MockCreateTraining();
    mockFetchTrainings = MockFetchTrainings();
    mockGetTraining = MockGetTraining();
    mockUpdateTraining = MockUpdateTraining();
    mockDeleteTraining = MockDeleteTraining();
    mockMessageBloc = MockMessageBloc();

    bloc = TrainingManagementBloc(
      createTraining: mockCreateTraining,
      fetchTrainings: mockFetchTrainings,
      getTraining: mockGetTraining,
      updateTraining: mockUpdateTraining,
      deleteTraining: mockDeleteTraining,
      messageBloc: mockMessageBloc,
    );

    registerFallbackValue(const AddMessageEvent(message: '', isError: false));
  });

  tearDown(() {
    bloc.close();
  });

  group('FetchTrainingsEvent', () {
    final trainings = [
      const Training(
        id: 1,
        name: 'Training 1',
        type: TrainingType.yoga,
        isSelected: false,
        trainingExercises: [],
        multisets: [],
      ),
      const Training(
        id: 2,
        name: 'Training 2',
        type: TrainingType.run,
        isSelected: false,
        trainingExercises: [],
        multisets: [],
      ),
    ];

    blocTest<TrainingManagementBloc, TrainingManagementState>(
      'emits [TrainingManagementLoaded] when fetchTrainings succeeds',
      build: () {
        when(() => mockFetchTrainings(null))
            .thenAnswer((_) async => Right(trainings));
        return bloc;
      },
      act: (bloc) => bloc.add(FetchTrainingsEvent()),
      expect: () => [
        TrainingManagementLoaded(trainings: trainings),
      ],
    );

    blocTest<TrainingManagementBloc, TrainingManagementState>(
      'does not emit new state and calls MessageBloc when fetchTrainings fails',
      build: () {
        when(() => mockFetchTrainings(null))
            .thenAnswer((_) async => const Left(DatabaseFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(FetchTrainingsEvent()),
      verify: (_) {
        verify(() => mockMessageBloc.add(any())).called(1);
      },
    );
  });

  group('DeleteTrainingEvent', () {
    const trainingId = 1;
    const currentState = TrainingManagementLoaded(trainings: [
      Training(
        id: trainingId,
        name: 'Training 1',
        type: TrainingType.yoga,
        isSelected: false,
        trainingExercises: [],
        multisets: [],
      ),
    ]);

    blocTest<TrainingManagementBloc, TrainingManagementState>(
      'emits updated TrainingManagementLoaded when deleteTraining succeeds',
      build: () {
        when(() => mockDeleteTraining(const delete.Params(trainingId)))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      seed: () => currentState,
      act: (bloc) => bloc.add(const DeleteTrainingEvent(trainingId)),
      expect: () => [
        currentState.copyWith(
          trainings: [],
        ),
      ],
    );

    blocTest<TrainingManagementBloc, TrainingManagementState>(
      'does not emit new state when deleteTraining fails',
      build: () {
        when(() => mockDeleteTraining(const delete.Params(trainingId)))
            .thenAnswer((_) async => const Left(DatabaseFailure()));
        return bloc;
      },
      seed: () => currentState,
      act: (bloc) => bloc.add(const DeleteTrainingEvent(trainingId)),
      verify: (_) {
        verify(() => mockMessageBloc.add(any())).called(1);
      },
    );
  });

  group('SelectTrainingEvent', () {
    const trainingId = 1;
    const training = Training(
      id: trainingId,
      name: 'Training 1',
      type: TrainingType.yoga,
      isSelected: false,
      trainingExercises: [],
      multisets: [],
    );

    blocTest<TrainingManagementBloc, TrainingManagementState>(
      'emits updated state with selected training when getTraining succeeds',
      build: () {
        when(() => mockGetTraining(const get_tr.Params(trainingId)))
            .thenAnswer((_) async => const Right(training));
        return bloc;
      },
      seed: () => const TrainingManagementLoaded(trainings: [training]),
      act: (bloc) => bloc.add(const SelectTrainingEvent(id: trainingId)),
      expect: () => [
        const TrainingManagementLoaded(
          trainings: [training],
          selectedTraining: training,
        ),
      ],
    );
  });

  group('UnselectTrainingEvent', () {
    const trainingId = 1;
    const initialTraining = Training(
      id: trainingId,
      name: 'Training 1',
      type: TrainingType.yoga,
      isSelected: true,
      trainingExercises: [],
      multisets: [],
    );
    const updatedTraining = Training(
      id: trainingId,
      name: 'Training 1',
      type: TrainingType.yoga,
      isSelected: false,
      trainingExercises: [],
      multisets: [],
    );

    blocTest<TrainingManagementBloc, TrainingManagementState>(
      'updates selectedTraining.isSelected to false and emits updated state',
      build: () {
        when(() => mockGetTraining(const get_tr.Params(trainingId)))
            .thenAnswer((_) async {
          return const Right(initialTraining);
        });
        when(() => mockUpdateTraining(const update.Params(updatedTraining)))
            .thenAnswer((_) async {
          return const Right(null);
        });
        when(() => mockFetchTrainings(null)).thenAnswer((_) async {
          return Right([initialTraining.copyWith(isSelected: false)]);
        });
        return bloc;
      },
      seed: () => const TrainingManagementLoaded(
        trainings: [initialTraining],
        selectedTraining: null,
      ),
      act: (bloc) => bloc.add(const UnselectTrainingEvent(trainingId)),
      expect: () => [
        TrainingManagementLoaded(
          trainings: [initialTraining.copyWith(isSelected: false)],
          selectedTraining: null,
        ),
      ],
    );
  });
  group('LoadInitialSelectedTrainingData', () {
    blocTest<TrainingManagementBloc, TrainingManagementState>(
      'emits updated state with selected training on successful fetchTrainings',
      build: () {
        // Mock dependencies like fetchTrainings and messageBloc
        final mockFetchTrainings = MockFetchTrainings();
        when(() => mockFetchTrainings(null)).thenAnswer(
            (_) async => const Right(<Training>[])); // Simulate success

        return TrainingManagementBloc(
          fetchTrainings: mockFetchTrainings,
          messageBloc: MockMessageBloc(),
          createTraining: mockCreateTraining,
          getTraining: mockGetTraining,
          updateTraining: mockUpdateTraining,
          deleteTraining: mockDeleteTraining,
        );
      },
      seed: () => const TrainingManagementLoaded(
        selectedTraining: null,
        trainings: [],
      ),
      act: (bloc) => bloc.add(LoadInitialSelectedTrainingData()),
      expect: () => [
        const TrainingManagementLoaded(
          selectedTraining: Training(
            name: 'Unnamed training',
            type: TrainingType.workout,
            isSelected: true,
            trainingExercises: [],
            multisets: [],
          ),
          trainings: [],
        ),
      ],
    );
  });

  group('StartTrainingEvent', () {
    const trainingId = 1;
    const training = Training(
      id: trainingId,
      name: 'Test Training',
      isSelected: false,
      type: TrainingType.yoga,
      trainingExercises: [],
      multisets: [],
    );
    final updatedTraining = training.copyWith(isSelected: true);
    final trainings = [updatedTraining];

    blocTest<TrainingManagementBloc, TrainingManagementState>(
      'emits updated state on successful training selection',
      build: () {
        when(() => mockGetTraining(const get_tr.Params(trainingId)))
            .thenAnswer((_) async => const Right(training));
        when(() => mockUpdateTraining(update.Params(updatedTraining)))
            .thenAnswer((_) async => const Right(null));
        when(() => mockFetchTrainings(null))
            .thenAnswer((_) async => Right(trainings));

        return bloc;
      },
      seed: () =>
          const TrainingManagementLoaded(trainings: [], activeTraining: null),
      act: (bloc) => bloc.add(const StartTrainingEvent(trainingId)),
      expect: () => [
        TrainingManagementLoaded(
          trainings: trainings,
          activeTraining: updatedTraining,
        ),
      ],
      verify: (_) {
        verify(() => mockGetTraining(const get_tr.Params(trainingId)))
            .called(1);
        verify(() => mockUpdateTraining(any())).called(1);
        verify(() => mockFetchTrainings(any())).called(1);
        verifyNever(() => mockMessageBloc.add(any()));
      },
    );

    blocTest<TrainingManagementBloc, TrainingManagementState>(
      'adds error message on getTraining failure',
      setUp: () {
        when(() => mockGetTraining(const get_tr.Params(trainingId))).thenAnswer(
            (_) async => const Left(DatabaseFailure('GetTraining failed')));
      },
      build: () => TrainingManagementBloc(
        getTraining: mockGetTraining,
        updateTraining: mockUpdateTraining,
        fetchTrainings: mockFetchTrainings,
        messageBloc: mockMessageBloc,
        createTraining: mockCreateTraining,
        deleteTraining: mockDeleteTraining,
      ),
      seed: () => const TrainingManagementLoaded(
        trainings: [],
        // Other fields
      ),
      act: (bloc) => bloc.add(const StartTrainingEvent(trainingId)),
      expect: () => [],
      verify: (_) {
        verify(() => mockGetTraining(any())).called(1);
        verifyNever(() => mockUpdateTraining(any()));
        verifyNever(() => mockFetchTrainings(any()));
      },
    );
  });
  group('ClearSelectedTrainingEvent', () {
    const trainingId = 1;
    const training = Training(
      id: trainingId,
      name: 'Test Training',
      isSelected: false,
      type: TrainingType.yoga,
      trainingExercises: [],
      multisets: [],
    );

    blocTest<TrainingManagementBloc, TrainingManagementState>(
      'emits new state with selected training cleared when ClearSelectedTrainingEvent is added',
      build: () => TrainingManagementBloc(
        getTraining: mockGetTraining,
        updateTraining: mockUpdateTraining,
        fetchTrainings: mockFetchTrainings,
        messageBloc: mockMessageBloc,
        createTraining: mockCreateTraining,
        deleteTraining: mockDeleteTraining,
      ),
      seed: () => TrainingManagementLoaded(
        trainings: [
          training.copyWith(isSelected: true),
          training.copyWith(id: 2, name: 'Another Training'),
        ],
        selectedTraining: training.copyWith(isSelected: true),
      ),
      act: (bloc) => bloc.add(const ClearSelectedTrainingEvent()),
      expect: () => [
        TrainingManagementLoaded(
            trainings: [
              training.copyWith(isSelected: true),
              training.copyWith(id: 2, name: 'Another Training'),
            ],
            selectedTraining: const Training(
              name: 'Unnamed training',
              type: TrainingType.workout,
              isSelected: true,
              trainingExercises: [],
              multisets: [],
            )),
      ],
    );

    blocTest<TrainingManagementBloc, TrainingManagementState>(
      'does nothing if state is not TrainingManagementLoaded',
      build: () => TrainingManagementBloc(
        getTraining: mockGetTraining,
        updateTraining: mockUpdateTraining,
        fetchTrainings: mockFetchTrainings,
        messageBloc: mockMessageBloc,
        createTraining: mockCreateTraining,
        deleteTraining: mockDeleteTraining,
      ),
      seed: () => TrainingManagementInitial(),
      act: (bloc) => bloc.add(const ClearSelectedTrainingEvent()),
      expect: () => [],
    );
  });

  group('UpdateSelectedTrainingProperty', () {
    const trainingId = 1;
    const initialTraining = Training(
      id: trainingId,
      name: 'Initial Training',
      isSelected: true,
      type: TrainingType.yoga,
      trainingExercises: [],
      multisets: [],
    );

    const updatedName = 'Updated Training';

    blocTest<TrainingManagementBloc, TrainingManagementState>(
      'updates selected training properties and emits updated state',
      build: () => TrainingManagementBloc(
        getTraining: mockGetTraining,
        updateTraining: mockUpdateTraining,
        fetchTrainings: mockFetchTrainings,
        messageBloc: mockMessageBloc,
        createTraining: mockCreateTraining,
        deleteTraining: mockDeleteTraining,
      ),
      seed: () => TrainingManagementLoaded(
        trainings: [
          initialTraining,
          initialTraining.copyWith(id: 2, name: 'Another Training'),
        ],
        selectedTraining: initialTraining,
      ),
      act: (bloc) =>
          bloc.add(const UpdateSelectedTrainingProperty(name: updatedName)),
      expect: () => [
        TrainingManagementLoaded(
          trainings: [
            initialTraining,
            initialTraining.copyWith(id: 2, name: 'Another Training'),
          ],
          selectedTraining: initialTraining.copyWith(name: updatedName),
        ),
      ],
    );

    blocTest<TrainingManagementBloc, TrainingManagementState>(
      'does nothing if state is not TrainingManagementLoaded',
      build: () => TrainingManagementBloc(
        getTraining: mockGetTraining,
        updateTraining: mockUpdateTraining,
        fetchTrainings: mockFetchTrainings,
        messageBloc: mockMessageBloc,
        createTraining: mockCreateTraining,
        deleteTraining: mockDeleteTraining,
      ),
      seed: () => TrainingManagementInitial(),
      act: (bloc) =>
          bloc.add(const UpdateSelectedTrainingProperty(name: updatedName)),
      expect: () => [],
    );
  });

  group('TrainingManagementBloc - UpdateTrainingEvent', () {
    const trainingId = 1;
    const training = Training(
      id: trainingId,
      name: 'Test Training',
      isSelected: true,
      type: TrainingType.yoga,
      trainingExercises: [],
      multisets: [],
    );

    const defaultTraining = Training(
      name: 'Unnamed training',
      type: TrainingType.workout,
      isSelected: true,
      trainingExercises: [],
      multisets: [],
    );

    final updatedTrainings = [
      training.copyWith(name: 'Updated Training'),
      training.copyWith(id: 2, name: 'Another Training'),
    ];

    blocTest<TrainingManagementBloc, TrainingManagementState>(
      'emits updated state and sends success message when update succeeds',
      build: () => TrainingManagementBloc(
        getTraining: mockGetTraining,
        updateTraining: mockUpdateTraining,
        fetchTrainings: mockFetchTrainings,
        messageBloc: mockMessageBloc,
        createTraining: mockCreateTraining,
        deleteTraining: mockDeleteTraining,
      ),
      seed: () => const TrainingManagementLoaded(
        trainings: [training],
        selectedTraining: training,
      ),
      setUp: () {
        when(() => mockUpdateTraining(any()))
            .thenAnswer((_) async => const Right(null));
        when(() => mockFetchTrainings(any()))
            .thenAnswer((_) async => Right(updatedTrainings));
      },
      act: (bloc) => bloc.add(UpdateTrainingEvent()),
      expect: () => [
        TrainingManagementLoaded(
          trainings: updatedTrainings,
          selectedTraining: defaultTraining,
        ),
      ],
      verify: (_) {
        verify(() => mockUpdateTraining(any())).called(1);
        verify(() => mockFetchTrainings(any())).called(1);
        verify(() => mockMessageBloc.add(
              const AddMessageEvent(
                message: 'Training updated successfully.',
                isError: false,
              ),
            )).called(1);
      },
    );

    blocTest<TrainingManagementBloc, TrainingManagementState>(
      'sends error message when update fails',
      build: () => TrainingManagementBloc(
        getTraining: mockGetTraining,
        updateTraining: mockUpdateTraining,
        fetchTrainings: mockFetchTrainings,
        messageBloc: mockMessageBloc,
        createTraining: mockCreateTraining,
        deleteTraining: mockDeleteTraining,
      ),
      seed: () => const TrainingManagementLoaded(
        trainings: [training],
        selectedTraining: training,
      ),
      setUp: () {
        when(() => mockUpdateTraining(any())).thenAnswer(
            (_) async => const Left(DatabaseFailure('Update failed')));
      },
      act: (bloc) => bloc.add(UpdateTrainingEvent()),
      expect: () => [],
      verify: (_) {
        verify(() => mockUpdateTraining(any())).called(1);
        verifyNever(() => mockFetchTrainings(any()));
      },
    );

    blocTest<TrainingManagementBloc, TrainingManagementState>(
      'sends error message when fetch fails after successful update',
      build: () => TrainingManagementBloc(
        getTraining: mockGetTraining,
        updateTraining: mockUpdateTraining,
        fetchTrainings: mockFetchTrainings,
        messageBloc: mockMessageBloc,
        createTraining: mockCreateTraining,
        deleteTraining: mockDeleteTraining,
      ),
      seed: () => const TrainingManagementLoaded(
        trainings: [training],
        selectedTraining: training,
      ),
      setUp: () {
        when(() => mockUpdateTraining(any()))
            .thenAnswer((_) async => const Right(null));
        when(() => mockFetchTrainings(any())).thenAnswer(
            (_) async => const Left(DatabaseFailure('Fetch failed')));
      },
      act: (bloc) => bloc.add(UpdateTrainingEvent()),
      expect: () => [],
      verify: (_) {
        verify(() => mockUpdateTraining(any())).called(1);
        verify(() => mockFetchTrainings(any())).called(1);
      },
    );
  });

  group('AddExerciseToSelectedTrainingEvent', () {
    const trainingId = 1;
    const trainingExercise = TrainingExercise(
      id: 100,
      trainingId: trainingId,
      exerciseId: 200,
      sets: 3,
      duration: 60,
      trainingExerciseType: TrainingExerciseType.workout,
    );

    const training = Training(
      id: trainingId,
      name: 'Test Training',
      isSelected: true,
      type: TrainingType.yoga,
      trainingExercises: [],
      multisets: [],
    );

    blocTest<TrainingManagementBloc, TrainingManagementState>(
      'adds a training exercise to selected training and emits updated state',
      build: () => TrainingManagementBloc(
        getTraining: mockGetTraining,
        updateTraining: mockUpdateTraining,
        fetchTrainings: mockFetchTrainings,
        messageBloc: mockMessageBloc,
        createTraining: mockCreateTraining,
        deleteTraining: mockDeleteTraining,
      ),
      seed: () => const TrainingManagementLoaded(
        trainings: [training],
        selectedTraining: training,
      ),
      act: (bloc) =>
          bloc.add(const AddExerciseToSelectedTrainingEvent(trainingExercise)),
      expect: () => [
        TrainingManagementLoaded(
          trainings: const [training],
          selectedTraining: training.copyWith(
            trainingExercises: [trainingExercise],
          ),
        ),
      ],
    );

    blocTest<TrainingManagementBloc, TrainingManagementState>(
      'does nothing if state is not TrainingManagementLoaded',
      build: () => TrainingManagementBloc(
        getTraining: mockGetTraining,
        updateTraining: mockUpdateTraining,
        fetchTrainings: mockFetchTrainings,
        messageBloc: mockMessageBloc,
        createTraining: mockCreateTraining,
        deleteTraining: mockDeleteTraining,
      ),
      seed: () => TrainingManagementInitial(),
      act: (bloc) =>
          bloc.add(const AddExerciseToSelectedTrainingEvent(trainingExercise)),
      expect: () => [],
    );
  });

  group('RemoveExerciseFromSelectedTrainingEvent', () {
    const trainingId = 1;

    const trainingExercise1 = TrainingExercise(
      id: 101,
      trainingId: trainingId,
      exerciseId: 201,
      key: 'exercise-1',
      position: 0,
      sets: 3,
      duration: 60,
      trainingExerciseType: TrainingExerciseType.workout,
    );

    const trainingExercise2 = TrainingExercise(
      id: 102,
      trainingId: trainingId,
      exerciseId: 202,
      key: 'exercise-2',
      position: 1,
      sets: 4,
      duration: 45,
      trainingExerciseType: TrainingExerciseType.workout,
    );

    const multiset = Multiset(
      id: 1,
      trainingId: trainingId,
      key: 'multiset-1',
      sets: 1,
      trainingExercises: [trainingExercise1],
      position: 2,
      setRest: null,
      multisetRest: null,
      specialInstructions: '',
      objectives: '',
    );

    const training = Training(
      id: trainingId,
      name: 'Test Training',
      isSelected: true,
      type: TrainingType.yoga,
      trainingExercises: [trainingExercise1, trainingExercise2],
      multisets: [multiset],
    );

    blocTest<TrainingManagementBloc, TrainingManagementState>(
      'RemoveExerciseFromSelectedTrainingEvent removes the exercise and recalculates positions',
      build: () => TrainingManagementBloc(
        getTraining: mockGetTraining,
        updateTraining: mockUpdateTraining,
        fetchTrainings: mockFetchTrainings,
        messageBloc: mockMessageBloc,
        createTraining: mockCreateTraining,
        deleteTraining: mockDeleteTraining,
      ),
      seed: () => const TrainingManagementLoaded(
        trainings: [training],
        selectedTraining: training,
      ),
      act: (bloc) => bloc.add(const RemoveExerciseFromSelectedTrainingEvent(
        'exercise-1',
      )),
      expect: () => [
        TrainingManagementLoaded(
          trainings: const [training],
          selectedTraining: training.copyWith(
            trainingExercises: [
              trainingExercise2.copyWith(position: 0),
            ],
            multisets: [
              multiset.copyWith(position: 1),
            ],
          ),
        ),
      ],
    );

    blocTest<TrainingManagementBloc, TrainingManagementState>(
      'AddExerciseToSelectedTrainingMultisetEvent adds an exercise to the specified multiset',
      build: () => TrainingManagementBloc(
        getTraining: mockGetTraining,
        updateTraining: mockUpdateTraining,
        fetchTrainings: mockFetchTrainings,
        messageBloc: mockMessageBloc,
        createTraining: mockCreateTraining,
        deleteTraining: mockDeleteTraining,
      ),
      seed: () => const TrainingManagementLoaded(
        trainings: [training],
        selectedTraining: training,
      ),
      act: (bloc) => bloc.add(const AddExerciseToSelectedTrainingMultisetEvent(
        'multiset-1',
        trainingExercise2,
      )),
      expect: () => [
        TrainingManagementLoaded(
          trainings: const [training],
          selectedTraining: training.copyWith(
            multisets: [
              multiset.copyWith(
                trainingExercises: [
                  trainingExercise1,
                  trainingExercise2,
                ],
              ),
            ],
          ),
        ),
      ],
    );
  });

  group('RemoveExerciseFromSelectedTrainingMultisetEvent', () {
    late MockMessageBloc mockMessageBloc;

    setUp(() {
      mockMessageBloc = MockMessageBloc();
    });

    const trainingId = 1;
    const multisetKey = 'multiset-1';
    const exerciseKeyToRemove = 'exercise-1';

    const trainingExercise1 = TrainingExercise(
      id: 101,
      trainingId: trainingId,
      exerciseId: 201,
      key: exerciseKeyToRemove,
      position: 0,
      sets: 3,
      duration: 60,
      trainingExerciseType: TrainingExerciseType.workout,
    );

    const trainingExercise2 = TrainingExercise(
      id: 102,
      trainingId: trainingId,
      exerciseId: 202,
      key: 'exercise-2',
      position: 1,
      sets: 4,
      duration: 45,
      trainingExerciseType: TrainingExerciseType.workout,
    );

    const multiset = Multiset(
      id: 1,
      trainingId: trainingId,
      key: multisetKey,
      trainingExercises: [trainingExercise1, trainingExercise2],
      position: 0,
      sets: null,
      setRest: null,
      multisetRest: null,
      specialInstructions: '',
      objectives: '',
    );

    const training = Training(
      id: trainingId,
      name: 'Test Training',
      isSelected: true,
      type: TrainingType.yoga,
      trainingExercises: [],
      multisets: [multiset],
    );

    blocTest<TrainingManagementBloc, TrainingManagementState>(
      'removes an exercise from the specified multiset and recalculates positions',
      build: () => TrainingManagementBloc(
        getTraining: mockGetTraining,
        updateTraining: mockUpdateTraining,
        fetchTrainings: mockFetchTrainings,
        messageBloc: mockMessageBloc,
        createTraining: mockCreateTraining,
        deleteTraining: mockDeleteTraining,
      ),
      seed: () => const TrainingManagementLoaded(
        trainings: [training],
        selectedTraining: training,
      ),
      act: (bloc) =>
          bloc.add(const RemoveExerciseFromSelectedTrainingMultisetEvent(
        multisetKey,
        exerciseKeyToRemove,
      )),
      expect: () => [
        TrainingManagementLoaded(
          trainings: const [training],
          selectedTraining: training.copyWith(
            multisets: [
              multiset.copyWith(
                trainingExercises: [
                  trainingExercise2.copyWith(position: 0),
                ],
              ),
            ],
          ),
        ),
      ],
    );

    blocTest<TrainingManagementBloc, TrainingManagementState>(
      'sends an error message if the specified multiset does not exist',
      build: () => TrainingManagementBloc(
        getTraining: mockGetTraining,
        updateTraining: mockUpdateTraining,
        fetchTrainings: mockFetchTrainings,
        messageBloc: mockMessageBloc,
        createTraining: mockCreateTraining,
        deleteTraining: mockDeleteTraining,
      ),
      seed: () => const TrainingManagementLoaded(
        trainings: [training],
        selectedTraining: training,
      ),
      act: (bloc) =>
          bloc.add(const RemoveExerciseFromSelectedTrainingMultisetEvent(
        'nonexistent-key',
        exerciseKeyToRemove,
      )),
      expect: () => [],
      verify: (_) {
        verify(() => mockMessageBloc.add(
              const AddMessageEvent(
                message: 'Multiset with key nonexistent-key not found.',
                isError: true,
              ),
            )).called(1);
      },
    );
  });

  group('AddMultisetToSelectedTrainingEvent', () {
    const trainingId = 1;

    const initialMultiset = Multiset(
      id: 1,
      trainingId: trainingId,
      key: 'multiset-1',
      trainingExercises: [],
      position: 0,
      sets: null,
      setRest: null,
      multisetRest: null,
      specialInstructions: '',
      objectives: '',
    );
    const newMultiset = Multiset(
      id: 2,
      trainingId: trainingId,
      key: 'multiset-2',
      trainingExercises: [],
      position: 0,
      sets: null,
      setRest: null,
      multisetRest: null,
      specialInstructions: '',
      objectives: '',
    );

    const training = Training(
      id: trainingId,
      name: 'Test Training',
      isSelected: true,
      type: TrainingType.yoga,
      trainingExercises: [],
      multisets: [initialMultiset],
    );

    blocTest<TrainingManagementBloc, TrainingManagementState>(
      'adds a new multiset to the selected training and emits updated state',
      build: () => TrainingManagementBloc(
        getTraining: mockGetTraining,
        updateTraining: mockUpdateTraining,
        fetchTrainings: mockFetchTrainings,
        messageBloc: mockMessageBloc,
        createTraining: mockCreateTraining,
        deleteTraining: mockDeleteTraining,
      ),
      seed: () => const TrainingManagementLoaded(
        trainings: [training],
        selectedTraining: training,
      ),
      act: (bloc) =>
          bloc.add(const AddMultisetToSelectedTrainingEvent(newMultiset)),
      expect: () => [
        TrainingManagementLoaded(
          trainings: const [training],
          selectedTraining: training.copyWith(
            multisets: [initialMultiset, newMultiset],
          ),
        ),
      ],
    );

    blocTest<TrainingManagementBloc, TrainingManagementState>(
      'does nothing if state is not TrainingManagementLoaded',
      build: () => TrainingManagementBloc(
        getTraining: mockGetTraining,
        updateTraining: mockUpdateTraining,
        fetchTrainings: mockFetchTrainings,
        messageBloc: mockMessageBloc,
        createTraining: mockCreateTraining,
        deleteTraining: mockDeleteTraining,
      ),
      seed: () => TrainingManagementInitial(),
      act: (bloc) =>
          bloc.add(const AddMultisetToSelectedTrainingEvent(newMultiset)),
      expect: () => [],
    );
  });

  group('SaveSelectedTrainingEvent', () {
    const trainingId = 1;
    const training = Training(
      id: trainingId,
      name: 'Test Training',
      isSelected: true,
      type: TrainingType.yoga,
      trainingExercises: [],
      multisets: [],
    );

    final updatedTrainings = [
      training.copyWith(name: 'Updated Training'),
      training.copyWith(id: 2, name: 'Another Training'),
    ];

    blocTest<TrainingManagementBloc, TrainingManagementState>(
      'sends an error message if no selected training exists',
      build: () => TrainingManagementBloc(
        getTraining: mockGetTraining,
        updateTraining: mockUpdateTraining,
        fetchTrainings: mockFetchTrainings,
        messageBloc: mockMessageBloc,
        createTraining: mockCreateTraining,
        deleteTraining: mockDeleteTraining,
      ),
      seed: () => const TrainingManagementLoaded(
        trainings: [training],
        selectedTraining: null,
      ),
      act: (bloc) => bloc.add(SaveSelectedTrainingEvent()),
      expect: () => [],
      verify: (_) {
        verify(() => mockMessageBloc.add(
              const AddMessageEvent(
                message: 'No training selected to save.',
                isError: true,
              ),
            )).called(1);
      },
    );

    blocTest<TrainingManagementBloc, TrainingManagementState>(
      'creates training and updates state when successful',
      build: () => TrainingManagementBloc(
        getTraining: mockGetTraining,
        updateTraining: mockUpdateTraining,
        fetchTrainings: mockFetchTrainings,
        messageBloc: mockMessageBloc,
        createTraining: mockCreateTraining,
        deleteTraining: mockDeleteTraining,
      ),
      seed: () => const TrainingManagementLoaded(
        trainings: [training],
        selectedTraining: training,
      ),
      setUp: () {
        when(() => mockCreateTraining(any()))
            .thenAnswer((_) async => const Right(null));
        when(() => mockFetchTrainings(any()))
            .thenAnswer((_) async => Right(updatedTrainings));
      },
      act: (bloc) => bloc.add(SaveSelectedTrainingEvent()),
      expect: () => [
        TrainingManagementLoaded(
          trainings: updatedTrainings,
          selectedTraining: const Training(
            name: 'Unnamed training',
            type: TrainingType.workout,
            isSelected: true,
            trainingExercises: [],
            multisets: [],
          ),
        ),
      ],
      verify: (_) {
        verify(() => mockCreateTraining(any())).called(1);
        verify(() => mockFetchTrainings(any())).called(1);
        verify(() => mockMessageBloc.add(
              const AddMessageEvent(
                message: 'Training created successfully.',
                isError: false,
              ),
            )).called(1);
      },
    );

    blocTest<TrainingManagementBloc, TrainingManagementState>(
      'sends error message if createTraining fails',
      build: () => TrainingManagementBloc(
        getTraining: mockGetTraining,
        updateTraining: mockUpdateTraining,
        fetchTrainings: mockFetchTrainings,
        messageBloc: mockMessageBloc,
        createTraining: mockCreateTraining,
        deleteTraining: mockDeleteTraining,
      ),
      seed: () => const TrainingManagementLoaded(
        trainings: [training],
        selectedTraining: training,
      ),
      setUp: () {
        when(() => mockCreateTraining(any())).thenAnswer(
            (_) async => const Left(DatabaseFailure('Create training failed')));
      },
      act: (bloc) => bloc.add(SaveSelectedTrainingEvent()),
      expect: () => [],
      verify: (_) {
        verify(() => mockCreateTraining(any())).called(1);
        verifyNever(() => mockFetchTrainings(any()));
      },
    );

    blocTest<TrainingManagementBloc, TrainingManagementState>(
      'sends error message if fetchTrainings fails after successful creation',
      build: () => TrainingManagementBloc(
        getTraining: mockGetTraining,
        updateTraining: mockUpdateTraining,
        fetchTrainings: mockFetchTrainings,
        messageBloc: mockMessageBloc,
        createTraining: mockCreateTraining,
        deleteTraining: mockDeleteTraining,
      ),
      seed: () => const TrainingManagementLoaded(
        trainings: [training],
        selectedTraining: training,
      ),
      setUp: () {
        when(() => mockCreateTraining(any()))
            .thenAnswer((_) async => const Right(null));
        when(() => mockFetchTrainings(any())).thenAnswer(
            (_) async => const Left(DatabaseFailure('Fetch trainings failed')));
      },
      act: (bloc) => bloc.add(SaveSelectedTrainingEvent()),
      expect: () => [],
      verify: (_) {
        verify(() => mockCreateTraining(any())).called(1);
        verify(() => mockFetchTrainings(any())).called(1);
      },
    );
  });
}
