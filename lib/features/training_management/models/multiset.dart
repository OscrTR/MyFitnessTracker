import 'package:objectbox/objectbox.dart';
import 'training.dart';
import 'training_exercise.dart';

@Entity()
class Multiset {
  @Id()
  int id = 0;

  /// Relation `ToOne` avec `Training`
  final training = ToOne<Training>();
  int? linkedTrainingId; // ID du Training pour cas d'absence

  int sets; // Nombre de séries dans ce [Multiset]
  int setRest; // Temps de repos entre les séries (en secondes)
  int multisetRest; // Temps de repos après ce [Multiset] (en secondes)
  String? specialInstructions; // Instructions spécifiques (optionnel)
  String? objectives; // Objectifs spécifiques (optionnel)
  int? position; // Position dans une session d'entraînement
  String? key; // Identifiant unique pour le widget associé

  @Backlink('multiset')
  final trainingExercises = ToMany<TrainingExercise>();

  // Default constructor (utilisé par ObjectBox)
  Multiset({
    required this.id,
    required this.sets,
    required this.setRest,
    required this.multisetRest,
    required this.position,
    required this.key,
    this.linkedTrainingId,
  });

  // Constructeur nommé pour une utilisation plus générale
  Multiset.create({
    this.id = 0,
    Training? training, // Assigner le Training via la relation
    required this.sets,
    required this.setRest,
    required this.multisetRest,
    required this.position,
    this.key,
    this.linkedTrainingId,
    this.specialInstructions,
    this.objectives,
    required List<TrainingExercise> trainingExercises,
  }) {
    if (training != null) {
      this.training.target = training;
      linkedTrainingId = training.id;
    }
    if (trainingExercises.isNotEmpty) {
      this.trainingExercises.addAll(trainingExercises);
    }
  }

  // Méthode copyWith mise à jour
  Multiset copyWith({
    int? id,
    Training? training,
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
    final copy = Multiset(
      id: id ?? this.id,
      sets: sets ?? this.sets,
      setRest: setRest ?? this.setRest,
      multisetRest: multisetRest ?? this.multisetRest,
      position: position ?? this.position,
      key: key ?? this.key,
    );

    copy.specialInstructions = specialInstructions ?? this.specialInstructions;
    copy.objectives = objectives ?? this.objectives;
    copy.training.target = training ?? this.training.target;
    copy.linkedTrainingId = linkedTrainingId ?? this.linkedTrainingId;

    // Copie des `TrainingExercises`
    copy.trainingExercises.addAll(
      trainingExercises != null
          ? trainingExercises.map((tExercise) => tExercise.copyWith()).toList()
          : this
              .trainingExercises
              .map((tExercise) => tExercise.copyWith())
              .toList(),
    );
    return copy;
  }

  /// Convertit un objet `Multiset` en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trainingId':
          training.target?.id, // Sérialisation de la relation avec Training
      'linkedTrainingId':
          linkedTrainingId, // Stockage de l'ID même si Training est supprimé
      'sets': sets,
      'setRest': setRest,
      'multisetRest': multisetRest,
      'specialInstructions': specialInstructions,
      'objectives': objectives,
      'position': position,
      'key': key,
      'trainingExercises': trainingExercises
          .map((exercise) => exercise.toJson())
          .toList(), // Sérialisation des TrainingExercises associés
    };
  }

  /// Crée un objet `Multiset` à partir d'un JSON
  static Multiset fromJson(Map<String, dynamic> json) {
    final multiset = Multiset.create(
      id: json['id'] as int? ?? 0,
      training: null, // La relation n'est pas restaurée
      linkedTrainingId:
          json['linkedTrainingId'] as int?, // Stocke l'ID du Training d'origine
      sets: json['sets'] as int? ?? 0,
      setRest: json['setRest'] as int? ?? 0,
      multisetRest: json['multisetRest'] as int? ?? 0,
      position: json['position'] as int?,
      key: json['key'] as String?,
      specialInstructions: json['specialInstructions'] as String?,
      objectives: json['objectives'] as String?,
      trainingExercises: (json['trainingExercises'] as List<dynamic>?)
              ?.map((e) => TrainingExercise.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

    return multiset;
  }
}
