class LocalDatabaseException implements Exception {
  final String message;

  LocalDatabaseException(
      [this.message = 'An unknown database error occurred.']);

  @override
  String toString() => 'LocalDatabaseException: $message';
}

class ExerciseNameException implements Exception {}
