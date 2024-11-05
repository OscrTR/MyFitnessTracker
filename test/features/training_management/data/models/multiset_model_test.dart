import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';
import 'package:my_fitness_tracker/features/training_management/data/models/training_exercise_model.dart';
import 'package:my_fitness_tracker/features/training_management/data/models/multiset_model.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/multiset.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/training_exercise.dart';

import '../../../../fixtures/fixture_reader.dart';

void main() {
  group('MultisetModel', () {
    const multisetModel = MultisetModel(
      id: 1,
      trainingId: 101,
      trainingExercises: [
        TrainingExerciseModel(
          id: 1,
          trainingId: 101,
          multisetId: 1,
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
        ),
      ],
      sets: 3,
      setRest: 120,
      multisetRest: 300,
      specialInstructions: 'Complete with good form',
      objectives: 'Overall strength',
    );

    test(
      'should be a sublass of Multiset entity',
      () async {
        // Assert
        expect(multisetModel, isA<Multiset>());
      },
    );

    test('fromJson should create a valid MultisetModel', () {
      final Map<String, dynamic> jsonMap =
          json.decode(fixture('multiset.json'))[0];
      // Act
      final result = MultisetModel.fromJson(jsonMap);

      expect(result, multisetModel);
    });

    test('toJson should convert MultisetModel to valid JSON', () {
      final result = multisetModel.toJson();
      const expectedMap = {
        "id": 1,
        "training_id": 101,
        "sets": 3,
        "set_rest": 120,
        "multiset_rest": 300,
        "special_instructions": "Complete with good form",
        "objectives": "Overall strength",
        "training_exercises": [
          {
            "id": 1,
            "training_id": 101,
            "multiset_id": 1,
            "exercise_id": 202,
            "training_exercise_type": 1,
            "special_instructions": "Focus on breathing",
            "objectives": "Endurance",
            "target_distance": 5000,
            "target_duration": 1800,
            "target_rythm": 80,
            "intervals": 5,
            "interval_distance": 1000,
            "interval_duration": 300,
            "interval_rest": 60,
            "sets": 3,
            "reps": 15,
            "duration": 600,
            "set_rest": 120,
            "exercise_rest": 90,
            "manual_start": true
          }
        ]
      };
      expect(result, expectedMap);
    });
  });
}
