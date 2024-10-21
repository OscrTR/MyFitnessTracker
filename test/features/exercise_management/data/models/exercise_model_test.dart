import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_fitness_tracker/features/exercise_management/data/models/exercise_model.dart';
import 'package:my_fitness_tracker/features/exercise_management/domain/entities/exercise.dart';

import '../../../../fixtures/fixture_reader.dart';

void main() {
  const tExerciseModel = ExerciseModel(
      id: 1,
      name: 'Test name',
      imageName: 'Test image name',
      description: 'Test description');

  test(
    'should be a sublass of Exercise entity',
    () async {
      // Assert
      expect(tExerciseModel, isA<Exercise>());
    },
  );

  group('fromJson', () {
    test(
      'should return a valid model',
      () async {
        // Arrange
        final Map<String, dynamic> jsonMap =
            json.decode(fixture('exercise.json'))[0];
        // Act
        final result = ExerciseModel.fromJson(jsonMap);
        // Assert
        expect(result, tExerciseModel);
      },
    );
  });

  group('toJson', () {
    test(
      'should return a JSON map containing the proper data',
      () async {
        // Act
        final result = tExerciseModel.toJson();
        // Assert
        const expectedMap = {
          "id": 1,
          "name": "Test name",
          "image_name": "Test image name",
          "description": "Test description"
        };
        expect(result, expectedMap);
      },
    );
  });
}
