import 'package:objectbox/objectbox.dart';

import 'training_exercise.dart';

@Entity()
class Multiset {
  @Id()
  int id = 0;

  int? linkedTrainingId; // Id du [Training] associé

  final trainingExercises = ToMany<TrainingExercise>();

  int sets; // Nombre de séries dans ce [Multiset]
  int setRest; // Temps de repos entre les séries (en secondes)
  int multisetRest; // Temps de repos après ce [Multiset] (en secondes)

  String? specialInstructions; // Instructions spécifiques (optionnel)
  String? objectives; // Objectifs spécifiques (optionnel)

  int? position; // Position dans une session d'entraînement
  String? key; // Identifiant unique pour le widget associé

// Default constructor (used by ObjectBox)
  Multiset({
    required this.id,
    required this.linkedTrainingId,
    required this.sets,
    required this.setRest,
    required this.multisetRest,
    required this.position,
    required this.key,
  });

  // Named constructor for app usage
  Multiset.create({
    this.id = 0,
    required this.linkedTrainingId,
    required this.sets,
    required this.setRest,
    required this.multisetRest,
    required this.position,
    this.key,
    this.specialInstructions,
    this.objectives,
    required List<TrainingExercise> trainingExercises,
  }) {
    if (trainingExercises.isNotEmpty) {
      this.trainingExercises.addAll(trainingExercises);
    }
  }

  Multiset copyWith({
    int? id,
    int? linkedTrainingId,
    List<TrainingExercise>? trainingExercises,
    int? sets,
    int? setRest,
    int? multisetRest,
    String? specialInstructions,
    String? objectives,
    int? position,
    String? key,
  }) {
    return Multiset(
      id: id ?? this.id,
      linkedTrainingId: linkedTrainingId ?? this.linkedTrainingId,
      sets: sets ?? this.sets,
      setRest: setRest ?? this.setRest,
      multisetRest: multisetRest ?? this.multisetRest,
      position: position ?? this.position,
      key: key ?? this.key,
    )
      ..specialInstructions = specialInstructions ?? this.specialInstructions
      ..objectives = objectives ?? this.objectives
      ..trainingExercises.clear()
      ..trainingExercises.addAll(
        trainingExercises != null
            ? trainingExercises
                .map((tExercise) => tExercise.copyWith())
                .toList()
            : this
                .trainingExercises
                .map((tExercise) => tExercise.copyWith())
                .toList(),
      );
  }
}
