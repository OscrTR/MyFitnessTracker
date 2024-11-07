import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_fitness_tracker/features/training_management/data/models/multiset_model.dart';
import 'package:my_fitness_tracker/features/training_management/data/models/training_exercise_model.dart';
import 'package:my_fitness_tracker/features/training_management/data/models/training_model.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/training.dart';
import 'package:my_fitness_tracker/features/training_management/domain/entities/training_exercise.dart';

import '../../../../fixtures/fixture_reader.dart';

void main() {
  group('TrainingModel', () {
    const trainingModel = TrainingModel(
      id: 1,
      name: 'Morning Routine',
      type: TrainingType.yoga,
      isSelected: true,
      trainingExercises: [
        TrainingExerciseModel(
          id: 1,
          trainingId: 1,
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
        )
      ],
      multisets: [
        MultisetModel(
          id: 1,
          trainingId: 1,
          trainingExercises: [
            TrainingExerciseModel(
              id: 1,
              trainingId: 1,
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
        )
      ],
    );

    test(
      'should be a sublass of Multiset entity',
      () async {
        // Assert
        expect(trainingModel, isA<Training>());
      },
    );
    test('fromJson should create a valid TrainingModel', () {
      final Map<String, dynamic> jsonMap =
          json.decode(fixture('training.json'))[0];
      // Act
      final result = TrainingModel.fromJson(jsonMap);

      expect(result, trainingModel);
    });

    test('toJson should convert TrainingModel to valid JSON', () {
      final result = trainingModel.toJson();
      const expectedMap = {
        "id": 1,
        "name": "Morning Routine",
        "type": 1,
        "is_selected": 1,
      };
      expect(result, expectedMap);
    });
  });
}