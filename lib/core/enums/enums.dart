import 'dart:convert';

enum RunType {
  distance,
  duration,
  unknown;

  String toMap() {
    switch (this) {
      case RunType.distance:
        return 'distance';
      case RunType.duration:
        return 'duration';
      case RunType.unknown:
        return 'unknown';
    }
  }

  static RunType fromMap(String value) {
    switch (value) {
      case 'distance':
        return RunType.distance;
      case 'duration':
        return RunType.duration;
      case 'unknown':
      default:
        return RunType.unknown;
    }
  }

  String translate(String locale) {
    switch (this) {
      case RunType.distance:
        return locale == 'fr' ? 'Distance' : 'Distance';
      case RunType.duration:
        return locale == 'fr' ? 'Durée' : 'Duration';
      case RunType.unknown:
        return locale == 'fr' ? 'Inconnu' : 'Unknown';
    }
  }
}

enum LogLevel {
  debug,
  info,
  warning,
  error,
  critical,
  unknown;

  String toMap() {
    switch (this) {
      case LogLevel.debug:
        return 'DEBUG';
      case LogLevel.info:
        return 'INFO';
      case LogLevel.warning:
        return 'WARNING';
      case LogLevel.error:
        return 'ERROR';
      case LogLevel.critical:
        return 'CRITICAL';
      case LogLevel.unknown:
        return 'UNKNOWN';
    }
  }

  static LogLevel fromMap(String value) {
    switch (value) {
      case 'DEBUG':
        return LogLevel.debug;
      case 'INFO':
        return LogLevel.info;
      case 'WARNING':
        return LogLevel.warning;
      case 'ERROR':
        return LogLevel.error;
      case 'CRITICAL':
        return LogLevel.critical;
      default:
        return LogLevel.unknown;
    }
  }
}

enum TrainingType {
  running,
  yoga,
  workout,
  unknown;

  String toMap() {
    switch (this) {
      case TrainingType.running:
        return 'running';
      case TrainingType.yoga:
        return 'yoga';
      case TrainingType.workout:
        return 'workout';
      case TrainingType.unknown:
        return 'unknown';
    }
  }

  static TrainingType fromMap(String value) {
    switch (value) {
      case 'running':
        return TrainingType.running;
      case 'yoga':
        return TrainingType.yoga;
      case 'workout':
        return TrainingType.workout;
      case 'unknown':
      default:
        return TrainingType.unknown;
    }
  }

  String translate(String locale) {
    switch (this) {
      case TrainingType.running:
        return locale == 'fr' ? 'Course' : 'Running';
      case TrainingType.yoga:
        return locale == 'fr' ? 'Yoga' : 'Yoga';
      case TrainingType.workout:
        return locale == 'fr' ? 'Renforcement' : 'Workout';
      case TrainingType.unknown:
        return locale == 'fr' ? 'Inconnu' : 'Unknown';
    }
  }
}

enum TrainingDay {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday;

  String toMap() {
    return name;
  }

  static TrainingDay fromMap(String value) {
    return TrainingDay.values.firstWhere(
      (day) => day.name == value,
      orElse: () => throw ArgumentError('Unknown TrainingDay value: $value'),
    );
  }

  static String listToMap(List<TrainingDay> days) {
    return jsonEncode(days.map((day) => day.toMap()).toList());
  }

  static List<TrainingDay> listFromMap(String jsonString) {
    final List<dynamic> decodedList = jsonDecode(jsonString);
    return decodedList.map((value) => TrainingDay.fromMap(value)).toList();
  }

  String translate(String locale) {
    switch (this) {
      case TrainingDay.monday:
        return locale == 'fr' ? 'Lundi' : 'Monday';
      case TrainingDay.tuesday:
        return locale == 'fr' ? 'Mardi' : 'Tuesday';
      case TrainingDay.wednesday:
        return locale == 'fr' ? 'Mercredi' : 'Wednesday';
      case TrainingDay.thursday:
        return locale == 'fr' ? 'Jeudi' : 'Thursday';
      case TrainingDay.friday:
        return locale == 'fr' ? 'Vendredi' : 'Friday';
      case TrainingDay.saturday:
        return locale == 'fr' ? 'Samedi' : 'Saturday';
      case TrainingDay.sunday:
        return locale == 'fr' ? 'Dimanche' : 'Sunday';
    }
  }
}

enum ExerciseType {
  running,
  yoga,
  workout,
  meditation,
  unknown;

  String toMap() {
    return name;
  }

