import 'dart:convert';

import 'package:equatable/equatable.dart';

import '../../base_exercise_management/models/base_exercise.dart';

import '../../../core/enums/enums.dart';
import 'exercise.dart';
import 'multiset.dart';

class Training extends Equatable {
  final int? id;
  final String name;
  final TrainingType trainingType;
  final String objectives;
  final List<TrainingDay> trainingDays;
  final List<Multiset> multisets;
  final List<Exercise> exercises;
  final List<BaseExercise> baseExercises;

  const Training({
    this.id,
    required this.name,
    required this.trainingType,
    required this.objectives,
    required this.trainingDays,
    required this.multisets,
    required this.exercises,
    required this.baseExercises,
  });

  @override
  List<Object?> get props {
    return [
      id,
      name,
      trainingType,
      objectives,
      trainingDays,
      multisets,
      exercises,
      baseExercises,
    ];
  }

  Training copyWith({
    int? id,
    String? name,
    TrainingType? trainingType,
    String? objectives,
    List<TrainingDay>? trainingDays,
    List<Multiset>? multisets,
    List<Exercise>? exercises,
    List<BaseExercise>? baseExercises,
  }) {
    return Training(
      id: id ?? this.id,
      name: name ?? this.name,
      trainingType: trainingType ?? this.trainingType,
      objectives: objectives ?? this.objectives,
      trainingDays: trainingDays ?? this.trainingDays,
      multisets: multisets ?? this.multisets,
      exercises: exercises ?? this.exercises,
      baseExercises: baseExercises ?? this.baseExercises,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'trainingType': trainingType.toMap(),
      'objectives': objectives,
      'trainingDays': TrainingDay.listToMap(trainingDays),
    };
  }

  factory Training.fromMap(Map<String, dynamic> map) {
    return Training(
      id: map['id'] != null ? map['id'] as int : null,
      name: map['name'] as String,
      trainingType: TrainingType.fromMap(map['trainingType']),
      objectives: map['objectives'] as String,
      trainingDays: TrainingDay.listFromMap(map['trainingDays']),
      multisets: [],
      exercises: [],
      baseExercises: [],
    );
  }

  String toJson() => json.encode(toMap());

  factory Training.fromJson(String source) =>
      Training.fromMap(json.decode(source) as Map<String, dynamic>);
}
