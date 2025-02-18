// Enum `TrainingExerciseType`
enum TrainingExerciseType {
  run,
  yoga,
  workout,
  meditation,
  unknown;

  String translate(String locale) {
    switch (this) {
      case TrainingExerciseType.yoga:
        return locale == 'fr' ? 'Yoga' : 'Yoga';
      case TrainingExerciseType.workout:
        return locale == 'fr' ? 'Renforcement' : 'Workout';
      case TrainingExerciseType.run:
        return locale == 'fr' ? 'Course' : 'Run';
      case TrainingExerciseType.meditation:
        return locale == 'fr' ? 'Méditation' : 'Meditation';
      case TrainingExerciseType.unknown:
        return locale == 'fr' ? 'Inconnu' : 'Unknown';
    }
  }
}

// Enum `RunExerciseTarget`
enum RunType {
  distance,
  duration,
  unknown;

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

// Enum TrainingType
enum TrainingType {
  run,
  yoga,
  workout,
  unknown;

  String translate(String locale) {
    switch (this) {
      case TrainingType.yoga:
        return locale == 'fr' ? 'Yoga' : 'Yoga';
      case TrainingType.workout:
        return locale == 'fr' ? 'Renforcement' : 'Workout';
      case TrainingType.run:
        return locale == 'fr' ? 'Course' : 'Run';
      case TrainingType.unknown:
        return locale == 'fr' ? 'Inconnu' : 'Unknown';
    }
  }
}

// Enum WeekDay
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

enum ExerciseType {
  yoga,
  workout,
  meditation,
  unknown;

  String translate(String locale) {
    switch (this) {
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
        return locale == 'fr' ? 'Quadriceps' : 'Quadriceps';

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
        return locale == 'fr' ? 'Fléchisseurs de la hanche' : 'Hip flexors';
    }
  }
}
