import 'package:get_it/get_it.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:my_fitness_tracker/core/database/object_box.dart';
import 'package:my_fitness_tracker/features/training_history/domain/usecases/fetch_history_run_locations.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'core/database/sqlite_database_helper.dart';
import 'core/messages/bloc/message_bloc.dart';

import 'features/active_training/presentation/bloc/active_training_bloc.dart';

import 'features/training_history/domain/usecases/check_recent_entry.dart';
import 'features/training_history/data/datasources/history_local_data_source.dart';
import 'features/training_history/data/repositories/history_repository_impl.dart';
import 'features/training_history/domain/repositories/history_repository.dart';
import 'features/training_history/domain/usecases/create_history_entry.dart';
import 'features/training_history/domain/usecases/get_history_entry.dart';
import 'features/training_history/domain/usecases/update_history_entry.dart';
import 'features/training_history/domain/usecases/delete_history_entry.dart';
import 'features/training_history/domain/usecases/fetch_history_entries.dart';
import 'features/training_history/presentation/bloc/training_history_bloc.dart';

import 'features/training_management/presentation/bloc/training_management_bloc.dart';
import 'features/exercise_management/presentation/bloc/exercise_management_bloc.dart';
import 'features/active_training/presentation/foreground_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Register the Database (async registration)
  sl.registerLazySingletonAsync<Database>(
      () async => await SQLiteDatabaseHelper.getDatabase());

  // Ensure the Database is ready before registering anything that depends on it
  await sl.isReady<Database>();

  sl.registerSingletonAsync<ObjectBox>(() async => await ObjectBox.create());

  //! Core
  sl.registerLazySingleton(() => MessageBloc());
  sl.registerLazySingleton(() => FlutterLocalNotificationsPlugin());
  sl.registerLazySingletonAsync(
      () async => await SharedPreferences.getInstance());

  await sl.isReady<SharedPreferences>();

  //! Features - Exercise Management
  // Bloc
  sl.registerLazySingleton(() => ExerciseManagementBloc(messageBloc: sl()));

  //! Features - Training Management
  // Bloc
  sl.registerLazySingleton(() => TrainingManagementBloc(
        messageBloc: sl(),
      ));

  //! Features - Active Training
  // Bloc
  sl.registerLazySingleton(() => ActiveTrainingBloc());

  sl.registerLazySingleton(() => ForegroundService());

  //! Features - Training History
  // Bloc
  sl.registerLazySingleton<TrainingHistoryBloc>(() => TrainingHistoryBloc(
        messageBloc: sl(),
        createHistoryEntry: sl(),
        fetchHistoryEntries: sl(),
        updateHistoryEntry: sl(),
        deleteHistoryEntry: sl(),
        getHistoryEntry: sl(),
        checkRecentEntry: sl(),
        fetchHistoryRunLocations: sl(),
      ));

  // Usecases
  sl.registerLazySingleton(() => CreateHistoryEntry(sl()));
  sl.registerLazySingleton(() => FetchHistoryEntries(sl()));
  sl.registerLazySingleton(() => GetHistoryEntry(sl()));
  sl.registerLazySingleton(() => UpdateHistoryEntry(sl()));
  sl.registerLazySingleton(() => DeleteHistoryEntry(sl()));
  sl.registerLazySingleton(() => CheckRecentEntry(sl()));
  sl.registerLazySingleton(() => FetchHistoryRunLocations(sl()));

  // Repository
  sl.registerLazySingleton<HistoryRepository>(
      () => HistoryRepositoryImpl(localDataSource: sl()));

  // Data sources
  sl.registerLazySingleton<HistoryLocalDataSource>(
      () => SQLiteHistoryLocalDataSource(database: sl()));

  //! Features - Training Management
  // Bloc
  sl.registerLazySingleton<SettingsBloc>(() => SettingsBloc(
        sharedPreferences: sl(),
      ));
}
