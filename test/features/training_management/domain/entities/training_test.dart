import 'package:flutter_test/flutter_test.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/training.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/multiset.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/training_exercise.dart';

void main() {
  group('Training', () {
    const trainingExercises = [
      TrainingExercise(
        id: 1,
        trainingId: 101,
        multisetId: 1,
        exerciseId: 202,
        trainingExerciseType: TrainingExerciseType.yoga,
        specialInstructions: 'Focus on breathing',
        objectives: 'Endurance',
        sets: 3,
        duration: 600,
      ),
    ];

    const multisets = [
      Multiset(
        id: 1,
        trainingId: 101,
        trainingExercises: trainingExercises,
        sets: 3,
        setRest: 120,
        multisetRest: 300,
        specialInstructions: 'Good form',
        objectives: 'Strength',
        position: 0,
      ),
    ];

    const training = Training(
      id: 101,
      name: 'Morning Yoga',
      type: TrainingType.yoga,
      isSelected: true,
      trainingExercises: trainingExercises,
      multisets: multisets,
    );

    test('should support value equality', () {
      const anotherTraining = Training(
        id: 101,
        name: 'Morning Yoga',
        type: TrainingType.yoga,
        isSelected: true,
        trainingExercises: trainingExercises,
        multisets: multisets,
      );

      expect(training, equals(anotherTraining));
    });

    test('copyWith should create a modified copy', () {
      final modifiedTraining = training.copyWith(
        name: 'Evening Yoga',
        isSelected: false,
      );

      expect(modifiedTraining.name, 'Evening Yoga');
      expect(modifiedTraining.isSelected, false);
      expect(modifiedTraining.type, training.type);
      expect(modifiedTraining.trainingExercises, training.trainingExercises);
      expect(modifiedTraining.multisets, training.multisets);
    });

    test('copyWith with no arguments should return the same object', () {
      final copiedTraining = training.copyWith();

      expect(copiedTraining, equals(training));
    });

    test('props should include all fields', () {
      expect(
        training.props,
        [
          training.id,
          training.name,
          training.type,
          training.isSelected,
          training.trainingExercises,
          training.multisets,
        ],
      );
    });

    test('should throw an error if required fields are null', () {
      expect(
        () => const Training(
          name: 'Morning Yoga',
          type: TrainingType.yoga,
          isSelected: true,
          trainingExercises: [],
          multisets: [],
        ),
        returnsNormally, // Ensures required fields are not null.
      );

      expect(
        () => const Training(
          name: '',
          type: TrainingType.yoga,
          isSelected: true,
          trainingExercises: [],
          multisets: [],
        ),
        returnsNormally, // Name can be empty.
      );

      expect(
        () => const Training(
          name: 'Morning Yoga',
          type: TrainingType.yoga,
          isSelected: true,
          trainingExercises: [],
          multisets: [],
          id: null, // Optional field.
        ),
        returnsNormally,
      );
    });

    test('should allow empty lists for trainingExercises and multisets', () {
      const emptyTraining = Training(
        id: 102,
        name: 'Empty Training',
        type: TrainingType.run,
        isSelected: false,
        trainingExercises: [],
        multisets: [],
      );

      expect(emptyTraining.trainingExercises, isEmpty);
      expect(emptyTraining.multisets, isEmpty);
    });
  });
}
