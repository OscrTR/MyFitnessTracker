import 'package:equatable/equatable.dart';

enum ExerciseType { yoga, workout }

class Exercise extends Equatable {
  final int? id;
  final String name;
  final String? imagePath;
  final String? description;
  final ExerciseType exerciseType;

  const Exercise({
    this.id,
    required this.name,
    this.imagePath,
    this.description,
    required this.exerciseType,
  });

  Exercise copyWith({
    int? id,
    String? name,
    String? imagePath,
    String? description,
    ExerciseType? exerciseType,
  }) {
    return Exercise(
        id: id ?? this.id,
        name: name ?? this.name,
        imagePath: imagePath ?? this.imagePath,
        description: description ?? this.description,
        exerciseType: exerciseType ?? this.exerciseType);
  }

  @override
  List<Object?> get props => [id, name, imagePath, description, exerciseType];
}
