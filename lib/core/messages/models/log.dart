import 'package:equatable/equatable.dart';

import '../../enums/enums.dart';

class Log extends Equatable {
  final int? id;
  final LogLevel level;
  final String? function;
  final String? message;
  final DateTime date;

  const Log({
    this.id,
    required this.level,
    this.function,
    this.message,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'level': level.toMap(),
      'function': function,
      'message': message,
      'date': date.millisecondsSinceEpoch
    };
  }

  factory Log.fromMap(Map<String, dynamic> map) {
    return Log(
      id: map['id'] as int?,
      level: LogLevel.fromMap(map['level'] as String),
      function: map['function'] as String?,
      message: map['message'] as String?,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
    );
  }

  @override
  List<Object?> get props => [id, level, function, message, date];
}
