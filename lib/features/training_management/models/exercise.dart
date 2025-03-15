import 'dart:convert';

import 'package:equatable/equatable.dart';

import '../../../core/enums/enums.dart';

class Exercise extends Equatable {
  final int? id;
  final int? trainingId;
  final int? multisetId;
  final int? baseExerciseId;
  final ExerciseType exerciseType;
  final RunType runType;
  final String specialInstructions;
  final String objectives;
  final int targetDistance;
  final int targetDuration;
  final bool isTargetPaceSelected;
  final double targetPace;
  final int sets;
  final bool isSetsInReps;
  final int minReps;
  final int maxReps;
  final int duration;
  final int setRest;
  final int exerciseRest;
  final bool isAutoStart;
  final int? position;
  final int intensity;
  final String? widgetKey;
  final String? multisetKey;

  const Exercise({
    this.id,
    this.trainingId,
    this.multisetId,
    this.baseExerciseId,
    required this.exerciseType,
    required this.runType,
    required this.specialInstructions,
    required this.objectives,
    required this.targetDistance,
    required this.targetDuration,
    required this.isTargetPaceSelected,
    required this.targetPace,
    required this.sets,
    required this.isSetsInReps,
    required this.minReps,
    required this.maxReps,
    required this.duration,
    required this.setRest,
    required this.exerciseRest,
    required this.isAutoStart,
    this.position,
    required this.intensity,
    this.widgetKey,
    this.multisetKey,
  });

  @override
  List<Object?> get props {
    return [
      id,
      trainingId,
      multisetId,
      baseExerciseId,
      exerciseType,
      runType,
      specialInstructions,
      objectives,
      targetDistance,
      targetDuration,
      isTargetPaceSelected,
      targetPace,
      sets,
      isSetsInReps,
      minReps,
      maxReps,
      duration,
      setRest,
      exerciseRest,
      isAutoStart,
      position,
      intensity,
      widgetKey,
      multisetKey,
    ];
  }

  Exercise copyWith({
    int? id,
    int? trainingId,
    int? multisetId,
    int? baseExerciseId,
    ExerciseType? exerciseType,
    RunType? runType,
    String? specialInstructions,
    String? objectives,
    int? targetDistance,
    int? targetDuration,
    bool? isTargetPaceSelected,
    double? targetPace,
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
    String? widgetKey,
    String? multisetKey,
    bool resetKeys = false,
  }) {
    return Exercise(
      id: id ?? this.id,
      trainingId: trainingId ?? this.trainingId,
      multisetId: multisetId ?? this.multisetId,
      baseExerciseId: baseExerciseId ?? this.baseExerciseId,
      exerciseType: exerciseType ?? this.exerciseType,
      runType: runType ?? this.runType,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      objectives: objectives ?? this.objectives,
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
      widgetKey: resetKeys ? null : widgetKey ?? this.widgetKey,
      multisetKey: resetKeys ? null : multisetKey ?? this.multisetKey,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'trainingId': trainingId,
      'multisetId': multisetId,
      'baseExerciseId': baseExerciseId,
      'exerciseType': exerciseType.toMap(),
      'runType': runType.toMap(),
      'specialInstructions': specialInstructions,
      'objectives': objectives,
      'targetDistance': targetDistance,
      'targetDuration': targetDuration,
      'isTargetPaceSelected': isTargetPaceSelected ? 1 : 0,
      'targetPace': targetPace,
      'sets': sets,
      'isSetsInReps': isSetsInReps ? 1 : 0,
      'minReps': minReps,
      'maxReps': maxReps,
      'duration': duration,
      'setRest': setRest,
      'exerciseRest': exerciseRest,
      'isAutoStart': isAutoStart ? 1 : 0,
      'position': position,
      'intensity': intensity,
      'widgetKey': widgetKey,
      'multisetKey': multisetKey,
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'] as int?,
      trainingId: map['trainingId'] != null ? map['trainingId'] as int : null,
      multisetId: map['multisetId'] != null ? map['multisetId'] as int : null,
      baseExerciseId:
          map['baseExerciseId'] != null ? map['baseExerciseId'] as int : null,
      exerciseType: ExerciseType.fromMap(map['exerciseType']),
      runType: RunType.fromMap(map['runType']),
      specialInstructions: map['specialInstructions'] as String,
      objectives: map['objectives'] as String,
      targetDistance: map['targetDistance'] as int,
      targetDuration: map['targetDuration'] as int,
      isTargetPaceSelected:
          (map['isTargetPaceSelected'] as int) == 1 ? true : false,
      targetPace: map['targetPace'] as double,
      sets: map['sets'] as int,
      isSetsInReps: (map['isSetsInReps'] as int) == 1 ? true : false,
      minReps: map['minReps'] as int,
      maxReps: map['maxReps'] as int,
      duration: map['duration'] as int,
      setRest: map['setRest'] as int,
      exerciseRest: map['exerciseRest'] as int,
      isAutoStart: (map['isAutoStart'] as int) == 1 ? true : false,
      position: map['position'] != null ? map['position'] as int : null,
      intensity: map['intensity'] as int,
      widgetKey: map['widgetKey'] != null ? map['widgetKey'] as String : null,
      multisetKey:
          map['multisetKey'] != null ? map['multisetKey'] as String : null,
    );
  }

  static String listToMap(List<Exercise> exercises) {
    return jsonEncode(exercises.map((exercise) => exercise.toMap()).toList());
  }

  static List<Exercise> listFromMap(String jsonString) {
    final List<dynamic> decodedList = jsonDecode(jsonString);
    return decodedList.map((value) => Exercise.fromMap(value)).toList();
  }
}
