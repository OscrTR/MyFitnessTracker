import 'dart:convert';
import 'package:objectbox/objectbox.dart';
import '../../../core/enums/enums.dart';

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
    type = value != null && value >= 0 && value < ExerciseType.values.length
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

  /// Convertit un objet `Exercise` en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imagePath': imagePath,
      'description': description,
      'type': dbType,
      'muscleGroups':
          dbMuscleGroups, // Conserve la liste des groupes musculaires sous forme de chaîne JSON
    };
  }

  /// Crée un objet `Exercise` à partir d'un JSON
  static Exercise fromJson(Map<String, dynamic> json) {
    final exercise = Exercise(json['name'] as String)
      ..id = json['id'] as int
      ..imagePath = json['imagePath'] as String?
      ..description = json['description'] as String?
      ..dbType = json['type'] as int?
      ..dbMuscleGroups = json['muscleGroups'] as String?;
    return exercise;
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
