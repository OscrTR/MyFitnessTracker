import 'package:my_fitness_tracker/features/exercise_management/models/exercise.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class TrainingExercise {
  @Id()
  int id = 0;

  int? linkedTrainingId; // Id du [Training] associé

  int? linkedMultisetId; // Id du [Multiset] associé (optionnel)

  int? linkedExerciseId; // Id du [Exercise] associé (optionnel)

  final exercise = ToOne<Exercise>();

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
    required this.sets,
    required this.isSetsInReps,
    required this.isAutoStart,
    required this.intensity,
  });

  TrainingExercise.create({
    this.id = 0,
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
    required Exercise? exercise,
  }) {
    this.exercise.target = exercise;
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
      exercise: exercise?.copyWith() ?? this.exercise.target?.copyWith(),
    );
  }
}

// Enum `TrainingExerciseType`
enum TrainingExerciseType {
  run,
  yoga,
  workout,
  meditation,
  unknown;

  String translate(String locale) {
    switch (this) {
      case TrainingExerciseType.yoga:
        return locale == 'fr' ? 'Yoga' : 'Yoga';
      case TrainingExerciseType.workout:
        return locale == 'fr' ? 'Renforcement' : 'Workout';
      case TrainingExerciseType.run:
        return locale == 'fr' ? 'Course' : 'Run';
      case TrainingExerciseType.meditation:
        return locale == 'fr' ? 'Méditation' : 'Meditation';
      case TrainingExerciseType.unknown:
        return locale == 'fr' ? 'Inconnu' : 'Unknown';
    }
  }
}

// Enum `RunExerciseTarget`
enum RunType {
  distance,
  duration,
  unknown;

  String translate(String locale) {
    switch (this) {
      case RunType.distance:
        return locale == 'fr' ? 'Distance' : 'Distance';
      case RunType.duration:
        return locale == 'fr' ? 'Durée' : 'Duration';
      case RunType.unknown:
        return locale == 'fr' ? 'Inconnu' : 'Unknown';
    }
  }
}
