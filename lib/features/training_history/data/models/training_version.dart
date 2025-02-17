import 'package:objectbox/objectbox.dart';

import '../../../training_management/models/multiset.dart';
import '../../../training_management/models/training.dart';
import '../../../training_management/models/training_exercise.dart';

@Entity()
class TrainingVersion {
  @Id()
  int id = 0;

  // Relation Many-To-One avec Training
  final training = ToOne<Training>();

  String name;
  int? dbType;
  String? objectives;
  String? dbTrainingDays;

  // Relations One-To-Many pour les exercices et les multisets
  final trainingExercises = ToMany<TrainingExercise>();
  final multisets = ToMany<Multiset>();

  // Default constructor (used by ObjectBox)
  TrainingVersion(this.name, this.dbType, this.objectives, this.dbTrainingDays);

  // Named constructor for app usage
  TrainingVersion.fromTraining(Training training)
      : name = training.name,
        dbType = training.dbType,
        objectives = training.objectives,
        dbTrainingDays = training.dbTrainingDays {
    if (training.trainingExercises.isNotEmpty) {
      trainingExercises.addAll(training.trainingExercises
          .map((tExercise) => tExercise.copyWith())
          .toList());
    }
    if (training.multisets.isNotEmpty) {
      multisets.addAll(
          training.multisets.map((multiset) => multiset.copyWith()).toList());
    }
  }
}
