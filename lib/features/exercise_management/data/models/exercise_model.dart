import 'dart:convert';

import '../../domain/entities/exercise.dart';

class ExerciseModel extends Exercise {
  const ExerciseModel({
    super.id,
    required super.name,
    super.imagePath,
    super.description,
    required super.exerciseType,
    super.muscleGroups,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'],
      name: json['name'] as String? ?? 'No Name',
      imagePath: json['image_path'] as String? ?? '',
      description: json['description'] as String? ?? '',
      exerciseType: ExerciseType.values
          .firstWhere((el) => el.name == (json['exercise_type'] as String)),
      muscleGroups: (jsonDecode(json['muscle_groups']) as List)
          .map((i) => MuscleGroup.values[i])
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_path': imagePath,
      'description': description,
      'exercise_type': exerciseType.name,
      'muscle_groups': jsonEncode(muscleGroups?.map((e) => e.index).toList()),
    };
  }
}
