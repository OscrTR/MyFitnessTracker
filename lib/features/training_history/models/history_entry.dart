import 'dart:convert';

import 'package:equatable/equatable.dart';

class HistoryEntry extends Equatable {
  final int? id;
  final int trainingId;
  final int exerciseId;
  final int trainingVersionId;
  final int setNumber;
  final int? intervalNumber;
  final DateTime date;
  final int reps;
  final int weight;
  final int duration;
  final int distance;
  final int pace;
  final int calories;

  const HistoryEntry({
    this.id,
    required this.trainingId,
    required this.exerciseId,
    required this.trainingVersionId,
    required this.setNumber,
    this.intervalNumber,
    required this.date,
    required this.reps,
    required this.weight,
    required this.duration,
    required this.distance,
    required this.pace,
    required this.calories,
  });

  @override
  List<Object?> get props {
    return [
      id,
      trainingId,
      exerciseId,
      trainingVersionId,
      setNumber,
      intervalNumber,
      date,
      reps,
      weight,
      duration,
      distance,
      pace,
      calories,
    ];
  }

  HistoryEntry copyWith({
    int? id,
    int? trainingId,
    int? exerciseId,
    int? trainingVersionId,
    int? setNumber,
    int? intervalNumber,
    DateTime? date,
    int? reps,
    int? weight,
    int? duration,
    int? distance,
    int? pace,
    int? calories,
  }) {
    return HistoryEntry(
      id: id ?? this.id,
      trainingId: trainingId ?? this.trainingId,
      exerciseId: exerciseId ?? this.exerciseId,
      trainingVersionId: trainingVersionId ?? this.trainingVersionId,
      setNumber: setNumber ?? this.setNumber,
      intervalNumber: intervalNumber ?? this.intervalNumber,
      date: date ?? this.date,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      duration: duration ?? this.duration,
      distance: distance ?? this.distance,
      pace: pace ?? this.pace,
      calories: calories ?? this.calories,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'trainingId': trainingId,
      'exerciseId': exerciseId,
      'trainingVersionId': trainingVersionId,
      'setNumber': setNumber,
      'intervalNumber': intervalNumber,
      'date': date.millisecondsSinceEpoch,
      'reps': reps,
      'weight': weight,
      'duration': duration,
      'distance': distance,
      'pace': pace,
      'calories': calories,
    };
  }

  factory HistoryEntry.fromMap(Map<String, dynamic> map) {
    return HistoryEntry(
      id: map['id'] as int?,
      trainingId: map['trainingId'] as int,
      exerciseId: map['exerciseId'] as int,
      trainingVersionId: map['trainingVersionId'] as int,
      setNumber: map['setNumber'] as int,
      intervalNumber: map['intervalNumber'] as int?,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      reps: map['reps'] as int,
      weight: map['weight'] as int,
      duration: map['duration'] as int,
      distance: map['distance'] as int,
      pace: map['pace'] as int,
      calories: map['calories'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory HistoryEntry.fromJson(String source) =>
      HistoryEntry.fromMap(json.decode(source) as Map<String, dynamic>);
}
