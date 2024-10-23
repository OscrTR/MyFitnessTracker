import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:my_fitness_tracker/core/database/sqlite_database_helper.dart';

void main() {
  // Initialize sqflite_ffi for tests
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('SQLiteDatabaseHelper', () {
    test('should return a singleton database instance', () async {
      // Act
      final db1 = await SQLiteDatabaseHelper.getDatabase();
      final db2 = await SQLiteDatabaseHelper.getDatabase();

      // Assert: Verify both instances are the same (singleton behavior)
      expect(db1, db2);
    });

    test('should create the exercises table when the database is created',
        () async {
      // Act: Initialize the database (this should trigger the onCreate callback)
      final db = await SQLiteDatabaseHelper.getDatabase();

      // Assert: Ensure the exercises table exists by checking its schema
      final result = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='exercises'");

      expect(result.isNotEmpty, true); // The exercises table should be created
    });
  });
}
