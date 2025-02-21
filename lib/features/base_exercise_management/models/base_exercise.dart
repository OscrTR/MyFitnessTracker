import 'package:equatable/equatable.dart';

import '../../../core/enums/enums.dart';

class BaseExercise extends Equatable {
  final int? id;
  final String name;
  final String imagePath;
  final String description;
  final List<MuscleGroup> muscleGroups;

  const BaseExercise({
    this.id,
    required this.name,
    required this.imagePath,
    required this.description,
    required this.muscleGroups,
  });

  @override
  List<Object?> get props {
    return [
      id,
      name,
      imagePath,
      description,
      muscleGroups,
    ];
  }

  BaseExercise copyWith({
    int? id,
    String? name,
    String? imagePath,
    String? description,
    List<MuscleGroup>? muscleGroups,
  }) {
    return BaseExercise(
      id: id ?? this.id,
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
      description: description ?? this.description,
      muscleGroups: muscleGroups ?? this.muscleGroups,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'imagePath': imagePath,
      'description': description,
      'muscleGroups': MuscleGroup.listToMap(muscleGroups),
    };
  }

  factory BaseExercise.fromMap(Map<String, dynamic> map) {
    return BaseExercise(
      id: map['id'] != null ? map['id'] as int : null,
      name: map['name'] as String,
      imagePath: map['imagePath'] as String,
      description: map['description'] as String,
      muscleGroups: MuscleGroup.listFromMap(map['muscleGroups']),
    );
  }
}
