import '../../domain/entities/exercise.dart';

class ExerciseModel extends Exercise {
  ExerciseModel({
    super.id,
    required super.name,
    super.imageName,
    super.description,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'],
      name: json['name'] as String? ?? 'No Name',
      imageName: json['image_name'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_name': imageName,
      'description': description,
    };
  }
}
