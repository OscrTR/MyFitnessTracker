import 'package:equatable/equatable.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Reminder extends Equatable {
  final int? id;
  final int notificationId;
  final Day day;
  const Reminder({
    this.id,
    required this.notificationId,
    required this.day,
  });

  Reminder copyWith({
    int? id,
    int? notificationId,
    Day? day,
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
      'day': day.value,
    };
  }

  static dayFromValue(int value) {
    return Day.values
        .firstWhere((day) => day.value == value, orElse: () => Day.sunday);
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'] as int?,
      notificationId: map['notificationId'] as int,
      day: dayFromValue(map['day'] as int),
    );
  }

  @override
  List<Object?> get props => [id, notificationId, day];
}
