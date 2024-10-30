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
    late Database db;

    setUp(() async {
      // Use an in-memory database with sqflite_ffi
      db = await openDatabase(inMemoryDatabasePath, version: 1,
          onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE exercises(
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            name TEXT, 
            description TEXT, 
            image_path TEXT
          )
        ''');
      });
    });

    tearDown(() async {
      await db.close();
    });

    test('database should be created and open', () async {
      expect(db.isOpen, true);
    });

    test('exercises table should exist', () async {
      final tables = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='exercises'");
      expect(tables.isNotEmpty, true);
    });

    test('can insert and retrieve an exercise', () async {
      // Insert a sample exercise
      await db.insert('exercises', {
        'name': 'Push Up',
        'description': 'An exercise for upper body strength',
        'image_path': '/images/push_up.png'
      });

      // Retrieve the exercise
      final result = await db.query('exercises');
      expect(result.length, 1);
      expect(result.first['name'], 'Push Up');
      expect(
          result.first['description'], 'An exercise for upper body strength');
      expect(result.first['image_path'], '/images/push_up.png');
    });

    test('can update an exercise', () async {
      // Insert a sample exercise to update
      await db.insert('exercises', {
        'name': 'Push Up',
        'description': 'An exercise for upper body strength',
        'image_path': '/images/push_up.png'
      });

      // Update the exercise
      await db.update(
        'exercises',
        {'name': 'Modified Push Up'},
        where: 'name = ?',
        whereArgs: ['Push Up'],
      );

      // Retrieve the updated exercise
      final result = await db.query('exercises');
      expect(result.length, 1);
      expect(result.first['name'], 'Modified Push Up');
    });

    test('can delete an exercise', () async {
      // Insert a sample exercise to delete
      await db.insert('exercises', {
        'name': 'Push Up',
        'description': 'An exercise for upper body strength',
        'image_path': '/images/push_up.png'
      });

      // Delete the exercise
      await db.delete(
        'exercises',
        where: 'name = ?',
        whereArgs: ['Push Up'],
      );

      // Verify the exercise is deleted
      final result = await db.query('exercises');
      expect(result.isEmpty, true);
    });
  });

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
}
