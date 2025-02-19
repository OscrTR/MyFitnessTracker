import 'dart:convert';

import 'package:objectbox/objectbox.dart';

import '../../../core/enums/enums.dart';
import '../../training_history/models/training_version.dart';
import 'multiset.dart';
import 'training_exercise.dart';

@Entity()
class Training {
  @Id()
  int id = 0;

  String name;

  // Property pour stocker l'index de l'enum TrainingType
  @Transient()
  TrainingType? type;

  int? get dbType {
    _ensureStableTrainingTypeEnumValues();
    return type?.index;
  }

  set dbType(int? value) {
    if (value == null) type = null;

    _ensureStableTrainingTypeEnumValues();
    type = value! >= 0 && value < TrainingType.values.length
        ? TrainingType.values[value]
        : TrainingType.unknown;
  }

  // Relation One-To-Many
  final trainingExercises = ToMany<TrainingExercise>();
  final multisets = ToMany<Multiset>();

  // Stocker les objectifs sous forme de chaîne
  String? objectives;

  // Stocker les WeekDays (enum) sous forme de chaîne (ex. JSON)
  @Transient()
  List<WeekDay>? trainingDays;

  String? get dbTrainingDays {
    return WeekDayHelper.enumListToJson(trainingDays);
  }

  set dbTrainingDays(String? value) {
    // Lors de la création du training, convertir le string en list de Weekdays
    trainingDays = WeekDayHelper.jsonToEnumList(value);
  }

  // Relation One-To-Many pour stocker les versions précédentes
  final trainingVersions = ToMany<TrainingVersion>();

  // Default constructor (used by ObjectBox)
  Training(this.name);

  // Named constructor for app usage
  Training.create({
    required this.name,
    required this.type,
    required this.objectives,
    required this.trainingDays,
    required List<TrainingExercise> trainingExercises,
    required List<Multiset> multisets,
  }) {
    if (trainingExercises.isNotEmpty) {
      this.trainingExercises.addAll(trainingExercises);
    }
    if (multisets.isNotEmpty) {
      this.multisets.addAll(multisets);
    }
  }

  void _ensureStableTrainingTypeEnumValues() {
    assert(TrainingType.run.index == 0);
    assert(TrainingType.yoga.index == 1);
    assert(TrainingType.workout.index == 2);
  }

  Training copyWith({
    int? id,
    String? name,
    TrainingType? type,
    String? objectives,
    List<TrainingExercise>? trainingExercises,
    List<Multiset>? multisets,
    List<WeekDay>? trainingDays,
  }) {
    return Training(name ?? this.name)
      ..id = id ?? this.id
      ..type = type ?? this.type
      ..objectives = objectives ?? this.objectives
      ..trainingExercises.clear()
      ..trainingExercises.addAll(trainingExercises?.map((e) => e.copyWith()) ??
          this.trainingExercises.map((e) => e.copyWith()))
      ..multisets.clear()
      ..multisets.addAll(multisets?.map((e) => e.copyWith()) ??
          this.multisets.map((e) => e.copyWith()))
      ..trainingDays = trainingDays ?? this.trainingDays;
  }

  /// Convertit un objet `Training` en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': dbType,
      'objectives': objectives,
      'trainingDays':
          dbTrainingDays, // Conserve les jours d'entraînement sous forme de chaîne JSON
      'trainingExercises': trainingExercises
          .map((exercise) => exercise.toJson())
          .toList(), // Sérialisation des TrainingExercises
      'multisets': multisets
          .map((multiset) => multiset.toJson())
          .toList(), // Sérialisation des Multisets
    };
  }

  /// Crée un objet `Training` à partir d'un JSON
  static Training fromJson(Map<String, dynamic> json) {
    final training = Training(json['name'] as String)
      ..id = json['id'] as int? ?? 0
      ..dbType = json['type'] as int?
      ..objectives = json['objectives'] as String?
      ..dbTrainingDays = json['trainingDays'] as String?;

    // Désérialisation de la liste des TrainingExercises
    final exercisesJson = json['trainingExercises'] as List<dynamic>?;
    if (exercisesJson != null) {
      training.trainingExercises.addAll(exercisesJson
          .map((e) => TrainingExercise.fromJson(e as Map<String, dynamic>)));
    }

    // Désérialisation de la liste des Multisets
    final multisetsJson = json['multisets'] as List<dynamic>?;
    if (multisetsJson != null) {
      training.multisets.addAll(multisetsJson
          .map((e) => Multiset.fromJson(e as Map<String, dynamic>)));
    }

    return training;
  }
}

// Helper pour convertir une liste d'énums en chaîne JSON et vice-versa
class WeekDayHelper {
  static String? enumListToJson(List<WeekDay>? enums) {
    if (enums == null) return null;
    return jsonEncode(enums.map((e) => e.index).toList());
  }

  static List<WeekDay>? jsonToEnumList(String? json) {
    if (json == null) return null;
    return (jsonDecode(json) as List<dynamic>)
        .map((e) => WeekDay.values[e as int])
        .toList();
  }
}
