import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'core/navigation_cubit.dart';
import 'core/permission_cubit.dart';

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
  sl.registerSingleton(DatabaseService());
  sl.registerSingleton(FlutterLocalNotificationsPlugin());
  sl.registerSingleton(PermissionCubit(flutterLocalNotificationsPlugin: sl()));
  sl.registerSingleton(NavigationCubit());

  //! Features - Exercise Management
  sl.registerSingleton(BaseExerciseManagementBloc());

  //! Features - Training Management
  sl.registerSingleton(TrainingManagementBloc());

  //! Features - Active Training
  sl.registerSingleton(ActiveTrainingBloc());
  sl.registerSingleton(ForegroundService());

  //! Features - Training History
  sl.registerSingleton(TrainingHistoryBloc());

  //! Features - Training Management
  sl.registerSingleton(SettingsBloc());
}
