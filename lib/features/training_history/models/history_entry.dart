// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:objectbox/objectbox.dart';

@Entity()
class HistoryEntry {
  @Id()
  int id = 0;
  @Index()
  int linkedTrainingId;
  int linkedTrainingVersionId;
  @Index()
  int linkedTrainingExerciseId;
  int setNumber;
  int? intervalNumber;
  DateTime date;
  int? reps;
  int? weight;
  int? duration;
  int? distance;
  int? pace;
  int? calories;

  HistoryEntry({
    required this.id,
    required this.linkedTrainingId,
    required this.linkedTrainingVersionId,
    required this.linkedTrainingExerciseId,
    required this.setNumber,
    required this.intervalNumber,
    required this.date,
    this.reps,
    this.weight,
    this.duration,
    this.distance,
    this.pace,
    this.calories,
  });

  HistoryEntry copyWith({
    int? id,
    int? linkedTrainingId,
    int? linkedTrainingVersionId,
    int? linkedTrainingExerciseId,
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
      linkedTrainingId: linkedTrainingId ?? this.linkedTrainingId,
      linkedTrainingVersionId:
          linkedTrainingVersionId ?? this.linkedTrainingVersionId,
      linkedTrainingExerciseId:
          linkedTrainingExerciseId ?? this.linkedTrainingExerciseId,
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
}
