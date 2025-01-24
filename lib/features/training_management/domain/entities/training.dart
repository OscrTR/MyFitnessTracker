import 'package:equatable/equatable.dart';

import 'multiset.dart';
import 'training_exercise.dart';

class Training extends Equatable {
  final int? id;
  final String name;
  final TrainingType type;
  final List<TrainingExercise> trainingExercises;
  final List<Multiset> multisets;
  final String? objectives;
  final List<WeekDay>? trainingDays;

  const Training({
    this.id,
    required this.name,
    required this.type,
    required this.trainingExercises,
    required this.multisets,
    this.objectives,
    this.trainingDays,
  });

  Training copyWith({
    int? id,
    String? name,
    TrainingType? type,
    bool? isSelected,
    List<TrainingExercise>? trainingExercises,
    List<Multiset>? multisets,
    String? objectives,
    List<WeekDay>? trainingDays,
  }) {
    return Training(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      trainingExercises: trainingExercises ?? this.trainingExercises,
      multisets: multisets ?? this.multisets,
      objectives: objectives ?? this.objectives,
      trainingDays: trainingDays ?? this.trainingDays,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, type, trainingExercises, multisets, objectives, trainingDays];
}

enum TrainingType {
  run,
  yoga,
  workout;

  String translate(String locale) {
    switch (this) {
      case TrainingType.yoga:
        return locale == 'fr' ? 'Yoga' : 'Yoga';
      case TrainingType.workout:
        return locale == 'fr' ? 'Renforcement' : 'Workout';
      case TrainingType.run:
        return locale == 'fr' ? 'Course' : 'Run';
    }
  }
}

enum WeekDay {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday;

  String translate(String locale) {
    switch (this) {
      case WeekDay.monday:
        return locale == 'fr' ? 'Lundi' : 'Monday';
      case WeekDay.tuesday:
        return locale == 'fr' ? 'Mardi' : 'Tuesday';
      case WeekDay.wednesday:
        return locale == 'fr' ? 'Mercredi' : 'Wednesday';
      case WeekDay.thursday:
        return locale == 'fr' ? 'Jeudi' : 'Thursday';
      case WeekDay.friday:
        return locale == 'fr' ? 'Vendredi' : 'Friday';
      case WeekDay.saturday:
        return locale == 'fr' ? 'Samedi' : 'Saturday';
      case WeekDay.sunday:
        return locale == 'fr' ? 'Dimanche' : 'Sunday';
    }
  }
}
