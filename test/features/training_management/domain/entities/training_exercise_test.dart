import 'package:flutter_test/flutter_test.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/training_exercise.dart';

void main() {
  group('TrainingExercise', () {
    const trainingExercise = TrainingExercise(
      id: 1,
      trainingId: 101,
      multisetId: 1,
      exerciseId: 202,
      trainingExerciseType: TrainingExerciseType.yoga,
      specialInstructions: 'Focus on breathing',
      objectives: 'Endurance',
      runExerciseTarget: RunExerciseTarget.distance,
      targetDistance: 5000,
      targetDuration: 1800,
      isTargetPaceSelected: false,
      targetPace: 80,
      intervals: 5,
      isIntervalInDistance: true,
      intervalDistance: 1000,
      intervalDuration: 300,
      intervalRest: 60,
      sets: 3,
      isSetsInReps: true,
      minReps: 8,
      maxReps: 12,
      actualReps: 15,
      duration: 600,
      setRest: 120,
      exerciseRest: 90,
      autoStart: true,
      position: 0,
      key: 'ijkl',
    );

    test('should support value equality', () {
      const otherExercise = TrainingExercise(
        id: 1,
        trainingId: 101,
        multisetId: 1,
        exerciseId: 202,
        trainingExerciseType: TrainingExerciseType.yoga,
        specialInstructions: 'Focus on breathing',
        objectives: 'Endurance',
        runExerciseTarget: RunExerciseTarget.distance,
        targetDistance: 5000,
        targetDuration: 1800,
        isTargetPaceSelected: false,
        targetPace: 80,
        intervals: 5,
        isIntervalInDistance: true,
        intervalDistance: 1000,
        intervalDuration: 300,
        intervalRest: 60,
        sets: 3,
        isSetsInReps: true,
        minReps: 8,
        maxReps: 12,
        actualReps: 15,
        duration: 600,
        setRest: 120,
        exerciseRest: 90,
        autoStart: true,
        position: 0,
        key: 'ijkl',
      );

      expect(trainingExercise, equals(otherExercise));
    });

    test('copyWith should create a modified copy', () {
      final modifiedExercise = trainingExercise.copyWith(
        sets: 4,
        duration: 800,
      );

      expect(modifiedExercise.sets, 4);
      expect(modifiedExercise.duration, 800);
      expect(modifiedExercise.trainingId, trainingExercise.trainingId);
    });

    test('copyWith with no arguments should return the same object', () {
      final copiedExercise = trainingExercise.copyWith();
      expect(copiedExercise, equals(trainingExercise));
    });

    test('copyWithExerciseIdNull should set exerciseId to null', () {
      final nullExerciseId = trainingExercise.copyWithExerciseIdNull();

      expect(nullExerciseId.exerciseId, isNull);
      expect(nullExerciseId.trainingId, trainingExercise.trainingId);
    });

    test('props should include all fields', () {
      expect(
        trainingExercise.props,
        [
          trainingExercise.id,
          trainingExercise.trainingId,
          trainingExercise.multisetId,
          trainingExercise.exerciseId,
          trainingExercise.trainingExerciseType,
          trainingExercise.specialInstructions,
          trainingExercise.objectives,
          trainingExercise.runExerciseTarget,
          trainingExercise.targetDistance,
          trainingExercise.targetDuration,
          trainingExercise.isTargetPaceSelected,
          trainingExercise.targetPace,
          trainingExercise.intervals,
          trainingExercise.isIntervalInDistance,
          trainingExercise.intervalDistance,
          trainingExercise.intervalDuration,
          trainingExercise.intervalRest,
          trainingExercise.sets,
          trainingExercise.isSetsInReps,
          trainingExercise.minReps,
          trainingExercise.maxReps,
          trainingExercise.actualReps,
          trainingExercise.duration,
          trainingExercise.setRest,
          trainingExercise.exerciseRest,
          trainingExercise.autoStart,
          trainingExercise.position,
          trainingExercise.key,
        ],
      );
    });

    test('should handle null optional fields without errors', () {
      const nullFieldExercise = TrainingExercise(
        id: 1,
        trainingId: 101,
        trainingExerciseType: TrainingExerciseType.run,
        sets: 3,
        duration: 600,
      );

      expect(nullFieldExercise.id, 1);
      expect(nullFieldExercise.trainingId, 101);
      expect(nullFieldExercise.trainingExerciseType, TrainingExerciseType.run);
      expect(nullFieldExercise.sets, 3);
      expect(nullFieldExercise.duration, 600);
      expect(nullFieldExercise.exerciseId, isNull);
    });
  });
}
