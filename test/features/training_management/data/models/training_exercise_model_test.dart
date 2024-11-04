import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_fitness_tracker/features/training_management/data/models/training_exercise_model.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/training_exercise.dart';

import '../../../../fixtures/fixture_reader.dart';

void main() {
  const trainingExercise = TrainingExerciseModel(
    id: 1,
    trainingId: 101,
    multisetId: 10,
    exerciseId: 202,
    trainingExerciseType: TrainingExerciseType.yoga,
    specialInstructions: 'Focus on breathing',
    objectives: 'Endurance',
    targetDistance: 5000,
    targetDuration: 1800,
    targetRythm: 80,
    intervals: 5,
    intervalDistance: 1000,
    intervalDuration: 300,
    intervalRest: 60,
    sets: 3,
    reps: 15,
    duration: 600,
    setRest: 120,
    exerciseRest: 90,
    manualStart: true,
  );

  test(
    'should be a sublass of Exercise entity',
    () async {
      // Assert
      expect(trainingExercise, isA<TrainingExercise>());
    },
  );

  group('fromJson', () {
    test(
      'should return a valid model',
      () async {
        // Arrange
        final Map<String, dynamic> jsonMap =
            json.decode(fixture('training_exercise.json'))[0];
        // Act
        final result = TrainingExerciseModel.fromJson(jsonMap);
        // Assert
        expect(result, trainingExercise);
      },
    );
  });

  group('toJson', () {
    test(
      'should return a JSON map containing the proper data',
      () async {
        // Act
        final result = trainingExercise.toJson();
        // Assert
        const expectedMap = {
          "id": 1,
          "trainingId": 101,
          "multisetId": 10,
          "exerciseId": 202,
          "trainingExerciseType": 1,
          "specialInstructions": "Focus on breathing",
          "objectives": "Endurance",
          "targetDistance": 5000,
          "targetDuration": 1800,
          "targetRythm": 80,
          "intervals": 5,
          "intervalDistance": 1000,
          "intervalDuration": 300,
          "intervalRest": 60,
          "sets": 3,
          "reps": 15,
          "duration": 600,
          "setRest": 120,
          "exerciseRest": 90,
          "manualStart": true
        };
        expect(result, expectedMap);
      },
    );
  });
}
