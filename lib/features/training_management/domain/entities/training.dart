import 'package:equatable/equatable.dart';

import 'multiset.dart';
import 'training_exercise.dart';

class Training extends Equatable {
  final int? id;
  final String name;
  final TrainingType type;
  final bool isSelected;
  final List<TrainingExercise> trainingExercises;
  final List<Multiset> multisets;

  const Training({
    this.id,
    required this.name,
    required this.type,
    required this.isSelected,
    required this.trainingExercises,
    required this.multisets,
  });

  Training copyWith({
    int? id,
    String? name,
    TrainingType? type,
    bool? isSelected,
    List<TrainingExercise>? trainingExercises,
    List<Multiset>? multisets,
  }) {
    return Training(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      isSelected: isSelected ?? this.isSelected,
      trainingExercises: trainingExercises ?? this.trainingExercises,
      multisets: multisets ?? this.multisets,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, type, isSelected, trainingExercises, multisets];
}

enum TrainingType {
  run,
  yoga,
  cardio,
  mixed,
  workout;

  String translate(String locale) {
    switch (this) {
      case TrainingType.yoga:
        return locale == 'fr' ? 'Yoga' : 'Yoga';
      case TrainingType.workout:
        return locale == 'fr' ? 'Renforcement' : 'Workout';
      case TrainingType.run:
        return locale == 'fr' ? 'Course' : 'Run';
      case TrainingType.cardio:
        return locale == 'fr' ? 'Cardio' : 'Cardio';
      case TrainingType.mixed:
        return locale == 'fr' ? 'Mixte' : 'Mixed';
    }
  }
}
