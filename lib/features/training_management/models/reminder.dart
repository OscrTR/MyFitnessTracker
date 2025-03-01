import 'package:equatable/equatable.dart';
import '../../../core/enums/enums.dart';

class Reminder extends Equatable {
  final int? id;
  final int notificationId;
  final TrainingDay day;
  const Reminder({
    this.id,
    required this.notificationId,
    required this.day,
  });

  Reminder copyWith({
    int? id,
    int? notificationId,
    TrainingDay? day,
  }) {
    return Reminder(
      id: id ?? this.id,
      notificationId: notificationId ?? this.notificationId,
      day: day ?? this.day,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'notificationId': notificationId,
      'day': day.toMap(),
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'] as int?,
      notificationId: map['notificationId'] as int,
      day: TrainingDay.fromMap(map['day'] as String),
    );
  }

  @override
  List<Object?> get props => [id, notificationId, day];
}
