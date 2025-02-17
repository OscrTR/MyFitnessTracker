import 'package:flutter_test/flutter_test.dart';
import 'package:my_fitness_tracker/features/exercise_management/models/exercise.dart';
import 'package:my_fitness_tracker/features/training_management/models/multiset.dart';
import 'package:my_fitness_tracker/features/training_management/models/training_exercise.dart';

void main() {
  test('Multiset copyWith should copy TrainingExercises with exercises', () {
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

    final originalMultiset = Multiset.create(
      linkedTrainingId: 1,
      sets: 2,
      setRest: 120,
      multisetRest: 180,
      position: 1,
      trainingExercises: [trainingExercise1, trainingExercise2],
    );

    final copiedMultiset = originalMultiset.copyWith();

    expect(copiedMultiset.trainingExercises.length, equals(2));
    expect(copiedMultiset.trainingExercises[0].exercise.target!.name,
        equals('Squat'));
    expect(copiedMultiset.trainingExercises[1].exercise.target!.name,
        equals('Bench Press'));
  });
}
