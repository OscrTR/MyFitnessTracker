import '../../domain/entities/exercise.dart';

class ExerciseModel extends Exercise {
  const ExerciseModel(
      {super.id,
      required super.name,
      required super.imageName,
      required super.description});

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'],
      name: json['name'],
      imageName: json['image_name'],
      description: json['description'],
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
