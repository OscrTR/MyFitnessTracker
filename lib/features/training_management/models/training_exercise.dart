import 'package:objectbox/objectbox.dart';

import '../../../core/enums/enums.dart';
import 'training.dart';
import 'multiset.dart';
import '../../exercise_management/models/exercise.dart';

@Entity()
class TrainingExercise {
  @Id()
  int id = 0;

  /// Relation `ToOne` avec `Training`
  final training = ToOne<Training>();
  int? linkedTrainingId; // ID du Training pour cas d'absence

  /// Relation `ToOne` avec `Multiset`
  final multiset = ToOne<Multiset>();
  int? linkedMultisetId; // ID du Multiset pour cas d'absence

  /// Relation `ToOne` avec `Exercise`
  final exercise = ToOne<Exercise>();
  int? linkedExerciseId; // ID de l'Exercise pour cas d'absence

  // Stocke l'index de l'enum `TrainingExerciseType`
  @Transient()
  TrainingExerciseType? type;

  int? get dbType {
    _ensureStableTrainingExerciseTypeEnumValues();
    return type?.index;
  }

  set dbType(int? value) {
    if (value == null) type = null;

    _ensureStableTrainingExerciseTypeEnumValues();
    type = value! >= 0 && value < TrainingExerciseType.values.length
        ? TrainingExerciseType.values[value]
        : TrainingExerciseType.unknown;
  }

  String? specialInstructions;
  String? objectives;

  // Stocke l'index de l'enum `RunType`
  @Transient()
  RunType? runType;

  int? get dbRunType {
    if (runType == null) return null;
    return runType!.index;
  }

  set dbRunType(int? value) {
    if (value == null) runType = null;
    runType = value! >= 0 && value < RunType.values.length
        ? RunType.values[value]
        : RunType.unknown;
  }

  int? targetDistance;
  int? targetDuration;
  bool? isTargetPaceSelected;
  int? targetPace;

  int sets;
  bool isSetsInReps;

  int? minReps;
  int? maxReps;
  int? duration;
  int? setRest;
  int? exerciseRest;

  bool isAutoStart;
  int? position;
  int intensity;
  String? key;

  TrainingExercise({
    required this.id,
    required this.linkedTrainingId,
    required this.linkedMultisetId,
    required this.linkedExerciseId,
    this.specialInstructions,
    this.objectives,
    this.targetDistance,
    this.targetDuration,
    this.isTargetPaceSelected,
    this.targetPace,
    required this.sets,
    required this.isSetsInReps,
    this.minReps,
    this.maxReps,
    this.duration,
    this.setRest,
    this.exerciseRest,
    required this.isAutoStart,
    this.position,
    required this.intensity,
    this.key,
  });

  TrainingExercise.create({
    this.id = 0,
    Training? training,
    Multiset? multiset,
    Exercise? exercise,
    required this.linkedTrainingId,
    required this.linkedMultisetId,
    required this.linkedExerciseId,
    required this.type,
    this.specialInstructions,
    this.objectives,
    required this.runType,
    this.targetDistance,
    this.targetDuration,
    this.isTargetPaceSelected,
    this.targetPace,
    required this.sets,
    required this.isSetsInReps,
    this.minReps,
    this.maxReps,
    this.duration,
    this.setRest,
    this.exerciseRest,
    required this.isAutoStart,
    this.position,
    required this.intensity,
    this.key,
  }) {
    if (training != null) {
      this.training.target = training;
      linkedTrainingId = training.id;
    }
    if (multiset != null) {
      this.multiset.target = multiset;
      linkedMultisetId = multiset.id;
    }
    if (exercise != null) {
      this.exercise.target = exercise;
      linkedExerciseId = exercise.id;
    }
  }

  void _ensureStableTrainingExerciseTypeEnumValues() {
    assert(TrainingExerciseType.run.index == 0);
    assert(TrainingExerciseType.yoga.index == 1);
    assert(TrainingExerciseType.workout.index == 2);
    assert(TrainingExerciseType.meditation.index == 3);
  }

