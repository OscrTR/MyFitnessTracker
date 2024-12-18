import 'package:flutter_test/flutter_test.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/multiset.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/training_exercise.dart';

void main() {
  group('Multiset', () {
    const trainingExercises = [
      TrainingExercise(
        id: 1,
        trainingId: 101,
        multisetId: 1,
        exerciseId: 202,
        trainingExerciseType: TrainingExerciseType.yoga,
        specialInstructions: 'Focus on breathing',
        objectives: 'Endurance',
        targetDistance: 5000,
        targetDuration: 1800,
        sets: 3,
        setRest: 120,
        exerciseRest: 90,
        autoStart: true,
      ),
    ];

    const multiset = Multiset(
      id: 1,
      trainingId: 101,
      trainingExercises: trainingExercises,
      sets: 3,
      setRest: 120,
      multisetRest: 300,
      specialInstructions: 'Complete with good form',
      objectives: 'Overall strength',
      position: 0,
      key: 'efgh',
    );

    test('should support value equality', () {
      const otherMultiset = Multiset(
        id: 1,
        trainingId: 101,
        trainingExercises: trainingExercises,
        sets: 3,
        setRest: 120,
        multisetRest: 300,
        specialInstructions: 'Complete with good form',
        objectives: 'Overall strength',
        position: 0,
        key: 'efgh',
      );

      expect(multiset, equals(otherMultiset));
    });

    test('copyWith should return a modified copy of the Multiset', () {
      final modifiedMultiset = multiset.copyWith(
        sets: 5,
        setRest: 150,
      );

      expect(modifiedMultiset.sets, 5);
      expect(modifiedMultiset.setRest, 150);
      expect(modifiedMultiset.trainingId, multiset.trainingId);
      expect(modifiedMultiset.trainingExercises, multiset.trainingExercises);
    });

    test('props should include all fields', () {
      expect(
        multiset.props,
        [
          multiset.id,
          multiset.trainingId,
          multiset.trainingExercises,
          multiset.sets,
          multiset.setRest,
          multiset.multisetRest,
          multiset.specialInstructions,
          multiset.objectives,
          multiset.position,
        ],
      );
    });

    test('copyWith with no parameters should return the same object', () {
      final copiedMultiset = multiset.copyWith();
      expect(copiedMultiset, equals(multiset));
    });
  });
}
