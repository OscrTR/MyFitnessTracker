import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/database/database_service.dart';
import 'core/messages/bloc/message_bloc.dart';
import 'features/active_training/bloc/active_training_bloc.dart';
import 'features/active_training/foreground_service.dart';
import 'features/base_exercise_management/bloc/base_exercise_management_bloc.dart';
import 'features/settings/bloc/settings_bloc.dart';
import 'features/training_history/bloc/training_history_bloc.dart';
import 'features/training_management/bloc/training_management_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerLazySingleton<DatabaseService>(() => DatabaseService());

  //! Core
  sl.registerLazySingleton(() => MessageBloc());
  sl.registerLazySingleton(() => FlutterLocalNotificationsPlugin());
  sl.registerLazySingletonAsync(
      () async => await SharedPreferences.getInstance());

  await sl.isReady<SharedPreferences>();

  //! Features - Exercise Management
  // Bloc
  sl.registerLazySingleton(() => BaseExerciseManagementBloc(messageBloc: sl()));

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
  sl.registerLazySingleton<TrainingHistoryBloc>(
      () => TrainingHistoryBloc(messageBloc: sl()));

  //! Features - Training Management
  // Bloc
  sl.registerLazySingleton<SettingsBloc>(() => SettingsBloc(
        sharedPreferences: sl(),
      ));
}
