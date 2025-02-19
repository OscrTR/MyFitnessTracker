import 'package:get_it/get_it.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'core/database/object_box.dart';
import 'features/settings/bloc/settings_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/messages/bloc/message_bloc.dart';
import 'features/active_training/bloc/active_training_bloc.dart';
import 'features/training_history/bloc/training_history_bloc.dart';
import 'features/training_management/bloc/training_management_bloc.dart';
import 'features/exercise_management/bloc/exercise_management_bloc.dart';
import 'features/active_training/foreground_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
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
  sl.registerLazySingleton<TrainingHistoryBloc>(
      () => TrainingHistoryBloc(messageBloc: sl()));

  //! Features - Training Management
  // Bloc
  sl.registerLazySingleton<SettingsBloc>(() => SettingsBloc(
        sharedPreferences: sl(),
      ));
}
