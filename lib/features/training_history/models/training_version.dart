import 'package:equatable/equatable.dart';

import '../../training_management/models/training.dart';

class TrainingVersion extends Equatable {
  final int? id;
  final int trainingId;
  final String jsonRepresentation; // Snapshot complet sérialisé en JSON

  const TrainingVersion({
    this.id,
    required this.trainingId,
    required this.jsonRepresentation,
  });

  @override
  List<Object?> get props => [id, trainingId, jsonRepresentation];

  /// Getter pour convertir le `jsonRepresentation` en un objet `Training`
  Training get training => Training.fromJson(jsonRepresentation);

  /// Setter pour sérialiser un `Training` en JSON et mettre à jour `jsonRepresentation`
  factory TrainingVersion.fromTraining({
    int? id,
    required int trainingId,
    required Training training,
  }) {
    return TrainingVersion(
      id: id,
      trainingId: trainingId,
      jsonRepresentation: training.toJson(), // Sérialise le training en JSON
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'trainingId': trainingId,
      'jsonRepresentation': jsonRepresentation,
    };
  }

  factory TrainingVersion.fromMap(Map<String, dynamic> map) {
    return TrainingVersion(
      id: map['id'] != null ? map['id'] as int : null,
      trainingId: map['trainingId'] as int,
      jsonRepresentation: map['jsonRepresentation'] as String,
    );
  }
}
