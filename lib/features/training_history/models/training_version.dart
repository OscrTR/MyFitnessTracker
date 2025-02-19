import 'dart:convert';

import 'package:objectbox/objectbox.dart';

import '../../training_management/models/training.dart';

@Entity()
class TrainingVersion {
  @Id()
  int id = 0;
  @Index()
  int? linkedTrainingId; // Id du [Training] associé

  String? jsonRepresentation; // Snapshot complet sérialisé en JSON

  // Default constructor (used by ObjectBox)
  TrainingVersion(this.linkedTrainingId, this.jsonRepresentation);

  // Construction depuis un Training
  TrainingVersion.fromTraining(Training training)
      : linkedTrainingId = training.id,
        jsonRepresentation = jsonEncode(training.toJson());

  // Désérialisation pour recréer un Training complet
  Training? toTraining() {
    if (jsonRepresentation == null) return null;
    return Training.fromJson(jsonDecode(jsonRepresentation!));
  }
}