  TrainingExercise copyWith({
    int? id,
    int? linkedTrainingId,
    int? linkedMultisetId,
    int? linkedExerciseId,
    TrainingExerciseType? type,
    String? specialInstructions,
    String? objectives,
    RunType? runType,
    int? targetDistance,
    int? targetDuration,
    bool? isTargetPaceSelected,
    int? targetPace,
    int? sets,
    bool? isSetsInReps,
    int? minReps,
    int? maxReps,
    int? duration,
    int? setRest,
    int? exerciseRest,
    bool? isAutoStart,
    int? position,
    int? intensity,
    String? key,
    Training? training,
    Multiset? multiset,
    Exercise? exercise,
  }) {
    return TrainingExercise.create(
      id: id ?? this.id,
      linkedTrainingId: linkedTrainingId ?? this.linkedTrainingId,
      linkedMultisetId: linkedMultisetId ?? this.linkedMultisetId,
      linkedExerciseId: linkedExerciseId ?? this.linkedExerciseId,
      type: type ?? this.type,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      objectives: objectives ?? this.objectives,
      runType: runType ?? this.runType,
      targetDistance: targetDistance ?? this.targetDistance,
      targetDuration: targetDuration ?? this.targetDuration,
      isTargetPaceSelected: isTargetPaceSelected ?? this.isTargetPaceSelected,
      targetPace: targetPace ?? this.targetPace,
      sets: sets ?? this.sets,
      isSetsInReps: isSetsInReps ?? this.isSetsInReps,
      minReps: minReps ?? this.minReps,
      maxReps: maxReps ?? this.maxReps,
      duration: duration ?? this.duration,
      setRest: setRest ?? this.setRest,
      exerciseRest: exerciseRest ?? this.exerciseRest,
      isAutoStart: isAutoStart ?? this.isAutoStart,
      position: position ?? this.position,
      intensity: intensity ?? this.intensity,
      key: key ?? this.key,
      training: training ?? this.training.target,
      multiset: multiset ?? this.multiset.target,
      exercise: exercise ?? this.exercise.target,
    );
  }

  /// Convertit un objet `TrainingExercise` en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'linkedTrainingId': linkedTrainingId,
      'linkedMultisetId': linkedMultisetId,
      'linkedExerciseId': linkedExerciseId,
      'type': dbType,
      'specialInstructions': specialInstructions,
      'objectives': objectives,
      'runType': dbRunType,
      'targetDistance': targetDistance,
      'targetDuration': targetDuration,
      'isTargetPaceSelected': isTargetPaceSelected,
      'targetPace': targetPace,
      'sets': sets,
      'isSetsInReps': isSetsInReps,
      'minReps': minReps,
      'maxReps': maxReps,
      'duration': duration,
      'setRest': setRest,
      'exerciseRest': exerciseRest,
      'isAutoStart': isAutoStart,
      'position': position,
      'intensity': intensity,
      'key': key,
      'exercise':
          exercise.target?.toJson(), // Sérialisation de l'exercice associé
    };
  }

  /// Crée un objet `TrainingExercise` à partir d'un JSON
  static TrainingExercise fromJson(Map<String, dynamic> json) {
    final trainingExercise = TrainingExercise.create(
      id: json['id'] as int? ?? 0,
      linkedTrainingId: json['linkedTrainingId'] as int?,
      linkedMultisetId: json['linkedMultisetId'] as int?,
      linkedExerciseId: json['linkedExerciseId'] as int?,
      type: json['type'] != null
          ? TrainingExerciseType.values[json['type'] as int]
          : null,
      specialInstructions: json['specialInstructions'] as String?,
      objectives: json['objectives'] as String?,
      runType: json['runType'] != null
          ? RunType.values[json['runType'] as int]
          : null,
      targetDistance: json['targetDistance'] as int?,
      targetDuration: json['targetDuration'] as int?,
      isTargetPaceSelected: json['isTargetPaceSelected'] as bool?,
      targetPace: json['targetPace'] as int?,
      sets: json['sets'] as int? ?? 0,
      isSetsInReps: json['isSetsInReps'] as bool? ?? false,
      minReps: json['minReps'] as int?,
      maxReps: json['maxReps'] as int?,
      duration: json['duration'] as int?,
      setRest: json['setRest'] as int?,
      exerciseRest: json['exerciseRest'] as int?,
      isAutoStart: json['isAutoStart'] as bool? ?? false,
      position: json['position'] as int?,
      intensity: json['intensity'] as int? ?? 0,
      key: json['key'] as String?,
      exercise: json['exercise'] != null
          ? Exercise.fromJson(json['exercise'] as Map<String, dynamic>)
          : null,
    );

    return trainingExercise;
  }
}
