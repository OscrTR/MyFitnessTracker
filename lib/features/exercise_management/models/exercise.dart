import 'dart:convert';

import 'package:objectbox/objectbox.dart';

@Entity()
class Exercise {
  @Id()
  int id = 0;

  String name;
  String? imagePath;
  String? description;

  // Stocke l'index de l'enum `ExerciseType`
  @Transient()
  ExerciseType? type;

  int? get dbType {
    _ensureStableExerciseTypeEnumValues();
    return type?.index;
  }

  set dbType(int? value) {
    if (value == null) type = null;

    _ensureStableExerciseTypeEnumValues();
    type = value! >= 0 && value < ExerciseType.values.length
        ? ExerciseType.values[value]
        : ExerciseType.unknown;
  }

  // Stocker les [MuscleGroup] (enum) sous forme de chaîne (ex. JSON)
  @Transient()
  List<MuscleGroup>? muscleGroups;

  String? get dbMuscleGroups {
    return MuscleGroupHelper.enumListToJson(muscleGroups);
  }

  set dbMuscleGroups(String? value) {
    // Lors de la création de l'exercise, convertir le string en list de [MuscleGroup]
    muscleGroups = MuscleGroupHelper.jsonToEnumList(value);
  }

// Default constructor (used by ObjectBox)
  Exercise(this.name);

  // Named constructor for app usage
  Exercise.create({
    required this.name,
    required this.type,
    required this.imagePath,
    required this.description,
    required this.muscleGroups,
  });

  Exercise copyWith({
    int? id,
    String? name,
    String? imagePath,
    String? description,
    ExerciseType? type,
    List<MuscleGroup>? muscleGroups,
  }) {
    return Exercise(name ?? this.name)
      ..id = id ?? this.id
      ..imagePath = imagePath ?? this.imagePath
      ..description = description ?? this.description
      ..type = type ?? this.type
      ..muscleGroups = muscleGroups ?? this.muscleGroups;
  }

  void _ensureStableExerciseTypeEnumValues() {
    assert(ExerciseType.yoga.index == 0);
    assert(ExerciseType.workout.index == 1);
    assert(ExerciseType.meditation.index == 2);
  }
}

// Helper pour convertir une liste d'énums en chaîne JSON et vice-versa
class MuscleGroupHelper {
  static String? enumListToJson(List<MuscleGroup>? enums) {
    if (enums == null) return null;
    return jsonEncode(enums.map((e) => e.index).toList());
  }

  static List<MuscleGroup>? jsonToEnumList(String? json) {
    if (json == null) return null;
    return (jsonDecode(json) as List<dynamic>)
        .map((e) => MuscleGroup.values[e as int])
        .toList();
  }
}

enum ExerciseType {
  yoga,
  workout,
  meditation,
  unknown;

  String translate(String locale) {
    switch (this) {
      case ExerciseType.yoga:
        return locale == 'fr' ? 'Yoga' : 'Yoga';
      case ExerciseType.workout:
        return locale == 'fr' ? 'Renforcement' : 'Workout';
      case ExerciseType.meditation:
        return locale == 'fr' ? 'Méditation' : 'Meditation';
      case ExerciseType.unknown:
        return locale == 'fr' ? 'Inconnu' : 'Unknown';
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
