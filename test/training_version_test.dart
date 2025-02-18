import 'package:flutter_test/flutter_test.dart';
import 'package:my_fitness_tracker/core/enums/enums.dart';
import 'package:my_fitness_tracker/features/exercise_management/models/exercise.dart';
import 'package:my_fitness_tracker/features/training_history/data/models/training_version.dart';
import 'package:my_fitness_tracker/features/training_management/models/multiset.dart';
import 'package:my_fitness_tracker/features/training_management/models/training.dart';
import 'package:my_fitness_tracker/features/training_management/models/training_exercise.dart';

void main() {
  test(
      'TrainingVersion.fromTraining should copy TrainingExercises and Multisets with exercises',
      () {
    final exercise1 = Exercise('Squat');
    final exercise2 = Exercise('Bench Press');
    final trainingExercise1 = TrainingExercise.create(
      linkedTrainingId: 1,
      sets: 3,
      exercise: exercise1,
      linkedMultisetId: null,
      linkedExerciseId: null,
      type: null,
      runType: null,
      isSetsInReps: true,
      isAutoStart: false,
      intensity: 5,
      setRest: 60,
      maxReps: 10,
    );
    final trainingExercise2 = TrainingExercise.create(
      linkedTrainingId: 1,
      sets: 3,
      exercise: exercise2,
      linkedMultisetId: null,
      linkedExerciseId: null,
      type: null,
      runType: null,
      isSetsInReps: true,
      isAutoStart: false,
      intensity: 5,
      setRest: 60,
      maxReps: 10,
    );

    final multiset = Multiset.create(
      linkedTrainingId: 1,
      sets: 2,
      setRest: 120,
      multisetRest: 180,
      position: 1,
      trainingExercises: [trainingExercise1, trainingExercise2],
    );

    final training = Training.create(
      name: 'Full Body Workout',
      objectives: 'Strength and Endurance',
      trainingExercises: [trainingExercise1, trainingExercise2],
      multisets: [multiset],
      type: TrainingType.workout,
      trainingDays: [],
    );

    final trainingVersion = TrainingVersion.fromTraining(training);
    final matchingTraining = trainingVersion.toTraining();

    expect(matchingTraining?.trainingExercises.length, equals(2));
    expect(matchingTraining?.trainingExercises[0].exercise.target!.name,
        equals('Squat'));
    expect(matchingTraining?.trainingExercises[1].exercise.target!.name,
        equals('Bench Press'));
    expect(matchingTraining?.multisets.length, equals(1));
    expect(matchingTraining?.multisets[0].trainingExercises.length, equals(2));
    expect(
        matchingTraining
            ?.multisets[0].trainingExercises[0].exercise.target!.name,
        equals('Squat'));
    expect(
        matchingTraining
            ?.multisets[0].trainingExercises[1].exercise.target!.name,
        equals('Bench Press'));
  });
}