  static ExerciseType fromMap(String value) {
    return ExerciseType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => ExerciseType.unknown,
    );
  }

  String translate(String locale) {
    switch (this) {
      case ExerciseType.running:
        return locale == 'fr' ? 'Course' : 'Running';
      case ExerciseType.yoga:
        return locale == 'fr' ? 'Yoga' : 'Yoga';
      case ExerciseType.workout:
        return locale == 'fr' ? 'Renforcement' : 'Workout';
      case ExerciseType.meditation:
        return locale == 'fr' ? 'Méditation' : 'Meditation';
      case ExerciseType.unknown:
        return locale == 'fr' ? 'Inconnu' : 'Unknown';
    }
  }
}

enum MuscleGroup {
  chest,
  back,
  shoulders,
  biceps,
  triceps,
  quads,
  hamstrings,
  calves,
  abs,
  forearms,
  traps,
  lats,
  glutes,
  obliques,
  neck,
  hipFlexors;

  String toMap() {
    return name;
  }

  static MuscleGroup fromMap(String value) {
    return MuscleGroup.values.firstWhere(
      (muscle) => muscle.name == value,
      orElse: () => throw ArgumentError('Unknown MuscleGroup value: $value'),
    );
  }

  static String listToMap(List<MuscleGroup> muscleGroups) {
    return jsonEncode(muscleGroups.map((muscle) => muscle.toMap()).toList());
  }

  static List<MuscleGroup> listFromMap(String jsonString) {
    final List<dynamic> decodedList = jsonDecode(jsonString);
    return decodedList.map((value) => MuscleGroup.fromMap(value)).toList();
  }

  String translate(String locale) {
    switch (this) {
      case MuscleGroup.chest:
        return locale == 'fr' ? 'Pectoraux' : 'Chest';
      case MuscleGroup.back:
        return locale == 'fr' ? 'Dos' : 'Back';
      case MuscleGroup.shoulders:
        return locale == 'fr' ? 'Épaules' : 'Shoulders';
      case MuscleGroup.biceps:
        return locale == 'fr' ? 'Biceps' : 'Biceps';
      case MuscleGroup.triceps:
        return locale == 'fr' ? 'Triceps' : 'Triceps';
      case MuscleGroup.quads:
        return locale == 'fr' ? 'Quadriceps' : 'Quads';
      case MuscleGroup.hamstrings:
        return locale == 'fr' ? 'Ischio-jambiers' : 'Hamstrings';
      case MuscleGroup.calves:
        return locale == 'fr' ? 'Mollets' : 'Calves';
      case MuscleGroup.abs:
        return locale == 'fr' ? 'Abdominaux' : 'Abdominals';
      case MuscleGroup.forearms:
        return locale == 'fr' ? 'Avant-bras' : 'Forearms';
      case MuscleGroup.traps:
        return locale == 'fr' ? 'Trapèzes' : 'Trapezius';
      case MuscleGroup.lats:
        return locale == 'fr' ? 'Grand dorsal' : 'Latissimus dorsi';
      case MuscleGroup.glutes:
        return locale == 'fr' ? 'Fessiers' : 'Glutes';
      case MuscleGroup.obliques:
        return locale == 'fr' ? 'Obliques' : 'Obliques';
      case MuscleGroup.neck:
        return locale == 'fr' ? 'Cou' : 'Neck';
      case MuscleGroup.hipFlexors:
        return locale == 'fr' ? 'Fléchisseurs de la hanche' : 'Hip Flexors';
    }
  }
}

enum ExerciseDifficulty {
  veryEasy,
  easy,
  moderate,
  hard,
  veryHard;

  String translate(String locale) {
    switch (this) {
      case ExerciseDifficulty.veryEasy:
        return locale == 'fr' ? 'Très facile' : 'Very easy';
      case ExerciseDifficulty.easy:
        return locale == 'fr' ? 'Facile' : 'Easy';
      case ExerciseDifficulty.moderate:
        return locale == 'fr' ? 'Modéré' : 'Moderate';
      case ExerciseDifficulty.hard:
        return locale == 'fr' ? 'Difficile' : 'Hard';
      case ExerciseDifficulty.veryHard:
        return locale == 'fr' ? 'Très difficile' : 'Very hard';
    }
  }
}

enum StatType {
  all,
  run,
  workout,
  yoga;

  String translate(String locale) {
    switch (this) {
      case StatType.all:
        return locale == 'fr' ? 'Tous' : 'All';
      case StatType.run:
        return locale == 'fr' ? 'Course' : 'Run';
      case StatType.workout:
        return locale == 'fr' ? 'Renforcement' : 'Workout';
      case StatType.yoga:
        return locale == 'fr' ? 'Yoga' : 'Yoga';
    }
  }
}

enum StatPeriod {
  week,
  month,
  year;

  String translate(String locale) {
    switch (this) {
      case StatPeriod.week:
        return locale == 'fr' ? 'Cette semaine' : 'This week';
      case StatPeriod.month:
        return locale == 'fr' ? 'Ce mois' : 'This month';
      case StatPeriod.year:
        return locale == 'fr' ? 'Cette année' : 'This year';
    }
  }
}
