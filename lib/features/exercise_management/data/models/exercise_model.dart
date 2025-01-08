import '../../domain/entities/exercise.dart';

class ExerciseModel extends Exercise {
  const ExerciseModel({
    super.id,
    required super.name,
    super.imagePath,
    super.description,
    required super.exerciseType,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'],
      name: json['name'] as String? ?? 'No Name',
      imagePath: json['image_path'] as String? ?? '',
      description: json['description'] as String? ?? '',
      exerciseType: ExerciseType.values[json['exercise_type'] as int],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_path': imagePath,
      'description': description,
      'exercise_type': exerciseType.index,
    };
  }
}
