import 'package:flutter_test/flutter_test.dart';
import 'package:my_fitness_tracker/features/exercise_management/models/exercise.dart';
import 'package:my_fitness_tracker/features/training_management/models/training_exercise.dart';

void main() {
  test('TrainingExercise copyWithExercise should copy the exercise', () {
    final originalExercise = Exercise('Squat');
    final originalTrainingExercise = TrainingExercise.create(
      linkedTrainingId: 1,
      sets: 3,
      exercise: originalExercise,
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

    final copiedTrainingExercise = originalTrainingExercise.copyWith();

    expect(copiedTrainingExercise.exercise.target!.name, equals('Squat'));
    expect(copiedTrainingExercise.sets, equals(3));
    expect(copiedTrainingExercise.maxReps, equals(10));
    expect(copiedTrainingExercise.setRest, equals(60));
  });
}
