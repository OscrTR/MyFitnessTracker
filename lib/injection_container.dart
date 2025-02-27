import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';

import 'core/database/database_service.dart';
import 'features/active_training/bloc/active_training_bloc.dart';
import 'features/active_training/foreground_service.dart';
import 'features/base_exercise_management/bloc/base_exercise_management_bloc.dart';
import 'features/settings/bloc/settings_bloc.dart';
import 'features/training_history/bloc/training_history_bloc.dart';
import 'features/training_management/bloc/training_management_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Core
  sl.registerLazySingleton(() => DatabaseService());
  sl.registerLazySingleton(() => FlutterLocalNotificationsPlugin());

  //! Features - Exercise Management
  sl.registerLazySingleton(() => BaseExerciseManagementBloc());

  //! Features - Training Management
  sl.registerLazySingleton(() => TrainingManagementBloc());

  //! Features - Active Training
  sl.registerLazySingleton(() => ActiveTrainingBloc());
  sl.registerLazySingleton(() => ForegroundService());

  //! Features - Training History
  sl.registerLazySingleton<TrainingHistoryBloc>(() => TrainingHistoryBloc());

  //! Features - Training Management
  sl.registerLazySingleton<SettingsBloc>(() => SettingsBloc());
}
