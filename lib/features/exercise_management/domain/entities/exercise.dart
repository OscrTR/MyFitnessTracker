import 'package:equatable/equatable.dart';

class Exercise extends Equatable {
  final int? id;
  final String name;
  final String? imagePath;
  final String? description;
  final ExerciseType exerciseType;
  final int intensity;
  final List<MuscleGroup>? muscleGroups;

  const Exercise({
    this.id,
    required this.name,
    this.imagePath,
    this.description,
    required this.exerciseType,
    required this.intensity,
    this.muscleGroups,
  });

  Exercise copyWith({
    int? id,
    String? name,
    String? imagePath,
    String? description,
    ExerciseType? exerciseType,
    int? intensity,
    List<MuscleGroup>? muscleGroups,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
      description: description ?? this.description,
      exerciseType: exerciseType ?? this.exerciseType,
      intensity: intensity ?? this.intensity,
      muscleGroups: muscleGroups ?? this.muscleGroups,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        imagePath,
        description,
        exerciseType,
        intensity,
        muscleGroups,
      ];
}

enum ExerciseType {
  yoga,
  meditation,
  stretching,
  cardio,
  workout;

  String translate(String locale) {
    switch (this) {
      case ExerciseType.yoga:
        return locale == 'fr' ? 'Yoga' : 'Yoga';
      case ExerciseType.workout:
        return locale == 'fr' ? 'Renforcement' : 'Workout';
      case ExerciseType.meditation:
        return locale == 'fr' ? 'Méditation' : 'Meditation';
      case ExerciseType.stretching:
        return locale == 'fr' ? 'Étirement' : 'Stretching';
      case ExerciseType.cardio:
        return locale == 'fr' ? 'Cardio' : 'Cardio';
    }
  }
}

enum MuscleGroup {
  chest,
  back,
  shoulders,
  biceps,
  triceps,
  quads,
  hamstrings,
  calves,
  abs,
  forearms,
  traps,
  lats,
  glutes,
  obliques,
  neck,
  hipFlexors;

  String translate(String locale) {
    switch (this) {
      case MuscleGroup.chest:
        return locale == 'fr' ? 'Pectoraux' : 'Chest';

      case MuscleGroup.back:
        return locale == 'fr' ? 'Dos' : 'Back';

      case MuscleGroup.shoulders:
        return locale == 'fr' ? 'Épaules' : 'Shoulders';

      case MuscleGroup.biceps:
        return locale == 'fr' ? 'Biceps' : 'Biceps';

      case MuscleGroup.triceps:
        return locale == 'fr' ? 'Triceps' : 'Triceps';

      case MuscleGroup.quads:
        return locale == 'fr' ? 'Quadriceps' : 'Quadriceps';

      case MuscleGroup.hamstrings:
        return locale == 'fr' ? 'Ischio-jambiers' : 'Hamstrings';

      case MuscleGroup.calves:
        return locale == 'fr' ? 'Mollets' : 'Calves';

      case MuscleGroup.abs:
        return locale == 'fr' ? 'Abdominaux' : 'Abdominals';

      case MuscleGroup.forearms:
        return locale == 'fr' ? 'Avant-bras' : 'Forearms';

      case MuscleGroup.traps:
        return locale == 'fr' ? 'Trapèzes' : 'Trapezius';

      case MuscleGroup.lats:
        return locale == 'fr' ? 'Grand dorsal' : 'Latissimus dorsi';

      case MuscleGroup.glutes:
        return locale == 'fr' ? 'Fessiers' : 'Glutes';

      case MuscleGroup.obliques:
        return locale == 'fr' ? 'Obliques' : 'Obliques';

      case MuscleGroup.neck:
        return locale == 'fr' ? 'Cou' : 'Neck';

      case MuscleGroup.hipFlexors:
        return locale == 'fr' ? 'Fléchisseurs de la hanche' : 'Hip flexors';
    }
  }
}
